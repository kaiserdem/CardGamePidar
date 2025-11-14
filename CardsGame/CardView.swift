import SwiftUI

struct CardView: View {
    let card: PlayingCard?
    let isFaceUp: Bool
    let isHighlighted: Bool // Для виділення пар
    let cardBack: CardBack
    
    init(card: PlayingCard?, isFaceUp: Bool, isHighlighted: Bool = false, cardBack: CardBack = .default) {
        self.card = card
        self.isFaceUp = isFaceUp
        self.isHighlighted = isHighlighted
        self.cardBack = cardBack
    }
    
    var body: some View {
        ZStack {
            if let card = card, isFaceUp {
                // Відкрита карта
                Image(card.imageName)
                    .resizable()
                    .scaledToFit()
            } else {
                // Закрита карта (зворотня сторона)
                Image(cardBack.imageName)
                    .resizable()
                    .scaledToFit()
            }
        }
        .aspectRatio(60/84, contentMode: .fit) // Зберігаємо пропорції карти
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .stroke(isHighlighted ? Color.yellow : Color.clear, lineWidth: 3)
        )
        .opacity(isHighlighted ? 0.8 : 1.0)
    }
}

#Preview {
    HStack {
        CardView(card: .aceSpades, isFaceUp: true)
        CardView(card: nil, isFaceUp: false)
        CardView(card: .kingHearts, isFaceUp: true, isHighlighted: true)
    }
}

