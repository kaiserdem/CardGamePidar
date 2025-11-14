import Foundation
import Combine

class GameManager: ObservableObject {
    @Published var players: [Player] = []
    @Published var currentPlayerIndex: Int = 0
    @Published var gameState: GameState = .finished
    @Published var winner: Player?
    
    let numberOfPlayers: Int
    
    // Статистика для діагностики
    private static var gameCount = 0
    private static var cardsAfterRemovalHistory: [[Int]] = []
    
    // Відстеження deadlock (зациклення)
    private var previousCardCounts: [Int] = []
    private var noChangeTurns: Int = 0
    
    // Спеціальна перевірка для випадку з 3 картами
    private var threeCardsExchangeCount: Int = 0
    private var lastThreeCardsState: [Int] = []
    
    // Відстеження серій успішних ходів для нарахування монет
    private var lastMoves: [Int: Int] = [:] // playerIndex: кількість успішних ходів підряд
    
    enum GameState {
        case notStarted
        case dealing          // Роздача карт
        case showingPairs     // Показ знайдених пар
        case removingPairs    // Анімація скидання пар
        case inProgress       // Гра в процесі
        case finished
    }
    
    // Знайдені пари для відображення (playerIndex: [пари карт])
    @Published var foundPairs: [Int: [[PlayingCard]]] = [:]
    
    let selectedBot: BotProfile?
    
    init(numberOfPlayers: Int, selectedBot: BotProfile? = nil) {
        self.numberOfPlayers = numberOfPlayers
        self.selectedBot = selectedBot
    }
    
    // Початок гри - роздача та одразу видалення пар
    func startGame() {
        GameManager.gameCount += 1
        print("=== ГРА #\(GameManager.gameCount) ===")
        
        // Скидаємо відстеження deadlock
        previousCardCounts = []
        noChangeTurns = 0
        threeCardsExchangeCount = 0
        lastThreeCardsState = []
        
        // Скидаємо відстеження серій ходів
        lastMoves = [:]
        
        var deck = Deck()
        // shuffle() викликається всередині dealCards() і відтворює звук тасування
        let hands = deck.dealCards(numberOfPlayers: numberOfPlayers)
        
        // Створюємо гравців
        players = []
        for (index, hand) in hands.enumerated() {
            let isHuman = (index == 0) // Перший гравець - людина
            var playerNumber = index + 1
            
            // Якщо це бот і є вибраний бот, використовуємо його номер
            if !isHuman, let bot = selectedBot {
                playerNumber = bot.avatar.playerNumber
            }
            
            let player = Player(hand: hand, isHuman: isHuman, playerNumber: playerNumber)
            players.append(player)
        }
        
        print("=== ПЕРЕД ВИДАЛЕННЯМ ПАР ===")
        for i in 0..<players.count {
            print("Гравець \(i + 1): \(players[i].hand.count) карт")
        }
        
        // Одразу видаляємо пари (без показу всіх карт)
        removePairsFromAllPlayers()
        
        print("=== ПІСЛЯ ВИДАЛЕННЯ ПАР ===")
        for i in 0..<players.count {
            let remaining = players[i].hand.count
            print("Гравець \(i + 1): \(remaining) карт залишилось")
        }
        
        // Очищаємо знайдені пари
        foundPairs = [:]
        
        // Зберігаємо початкову кількість карт для відстеження deadlock
        previousCardCounts = players.map { $0.hand.count }
        
        // Перевіряємо чи хтось не виграв одразу
        checkForWinner()
        
        // Починаємо з роздачі (для анімації)
        gameState = .dealing
    }
    
    // Знайти всі пари у всіх гравців (без видалення)
    func findPairsInAllPlayers() {
        foundPairs = [:]
        print("=== ЗНАЙДЕНІ ПАРИ ===")
        for i in 0..<players.count {
            let pairs = findPairs(for: i)
            foundPairs[i] = pairs
            print("Гравець \(i + 1): знайдено \(pairs.count) пар")
        }
        gameState = .showingPairs
    }
    
    // Видалити пари з руки (логіка гри "Підара")
    private func removePairs(from hand: [PlayingCard]) -> [PlayingCard] {
        var groups = Dictionary(grouping: hand, by: { $0.rank })
        var result: [PlayingCard] = []
        
        for (_, cards) in groups {
            switch cards.count {
            case 1:
                result.append(cards[0])          // одна карта → залишається
            case 2:
                break                            // пара → видаляємо
            case 3, 4:
                result.append(cards[0])          // трійка/квартет → залишаємо одну карту
            default:
                let remainder = cards.count % 2
                if remainder == 1 {
                    result.append(cards[0])
                }
                // Якщо парна кількість (6, 8...) → видаляємо всі
            }
        }
        
        return result
    }
    
    // Знайти пари у конкретного гравця (повертає масив пар для відображення)
    func findPairs(for playerIndex: Int) -> [[PlayingCard]] {
        guard playerIndex < players.count else { return [] }
        
        let hand = players[playerIndex].hand
        var ranks: [String: [PlayingCard]] = [:]
        
        // Групуємо карти за рангом
        for card in hand {
            let rank = card.rank
            ranks[rank, default: []].append(card)
        }
        
        // Знаходимо пари для відображення (2, 4, 6... карт одного рангу)
        var pairs: [[PlayingCard]] = []
        
        for (rank, cards) in ranks {
            let count = cards.count
            if count >= 2 {
                // Якщо парна кількість - всі утворюють пари
                if count % 2 == 0 {
                    // Розбиваємо на пари по 2
                    for i in stride(from: 0, to: count, by: 2) {
                        pairs.append([cards[i], cards[i + 1]])
                    }
                } else {
                    // Непарна кількість - всі крім останньої утворюють пари
                    for i in stride(from: 0, to: count - 1, by: 2) {
                        pairs.append([cards[i], cards[i + 1]])
                    }
                }
            }
        }
        
        return pairs
    }
    
    // Перехід до анімації скидання пар
    func startRemovingPairs() {
        gameState = .removingPairs
    }
    
    // Видалити пари після анімації
    func removePairsAfterAnimation() {
        print("=== ПЕРЕД ВИДАЛЕННЯМ ПАР ===")
        for i in 0..<players.count {
            print("Гравець \(i + 1): \(players[i].hand.count) карт")
        }
        
        removePairsFromAllPlayers()
        
        // Звук видалення пари
        SoundManager.shared.playPairRemovedSound()
        
        print("=== ПІСЛЯ ВИДАЛЕННЯ ПАР ===")
        var cardsAfterRemoval: [Int] = []
        for i in 0..<players.count {
            let remaining = players[i].hand.count
            cardsAfterRemoval.append(remaining)
            print("Гравець \(i + 1): \(remaining) карт залишилось")
            print("  Залишились карти: \(players[i].hand.map { $0.rawValue })")
        }
        
        // Зберігаємо статистику
        GameManager.cardsAfterRemovalHistory.append(cardsAfterRemoval)
        if GameManager.cardsAfterRemovalHistory.count >= 5 {
            print("\n=== СТАТИСТИКА ЗА ОСТАННІ \(GameManager.cardsAfterRemovalHistory.count) ІГОР ===")
            for (gameIndex, cards) in GameManager.cardsAfterRemovalHistory.enumerated() {
                print("Гра #\(gameIndex + 1): \(cards.map { "\($0)" }.joined(separator: ", ")) карт")
            }
            
            // Перевіряємо чи завжди однакова кількість
            let allSame = GameManager.cardsAfterRemovalHistory.allSatisfy { cards in
                cards.allSatisfy { $0 == cards.first }
            }
            if allSame {
                print("⚠️ УВАГА: Завжди однакова кількість карт після видалення пар!")
            } else {
                // Знаходимо унікальні комбінації
                let unique = Set(GameManager.cardsAfterRemovalHistory.map { $0 })
                print("Унікальні комбінації: \(unique.count)")
            }
        }
        
        // Очищаємо знайдені пари (щоб жовтий бордер зник)
        foundPairs = [:]
        
        // Перевіряємо чи хтось не виграв одразу
        checkForWinner()
        
        if gameState != .finished {
            gameState = .inProgress
            currentPlayerIndex = 0
        }
    }
    
    // Автоматичне скидання пар у всіх гравців
    private func removePairsFromAllPlayers() {
        for i in 0..<players.count {
            let initialCount = players[i].hand.count
            players[i].hand = removePairs(from: players[i].hand)
            let remaining = players[i].hand.count
            print("Гравець \(i + 1): було \(initialCount) карт, залишилось \(remaining) карт")
        }
    }
    
    // Скидання пар у конкретного гравця
    private func removePairs(for playerIndex: Int) {
        guard playerIndex < players.count else { return }
        let initialCount = players[playerIndex].hand.count
        players[playerIndex].hand = removePairs(from: players[playerIndex].hand)
        let remaining = players[playerIndex].hand.count
        print("Гравець \(playerIndex + 1): було \(initialCount) карт, залишилось \(remaining) карт")
    }
    
    // Поточний гравець
    var currentPlayer: Player? {
        guard currentPlayerIndex < players.count else { return nil }
        return players[currentPlayerIndex]
    }
    
    // Взяти випадкову карту у суперника
    func takeCardFromOpponent(opponentIndex: Int) -> PlayingCard? {
        guard opponentIndex < players.count,
              opponentIndex != currentPlayerIndex,
              !players[opponentIndex].hand.isEmpty else {
            return nil
        }
        
        // Випадкова карта з руки суперника
        let randomIndex = Int.random(in: 0..<players[opponentIndex].hand.count)
        let card = players[opponentIndex].hand.remove(at: randomIndex)
        
        // Додаємо карту поточному гравцю
        players[currentPlayerIndex].hand.append(card)
        
        // Перевіряємо чи утворилась пара
        checkAndRemovePairs(for: currentPlayerIndex)
        
        // Перевіряємо переможця
        checkForWinner()
        
        return card
    }
    
    // Взяти карту у суперника без додавання до руки (для показу на столі)
    func takeCardFromOpponentWithoutAdding(opponentIndex: Int) -> PlayingCard? {
        guard opponentIndex < players.count,
              opponentIndex != currentPlayerIndex,
              !players[opponentIndex].hand.isEmpty else {
            return nil
        }
        
        // Випадкова карта з руки суперника
        let randomIndex = Int.random(in: 0..<players[opponentIndex].hand.count)
        let card = players[opponentIndex].hand.remove(at: randomIndex)
        
        return card
    }
    
    // Додати карту до руки поточного гравця
    func addCardToCurrentPlayer(card: PlayingCard) {
        players[currentPlayerIndex].hand.append(card)
    }
    
    // Перевірити та видалити пари для поточного гравця
    func checkAndRemovePairsForCurrentPlayer() {
        // Видаляємо пари використовуючи нову логіку
        removePairs(for: currentPlayerIndex)
        // Очищаємо знайдені пари для цього гравця
        foundPairs[currentPlayerIndex] = []
        
        // Перевіряємо на deadlock
        checkForDeadlock()
    }
    
    // Перевірка та видалення пар у гравця
    private func checkAndRemovePairs(for playerIndex: Int) {
        removePairs(for: playerIndex)
        // Перевіряємо на deadlock після видалення пар
        checkForDeadlock()
    }
    
    // Перевірка чи утворилась пара після додавання карти
    func formsPair(card: PlayingCard, playerIndex: Int) -> Bool {
        guard playerIndex < players.count else { return false }
        let hand = players[playerIndex].hand
        let rankCount = hand.filter { $0.rank == card.rank }.count
        return rankCount == 2 // якщо після додавання карти стало 2 → пара утворилась
    }
    
    // Нарахування монет за хід
    func awardCoinsForMove(takenCard: PlayingCard, from opponentIndex: Int, opponentCardsCountBefore: Int) {
        guard let currentPlayer = currentPlayer, currentPlayer.isHuman else { return }
        guard currentPlayerIndex < players.count, opponentIndex < players.count else { return }
        
        // Базова нагорода залежно від карт суперника (до видалення карти)
        var coinsEarned = max(1, opponentCardsCountBefore) // чим більше карт, тим більше монет
        
        // Додатково, якщо утворилась пара після додавання карти
        if formsPair(card: takenCard, playerIndex: currentPlayerIndex) {
            coinsEarned += 5
        }
        
        // Серія успішних ходів: перевірка попередніх ходів
        if let lastMove = lastMoves[currentPlayerIndex], lastMove > 1 {
            coinsEarned += lastMove // бонус за серію
        }
        
        // Застосовуємо коефіцієнт грошей від вибраного бота
        let multiplier = selectedBot?.moneyMultiplier ?? 1.0
        let finalCoinsEarned = Int(Double(coinsEarned) * multiplier)
        
        // Нарахування
        players[currentPlayerIndex].coins += finalCoinsEarned
        print("🎉 Гравець \(currentPlayer.playerNumber) отримав \(finalCoinsEarned) монет (базово \(coinsEarned) × \(multiplier)x), всього: \(players[currentPlayerIndex].coins)")
        
        // Звук додавання монет
        SoundManager.shared.playCoinSound()
        
        // Оновлюємо історію ходів для серій
        lastMoves[currentPlayerIndex] = formsPair(card: takenCard, playerIndex: currentPlayerIndex) ? (lastMoves[currentPlayerIndex] ?? 0) + 1 : 0
    }
    
    // Перевірка на deadlock (зациклення)
    private func checkForDeadlock() {
        let currentCardCounts = players.map { $0.hand.count }
        let totalCards = currentCardCounts.reduce(0, +)
        
        // Спеціальна перевірка для випадку з 3 картами
        if totalCards == 3 {
            // Якщо це перший раз коли залишилось 3 карти - ініціалізуємо стан
            if lastThreeCardsState.isEmpty {
                lastThreeCardsState = currentCardCounts
                threeCardsExchangeCount = 0
            } else {
                // Перевіряємо чи стан змінився (карти передаються між гравцями)
                // Якщо стан змінився - це означає що карта була передана
                if currentCardCounts != lastThreeCardsState {
                    // Стан змінився - карта передана, збільшуємо лічильник
                    threeCardsExchangeCount += 1
                    lastThreeCardsState = currentCardCounts
                    
                    print("🔄 Передача карти при 3 картах. Лічильник: \(threeCardsExchangeCount)")
                }
            }
            
            // Якщо карти передаються більше 3 разів - нічия
            if threeCardsExchangeCount > 3 {
                print("⚠️ НІЧИЯ! Залишилось 3 карти і вони передаються більше 3 разів")
                print("  Поточний стан: \(currentCardCounts)")
                
                // Нічия - виграш ділиться пополам
                self.winner = nil
                
                // Ділимо монети пополам між гравцями
                if players.count >= 2 {
                    let totalCoins = players.reduce(0) { $0 + $1.coins }
                    let coinsPerPlayer = totalCoins / players.count
                    
                    for i in 0..<players.count {
                        players[i].coins = coinsPerPlayer
                    }
                    
                    print("💰 Монети розподілено порівну: \(coinsPerPlayer) монет кожному гравцю")
                }
                
                // Зберігаємо статистику (нічия = програш для гравця)
                saveGameStatistics(didWin: false)
                
                gameState = .finished
                return
            }
        } else {
            // Якщо не 3 карти - скидаємо лічильник
            if totalCards != 3 {
                threeCardsExchangeCount = 0
                lastThreeCardsState = []
            }
        }
        
        // Звичайна перевірка deadlock
        // Якщо кількість карт не змінилась
        if currentCardCounts == previousCardCounts {
            noChangeTurns += 1
        } else {
            noChangeTurns = 0
            previousCardCounts = currentCardCounts
        }
        
            // Якщо протягом 5 ходів кількість карт не змінилась - deadlock
        if noChangeTurns >= 5 {
            print("⚠️ DEADLOCK виявлено! Кількість карт не змінюється протягом \(noChangeTurns) ходів")
            print("  Поточний стан: \(currentCardCounts)")
            
            // Завершуємо гру - виграє той, у кого більше карт
            let playersWithCards = players.filter { $0.hasCards }
            if let winner = playersWithCards.max(by: { $0.hand.count < $1.hand.count }) {
                self.winner = winner
                // Зберігаємо статистику
                saveGameStatistics(didWin: winner.isHuman)
            } else {
                // Якщо однакова кількість - нічия
                self.winner = nil
                // Зберігаємо статистику (нічия = програш для гравця)
                saveGameStatistics(didWin: false)
            }
            
            gameState = .finished
        }
    }
    
    // Перевірка чи є переможець
    func checkForWinner() {
        // Гравці, у яких ще є карти
        let playersWithCards = players.filter { $0.hasCards }
        
        if playersWithCards.count == 1 {
            // Залишився один гравець → він виграв
            winner = playersWithCards.first
            
            // Нараховуємо бонус за виграш (тільки для людини)
            if let winner = winner, winner.isHuman {
                // Знаходимо індекс переможця
                if let winnerIndex = players.firstIndex(where: { $0.id == winner.id }) {
                    let winBonus = 50
                    players[winnerIndex].coins += winBonus
                    print("🏆 Гравець виграв! Бонус: \(winBonus) монет, всього: \(players[winnerIndex].coins)")
                    // Звук виграшу
                    SoundManager.shared.playWinSound()
                }
            } else {
                // Звук програшу
                SoundManager.shared.playLoseSound()
            }
            
            // Зберігаємо статистику
            saveGameStatistics(didWin: winner?.isHuman ?? false)
            
            gameState = .finished
        } else if playersWithCards.isEmpty {
            // Усі без карт → нічия
            winner = nil
            // Зберігаємо статистику (нічия = програш для гравця)
            saveGameStatistics(didWin: false)
            gameState = .finished
        } else {
            // Гра ще триває
            winner = nil
        }
    }
    
    // Зберегти статистику гри
    private func saveGameStatistics(didWin: Bool) {
        // Знаходимо бота (індекс 1, якщо є selectedBot)
        if let bot = selectedBot {
            let playerWon = didWin
            StatisticsManager.shared.recordGame(botId: bot.id, didWin: playerWon)
            print("📊 Статистика збережена: \(bot.name) - \(playerWon ? "Перемога" : "Поразка")")
        }
    }
    
    // Отримати монети гравця (для збереження в ShopManager)
    func getPlayerCoins() -> Int {
        guard !players.isEmpty, players[0].isHuman else { return 0 }
        return players[0].coins
    }
    
    // Перехід до наступного гравця
    func nextTurn() {
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
        
        // Пропускаємо гравців без карт
        var attempts = 0
        while !players[currentPlayerIndex].hasCards && attempts < players.count {
            currentPlayerIndex = (currentPlayerIndex + 1) % players.count
            attempts += 1
        }
    }
    
    // Бот робить хід (випадково вибирає суперника та бере карту)
    func botTurn() {
        guard let currentPlayer = currentPlayer,
              !currentPlayer.isHuman else {
            return
        }
        
        // Знаходимо суперників з картами
        let opponents = players.enumerated()
            .filter { $0.offset != currentPlayerIndex && $0.element.hasCards }
            .map { $0.offset }
        
        guard !opponents.isEmpty else {
            checkForWinner()
            return
        }
        
        // Випадковий суперник
        let randomOpponent = opponents.randomElement()!
        _ = takeCardFromOpponent(opponentIndex: randomOpponent)
        
        // Перехід до наступного гравця
        nextTurn()
    }
}

