import SwiftUI

struct GameView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var gameManager: GameManager
    @State private var dealtCards: [Int: [Bool]] = [:] // Трекінг розданих карт для анімації
    @State private var removingPairsDelay: Double = 0
    
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
                    .frame(height: 120)
                
                // Основний фон
                Image("bg1")
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
                    .padding(.top, 100)
                    
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
                
                // Карти бота (показуємо тільки під час гри)
                if gameManager.gameState == .inProgress, numberOfPlayers == 2, gameManager.players.count > 1 {
                    VStack(spacing: 8) {
                        // Карти бота (закриті) у сітці
                        CardsGridView(
                            cards: gameManager.players[1].hand,
                            isFaceUp: false,
                            foundPairs: gameManager.foundPairs[1] ?? [],
                            playerIndex: 1,
                            cardBack: .default
                        )
                    }
                    .padding(.top, 20)
                }
                
                Spacer()
                
                // Контент гри (текст стану по центру)
                gameContent
                
                Spacer()
                
               
                
                // Нижня частина: карти користувача
                if !gameManager.players.isEmpty, gameManager.players[0].isHuman {
                    VStack(spacing: 8) {
                        // Карти користувача у сітці
                        CardsGridView(
                            cards: gameManager.players[0].hand,
                            isFaceUp: true,
                            foundPairs: gameManager.foundPairs[0] ?? [],
                            playerIndex: 0,
                            cardBack: .default
                        )
                    }
                    .padding(.bottom, 150)
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
        VStack(spacing: 20) {
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
        VStack(spacing: 20) {
            if gameManager.winner != nil {
                Text("You won!")
                    .font(.customLargeTitle)
                    .foregroundColor(.green)
            } else {
                Text("You lost!")
                    .font(.customLargeTitle)
                    .foregroundColor(.red)
            }
            
            Button(action: {
                dismiss()
            }) {
                Text("Back to Menu")
                    .font(.customTitle2)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
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
        // Проста затримка перед пошуком пар
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            gameManager.findPairsInAllPlayers()
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
        
        _ = gameManager.takeCardFromOpponent(opponentIndex: randomOpponent)
        
        // Перехід до наступного гравця
        gameManager.nextTurn()
        
        // Якщо наступний гравець - бот, він робить хід
        if gameManager.currentPlayer?.isHuman == false {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                gameManager.botTurn()
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
