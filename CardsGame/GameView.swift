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
                    .frame(height: 100)
                
                // Основний фон
                Image("bg1")
                    .resizable()
                    .scaledToFill()
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Верхня частина: кнопка назад та аватар користувача
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
                    
                    // Аватар користувача зверху
                    if !gameManager.players.isEmpty, gameManager.players[0].isHuman {
                        Image(PlayerAvatar.allCases.first { $0.playerNumber == 1 }?.imageName ?? "Player1")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 60, height: 60)
                            .padding(.trailing, 20)
                            .padding(.top, 100)
                    }
                }
                
                Spacer()
                
                // Контент гри (карти суперника в центрі)
                gameContent
                
                Spacer()
                
                // Нижня частина: карти користувача
                if !gameManager.players.isEmpty, gameManager.players[0].isHuman {
                    VStack(spacing: 8) {
                        // Карти користувача
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(gameManager.players[0].hand, id: \.rawValue) { card in
                                    CardView(
                                        card: card,
                                        isFaceUp: true,
                                        isHighlighted: isCardInPair(card, playerIndex: 0),
                                        cardBack: .default
                                    )
                                }
                            }
                            .padding(.horizontal, 10)
                        }
                        .frame(height: 100)
                        
                        // Кількість карт
                        Text("\(gameManager.players[0].cardCount) cards")
                            .font(.customCaption)
                            .foregroundColor(.white)
                            .padding(.bottom, 20)
                    }
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
        VStack(spacing: 20) {
            Text("Dealing cards...")
                .font(.customTitle)
                .foregroundColor(.white)
            
            if numberOfPlayers == 2 {
                // Бот зверху (тільки карти, без аватара тут)
                if gameManager.players.count > 1 {
                    VStack(spacing: 8) {
                        // Аватар бота
                        Image(PlayerAvatar.allCases.first { $0.playerNumber == 2 }?.imageName ?? "Player2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                        
                        // Карти бота
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(gameManager.players[1].hand, id: \.rawValue) { card in
                                    CardView(
                                        card: card,
                                        isFaceUp: false,
                                        cardBack: .default
                                    )
                                }
                            }
                            .padding(.horizontal, 10)
                        }
                        
                        Text("\(gameManager.players[1].cardCount) cards")
                            .font(.customCaption)
                            .foregroundColor(.white)
                    }
                }
            } else {
                // Для 4 гравців (пізніше)
                Text("4 players layout")
                    .foregroundColor(.white)
            }
        }
    }
    
    // MARK: - Showing Pairs View
    private var showingPairsView: some View {
        VStack(spacing: 20) {
            Text("Found pairs!")
                .font(.customTitle)
                .foregroundColor(.white)
            
            if numberOfPlayers == 2 {
                // Бот зверху (показуємо карти для візуалізації пар)
                if gameManager.players.count > 1 {
                    VStack(spacing: 8) {
                        // Аватар бота
                        Image(PlayerAvatar.allCases.first { $0.playerNumber == 2 }?.imageName ?? "Player2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                        
                        // Карти бота з підсвіткою пар
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(gameManager.players[1].hand, id: \.rawValue) { card in
                                    CardView(
                                        card: card,
                                        isFaceUp: true,
                                        isHighlighted: isCardInPair(card, playerIndex: 1),
                                        cardBack: .default
                                    )
                                }
                            }
                            .padding(.horizontal, 10)
                        }
                        
                        Text("\(gameManager.players[1].cardCount) cards")
                            .font(.customCaption)
                            .foregroundColor(.white)
                    }
                }
            }
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
        VStack(spacing: 20) {
            Text("Removing pairs...")
                .font(.customTitle)
                .foregroundColor(.white)
            
            if numberOfPlayers == 2 {
                // Бот зверху
                if gameManager.players.count > 1 {
                    VStack(spacing: 8) {
                        // Аватар бота
                        Image(PlayerAvatar.allCases.first { $0.playerNumber == 2 }?.imageName ?? "Player2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                        
                        // Карти бота з підсвіткою пар
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(gameManager.players[1].hand, id: \.rawValue) { card in
                                    CardView(
                                        card: card,
                                        isFaceUp: true,
                                        isHighlighted: isCardInPair(card, playerIndex: 1),
                                        cardBack: .default
                                    )
                                }
                            }
                            .padding(.horizontal, 10)
                        }
                        
                        Text("\(gameManager.players[1].cardCount) cards")
                            .font(.customCaption)
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .onAppear {
            // Анімація скидання пар
            animateRemovingPairs()
        }
    }
    
    // MARK: - In Progress View
    private var inProgressView: some View {
        VStack(spacing: 20) {
            // Індикатор стану
            Text(gameManager.currentPlayer?.isHuman == true ? "Your turn" : "Bot's turn")
                .font(.customTitle2)
                .foregroundColor(.white)
            
            if numberOfPlayers == 2 {
                // Бот зверху (закриті карти)
                if gameManager.players.count > 1 {
                    VStack(spacing: 8) {
                        // Аватар бота
                        Image(PlayerAvatar.allCases.first { $0.playerNumber == 2 }?.imageName ?? "Player2")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                        
                        // Карти бота (закриті)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(gameManager.players[1].hand, id: \.rawValue) { _ in
                                    CardView(
                                        card: nil,
                                        isFaceUp: false,
                                        cardBack: .default
                                    )
                                }
                            }
                            .padding(.horizontal, 10)
                        }
                        
                        Text("\(gameManager.players[1].cardCount) cards")
                            .font(.customCaption)
                            .foregroundColor(.white)
                    }
                }
                
                // Кнопка взяття карти
                if gameManager.currentPlayer?.isHuman == true {
                    Button(action: {
                        takeCardFromRandomOpponent()
                    }) {
                        Text("Take Card")
                            .font(.customTitle2)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
            }
        }
    }
    
    // MARK: - Finished View
    private var finishedView: some View {
        VStack(spacing: 20) {
            if let winner = gameManager.winner {
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
