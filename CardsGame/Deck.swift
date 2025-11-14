import Foundation

struct Deck {
    private var cards: [PlayingCard]
    
    init() {
        // Створюємо повну колоду з 52 карт
        self.cards = PlayingCard.allCases
    }
    
    // Перемішування колоди
    mutating func shuffle() {
        cards.shuffle()
    }
    
    // Роздача карт гравцям
    mutating func dealCards(numberOfPlayers: Int) -> [[PlayingCard]] {
        let cardsPerPlayer: Int
        switch numberOfPlayers {
        case 2:
            cardsPerPlayer = 26
        case 4:
            cardsPerPlayer = 13
        default:
            cardsPerPlayer = 52 / numberOfPlayers
        }
        
        var hands: [[PlayingCard]] = []
        
        for i in 0..<numberOfPlayers {
            let startIndex = i * cardsPerPlayer
            let endIndex = startIndex + cardsPerPlayer
            let playerHand = Array(cards[startIndex..<endIndex])
            hands.append(playerHand)
        }
        
        return hands
    }
}

