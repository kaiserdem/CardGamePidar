import SwiftUI

struct GameView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var gameManager: GameManager
    @State private var dealtCards: [Int: [Bool]] = [:] // Трекінг розданих карт для анімації
    @State private var removingPairsDelay: Double = 0
    @State private var cardOnTable: PlayingCard? // Карта на столі
    @State private var cardOnTableOwner: Int? // Чия карта (0 - гравець, 1 - бот)
    
    let numberOfPlayers: Int
    
    init(numberOfPlayers: Int) {
        self.numberOfPlayers = numberOfPlayers
        _gameManager = StateObject(wrappedValue: GameManager(numberOfPlayers: numberOfPlayers))
    }
    
    var body: some View {
        ZStack {
            // Чорний фон для верхньої частини
            Color.black
                .ignoresSafeArea()
            
            // Фон гри
            VStack(spacing: 0) {
                // Відступ зверху
                Color.black
                    .frame(height: 150)
                
                // Основний фон
                Image("bg3")
                    .resizable()
                    .scaledToFill()
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Верхня частина: кнопка назад
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image("back")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                    .padding(.leading, 20)
                    .padding(.top, 120)
                    
                    Spacer()
                }
                
                // Аватар бота зверху посередині (круглий з border)
                if numberOfPlayers == 2, gameManager.players.count > 1 {
                    HStack {
                        Spacer()
                        Image((PlayerAvatar.allCases.first { $0.playerNumber == 2 } ?? .player2).roundedVersion.imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(Color(hex: "A3702C"), lineWidth: 3)
                            )
                        Spacer()
                    }
                    .padding(.top, -20)
                }
                
               // Spacer()
                
                // Карти бота (показуємо тільки після видалення пар)
                if (gameManager.gameState == .inProgress || gameManager.gameState == .finished), numberOfPlayers == 2, gameManager.players.count > 1 {
                    VStack(spacing: 8) {
                        // Карта на столі над картами бота (фіксована висота, щоб не пригав UI)
                        
                        // Карти бота (закриті) у сітці
                        CardsGridView(
                            cards: gameManager.players[1].hand,
                            isFaceUp: false,
                            foundPairs: gameManager.foundPairs[1] ?? [],
                            playerIndex: 1,
                            cardBack: .default
                        )
                        
                        ZStack {
                            // Невидимий placeholder для фіксації розміру
                            Color.clear
                                .frame(height: 0)
                            
                            if let card = cardOnTable, cardOnTableOwner == 1 {
                                CardView(
                                    card: card,
                                    isFaceUp: true,
                                    cardBack: .default
                                )
                                .frame(width: 80, height: 112)
                                .transition(.opacity.combined(with: .scale(scale: 0.8)))
                            }
                        }
                        .frame(height: 112) // Фіксована висота
                    }
                    .padding(.top, 20)
                }
                
                Spacer()
                                
                // Контент гри (текст стану по центру)
                gameContent
                
                Spacer()
                
               
                
                // Нижня частина: карти користувача (показуємо тільки після видалення пар)
                if (gameManager.gameState == .inProgress || gameManager.gameState == .finished), !gameManager.players.isEmpty, gameManager.players[0].isHuman {
                    VStack(spacing: 8) {
                        // Карта на столі над картами гравця (фіксована висота, щоб не пригав UI)
                        ZStack {
                            // Невидимий placeholder для фіксації розміру
                            Color.clear
                                .frame(height: 0)
                            
                            if let card = cardOnTable, cardOnTableOwner == 0 {
                                CardView(
                                    card: card,
                                    isFaceUp: true,
                                    cardBack: .default
                                )
                                .frame(width: 80, height: 112)
                                .transition(.opacity.combined(with: .scale(scale: 0.8)))
                            }
                        }
                        .frame(height: 112) // Фіксована висота
                        
                        // Карти користувача у сітці
                        CardsGridView(
                            cards: gameManager.players[0].hand,
                            isFaceUp: true,
                            foundPairs: gameManager.foundPairs[0] ?? [],
                            playerIndex: 0,
                            cardBack: .default
                        )
                    }
                    .padding(.bottom, 120)
                }
            }
        }
        .onAppear {
            startGameSequence()
        }
        .onChange(of: gameManager.gameState) { newState in
            handleStateChange(newState)
        }
    }
    
    @ViewBuilder
    private var gameContent: some View {
        switch gameManager.gameState {
        case .notStarted, .dealing:
            dealingView
        case .showingPairs:
            showingPairsView
        case .removingPairs:
            removingPairsView
        case .inProgress:
            inProgressView
        case .finished:
            finishedView
        }
    }
    
    // MARK: - Dealing View
    private var dealingView: some View {
        VStack {
            Text("Dealing cards...")
                .font(.customTitle)
                .foregroundColor(.white)
        }
    }
    
    // MARK: - Showing Pairs View
    private var showingPairsView: some View {
        VStack {
            Text("Found pairs!")
                .font(.customTitle)
                .foregroundColor(.white)
        }
        .onAppear {
            // Автоматично переходимо до скидання через 2 секунди
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                gameManager.startRemovingPairs()
            }
        }
    }
    
    // MARK: - Removing Pairs View
    private var removingPairsView: some View {
        VStack {
            Text("Removing pairs...")
                .font(.customTitle)
                .foregroundColor(.white)
        }
        .onAppear {
            // Анімація скидання пар
            animateRemovingPairs()
        }
    }
    
    // MARK: - In Progress View
    private var inProgressView: some View {
        VStack(spacing: 5) {
            // Індикатор стану по центру
            Text(gameManager.currentPlayer?.isHuman == true ? "Your turn" : "Bot's turn")
                .font(.customTitle2)
                .foregroundColor(.white)
            
            // Кнопка взяття карти (тільки для гравця)
            if gameManager.currentPlayer?.isHuman == true {
                Button(action: {
                    takeCardFromRandomOpponent()
                }) {
                    ZStack {
                        Image("button")
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width / 1.9, height: 50)
                            .ignoresSafeArea()

                        Text("Take Card")
                            .font(.customHeadline)
                            .foregroundColor(.white)
                    }
                    .padding()
                }
            }
        }
    }
    
    // MARK: - Finished View
    private var finishedView: some View {
        ZStack {
            // Напівпрозорий фон на весь екран
            Color.black.opacity(0.5)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .edgesIgnoringSafeArea(.all)
            
            // Попап
            VStack(spacing: 30) {
                // Текст результату
                Text(gameManager.winner != nil ? "You won!" : "You lost!")
                    .font(.customLargeTitle)
                    .foregroundColor(.white)
                
                // Кнопка "Back to Menu"
                Button(action: {
                    dismiss()
                }) {
                    ZStack {
                        Image("button")
                            .resizable()
                            .scaledToFit()
                            .frame(width: UIScreen.main.bounds.width / 1.9, height: 50)
                        
                        Text("Back to Menu")
                            .font(.customHeadline)
                            .foregroundColor(.white)
                    }
                    .padding()
                }
            }
            .padding(50)
            .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(hex: "1C1C2C"),
                        Color(hex: "212135"),
                        Color(hex: "171726")
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(Color(hex: "A3702C"), lineWidth: 2)
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .edgesIgnoringSafeArea(.all)
    }
    
    // MARK: - Game Logic
    private func startGameSequence() {
        gameManager.startGame()
    }
    
    private func handleStateChange(_ state: GameManager.GameState) {
        switch state {
        case .dealing:
            // Анімація роздачі
            animateDealing()
        case .showingPairs:
            // Вже обробляється в showingPairsView
            break
        case .removingPairs:
            // Вже обробляється в removingPairsView
            break
        default:
            break
        }
    }
    
    private func animateDealing() {
        // Проста затримка перед початком гри (пари вже видалені)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Перевіряємо чи хтось не виграв одразу
            gameManager.checkForWinner()
            
            if gameManager.gameState != .finished {
                gameManager.gameState = .inProgress
                gameManager.currentPlayerIndex = 0
            }
        }
    }
    
    private func animateRemovingPairs() {
        // Затримка перед видаленням пар (для анімації)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            gameManager.removePairsAfterAnimation()
        }
    }
    
    // Допоміжна функція для перевірки чи карта в парі
    private func isCardInPair(_ card: PlayingCard, playerIndex: Int) -> Bool {
        guard let pairs = gameManager.foundPairs[playerIndex] else { return false }
        for pair in pairs {
            for pairCard in pair {
                if pairCard.rawValue == card.rawValue {
                    return true
                }
            }
        }
        return false
    }
    
    private func takeCardFromRandomOpponent() {
        // Знаходимо суперників
        let opponents = gameManager.players.enumerated()
            .filter { $0.offset != gameManager.currentPlayerIndex && $0.element.hasCards }
            .map { $0.offset }
        
        guard let randomOpponent = opponents.randomElement() else { return }
        
        // Беремо карту (але не додаємо до руки одразу)
        let takenCard = gameManager.takeCardFromOpponentWithoutAdding(opponentIndex: randomOpponent)
        
        guard let card = takenCard else { return }
        
        // Показуємо карту на столі над картами гравця
        withAnimation(.easeInOut(duration: 0.3)) {
            cardOnTable = card
            cardOnTableOwner = 0 // Карта гравця
        }
        
        // Після затримки додаємо карту до руки та перевіряємо пари
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Додаємо карту до руки
            gameManager.addCardToCurrentPlayer(card: card)
            
            // Перевіряємо пари
            gameManager.checkAndRemovePairsForCurrentPlayer()
            
            // Перевіряємо переможця
            gameManager.checkForWinner()
            
            // Прибираємо карту зі столу
            withAnimation(.easeOut(duration: 0.3)) {
                cardOnTable = nil
                cardOnTableOwner = nil
            }
            
            // Перехід до наступного гравця
            gameManager.nextTurn()
            
            // Якщо наступний гравець - бот, він робить хід
            if gameManager.currentPlayer?.isHuman == false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    botTakeCardFromPlayer()
                }
            }
        }
    }
    
    private func botTakeCardFromPlayer() {
        // Перевіряємо чи гра не закінчилась
        guard gameManager.gameState != .finished else { return }
        
        // Знаходимо суперників
        let opponents = gameManager.players.enumerated()
            .filter { $0.offset != gameManager.currentPlayerIndex && $0.element.hasCards }
            .map { $0.offset }
        
        guard let randomOpponent = opponents.randomElement() else {
            gameManager.checkForWinner()
            return
        }
        
        // Беремо карту (але не додаємо до руки одразу)
        let takenCard = gameManager.takeCardFromOpponentWithoutAdding(opponentIndex: randomOpponent)
        
        guard let card = takenCard else {
            gameManager.checkForWinner()
            return
        }
        
        // Показуємо карту на столі над картами бота
        withAnimation(.easeInOut(duration: 0.3)) {
            cardOnTable = card
            cardOnTableOwner = 1 // Карта бота
        }
        
        // Після затримки додаємо карту до руки та перевіряємо пари
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Перевіряємо чи гра не закінчилась
            guard self.gameManager.gameState != .finished else { return }
            
            // Додаємо карту до руки
            self.gameManager.addCardToCurrentPlayer(card: card)
            
            // Перевіряємо пари
            self.gameManager.checkAndRemovePairsForCurrentPlayer()
            
            // Перевіряємо переможця
            self.gameManager.checkForWinner()
            
            // Якщо гра закінчилась, не продовжуємо
            guard self.gameManager.gameState != .finished else {
                // Прибираємо карту зі столу
                withAnimation(.easeOut(duration: 0.3)) {
                    self.cardOnTable = nil
                    self.cardOnTableOwner = nil
                }
                return
            }
            
            // Прибираємо карту зі столу
            withAnimation(.easeOut(duration: 0.3)) {
                self.cardOnTable = nil
                self.cardOnTableOwner = nil
            }
            
            // Перехід до наступного гравця
            self.gameManager.nextTurn()
            
            // Якщо наступний гравець знову бот, він робить хід
            if self.gameManager.currentPlayer?.isHuman == false {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.botTakeCardFromPlayer()
                }
            }
        }
    }
}

#Preview {
    GameView(numberOfPlayers: 2)
}

// MARK: - Cards Grid View
struct CardsGridView: View {
    let cards: [PlayingCard]
    let isFaceUp: Bool
    let foundPairs: [[PlayingCard]]
    let playerIndex: Int
    let cardBack: CardBack
    
    private let columns = 7
    private let spacing: CGFloat = 8
    private let horizontalPadding: CGFloat = 20
    
    private var cardWidth: CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        let availableWidth = screenWidth - (horizontalPadding * 2) - (spacing * CGFloat(columns - 1))
        return availableWidth / CGFloat(columns)
    }
    
    private var cardHeight: CGFloat {
        return cardWidth * 1.4 // Співвідношення висоти до ширини карти (84/60 ≈ 1.4)
    }
    
    private var gridHeight: CGFloat {
        let rows = ceil(Double(cards.count) / Double(columns))
        let totalSpacing = spacing * CGFloat(rows - 1)
        return (cardHeight * CGFloat(rows)) + totalSpacing
    }
    
    var body: some View {
        VStack(spacing: 0) {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns), spacing: spacing) {
                ForEach(cards, id: \.rawValue) { card in
                    CardView(
                        card: isFaceUp ? card : nil,
                        isFaceUp: isFaceUp,
                        isHighlighted: isCardInPair(card),
                        cardBack: cardBack
                    )
                    .frame(width: cardWidth, height: cardHeight)
                }
            }
            .padding(.horizontal, horizontalPadding)
        }
        .frame(height: gridHeight)
    }
    
    private func isCardInPair(_ card: PlayingCard) -> Bool {
        for pair in foundPairs {
            for pairCard in pair {
                if pairCard.rawValue == card.rawValue {
                    return true
                }
            }
        }
        return false
    }
}
