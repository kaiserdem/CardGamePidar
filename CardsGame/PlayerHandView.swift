import SwiftUI

struct PlayerHandView: View {
    let player: Player
    let isFaceUp: Bool
    let foundPairs: [[PlayingCard]] // Пари для виділення
    let cardBack: CardBack
    let showAvatar: Bool
    let avatar: PlayerAvatar?
    
    init(player: Player, isFaceUp: Bool, foundPairs: [[PlayingCard]] = [], cardBack: CardBack = .default, showAvatar: Bool = false, avatar: PlayerAvatar? = nil) {
        self.player = player
        self.isFaceUp = isFaceUp
        self.foundPairs = foundPairs
        self.cardBack = cardBack
        self.showAvatar = showAvatar
        self.avatar = avatar
    }
    
    // Перевірка чи карта в парі
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
    
    var body: some View {
        VStack(spacing: 8) {
            // Аватар (якщо потрібно)
            if showAvatar, let avatar = avatar {
                Image(avatar.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
            }
            
            // Карти
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(player.hand, id: \.rawValue) { card in
                        CardView(
                            card: card,
                            isFaceUp: isFaceUp,
                            isHighlighted: isCardInPair(card),
                            cardBack: cardBack
                        )
                    }
                }
                .padding(.horizontal, 10)
            }
            
            // Кількість карт
            Text("\(player.cardCount) cards")
                .font(.customCaption)
                .foregroundColor(.white)
        }
    }
}

#Preview {
    let player = Player(hand: [.aceSpades, .aceHearts, .kingSpades, .kingHearts, .queenDiamonds], isHuman: true, playerNumber: 1)
    let pairs = [[PlayingCard.aceSpades, PlayingCard.aceHearts], [PlayingCard.kingSpades, PlayingCard.kingHearts]]
    
    return PlayerHandView(
        player: player,
        isFaceUp: true,
        foundPairs: pairs,
        showAvatar: true,
        avatar: .player1
    )
    .background(Color.blue)
}

