import Foundation
import Combine

class GameManager: ObservableObject {
    @Published var players: [Player] = []
    @Published var currentPlayerIndex: Int = 0
    @Published var gameState: GameState = .finished
    @Published var winner: Player?
    
    let numberOfPlayers: Int
    
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
    
    init(numberOfPlayers: Int) {
        self.numberOfPlayers = numberOfPlayers
    }
    
    // Початок гри - тільки роздача
    func startGame() {
        var deck = Deck()
        deck.shuffle()
        
        let hands = deck.dealCards(numberOfPlayers: numberOfPlayers)
        
        // Створюємо гравців
        players = []
        for (index, hand) in hands.enumerated() {
            let isHuman = (index == 0) // Перший гравець - людина
            let player = Player(hand: hand, isHuman: isHuman, playerNumber: index + 1)
            players.append(player)
        }
        
        // Починаємо з роздачі
        gameState = .dealing
        foundPairs = [:]
    }
    
    // Знайти всі пари у всіх гравців (без видалення)
    func findPairsInAllPlayers() {
        foundPairs = [:]
        for i in 0..<players.count {
            foundPairs[i] = findPairs(for: i)
        }
        gameState = .showingPairs
    }
    
    // Знайти пари у конкретного гравця (повертає масив пар)
    func findPairs(for playerIndex: Int) -> [[PlayingCard]] {
        guard playerIndex < players.count else { return [] }
        
        let hand = players[playerIndex].hand
        var ranks: [String: [PlayingCard]] = [:]
        
        // Групуємо карти за рангом
        for card in hand {
            let rank = card.rank
            if ranks[rank] == nil {
                ranks[rank] = []
            }
            ranks[rank]?.append(card)
        }
        
        // Знаходимо пари (2, 4, 6... карт одного рангу)
        var pairs: [[PlayingCard]] = []
        for (_, cards) in ranks {
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
        removePairsFromAllPlayers()
        
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
            removePairs(for: i)
        }
    }
    
    // Скидання пар у конкретного гравця (використовує знайдені пари)
    private func removePairs(for playerIndex: Int) {
        guard playerIndex < players.count else { return }
        
        // Отримуємо всі карти з пар (використовуємо rawValue для порівняння)
        var cardsToRemove: [String] = []
        if let pairs = foundPairs[playerIndex] {
            for pair in pairs {
                for card in pair {
                    cardsToRemove.append(card.rawValue)
                }
            }
        }
        
        // Видаляємо карти з руки
        players[playerIndex].hand = players[playerIndex].hand.filter { !cardsToRemove.contains($0.rawValue) }
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
        // Спочатку знаходимо пари
        foundPairs[currentPlayerIndex] = findPairs(for: currentPlayerIndex)
        // Потім видаляємо їх
        checkAndRemovePairs(for: currentPlayerIndex)
    }
    
    // Перевірка та видалення пар у гравця
    private func checkAndRemovePairs(for playerIndex: Int) {
        removePairs(for: playerIndex)
    }
    
    // Перевірка чи є переможець
    func checkForWinner() {
        let playersWithCards = players.filter { $0.hasCards }
        
        if playersWithCards.count == 1 {
            // Залишився один гравець - він програє
            winner = nil
            gameState = .finished
        } else if playersWithCards.isEmpty || playersWithCards.count == 0 {
            // Всі без карт - нічия (не повинно статися)
            gameState = .finished
        } else {
            // Перевіряємо чи хтось виграв (немає карт)
            for player in players {
                if !player.hasCards {
                    winner = player
                    gameState = .finished
                    return
                }
            }
        }
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

