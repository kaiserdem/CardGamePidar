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
        // Звук тасування
        SoundManager.shared.playShuffleSound()
    }
    
    // Роздача карт гравцям (збалансована роздача по черзі)
    mutating func dealCards(numberOfPlayers: Int) -> [[PlayingCard]] {
        var hands = Array(repeating: [PlayingCard](), count: numberOfPlayers)
        
        // Перемішуємо всю колоду (випадковий порядок карт)
        // Використовуємо метод shuffle() щоб відтворити звук
        self.shuffle()
        
        // Роздаємо по черзі кожну карту
        var currentPlayer = 0
        for card in cards {
            hands[currentPlayer].append(card)
            currentPlayer = (currentPlayer + 1) % numberOfPlayers
        }
        
        // Діагностика: скільки карт отримав кожен гравець
        print("\n=== ПІДСУМОК РОЗДАЧІ ===")
        for (index, hand) in hands.enumerated() {
            print("Гравець \(index + 1): \(hand.count) карт")
            print("  Всі карти: \(hand.map { $0.rawValue })")
        }
        
        return hands
    }
}

