import Foundation

struct Player: Identifiable {
    let id: UUID
    var hand: [PlayingCard]
    let isHuman: Bool // true для гравця, false для бота
    let playerNumber: Int // номер гравця (1, 2, 3, 4)
    
    init(id: UUID = UUID(), hand: [PlayingCard] = [], isHuman: Bool = false, playerNumber: Int) {
        self.id = id
        self.hand = hand
        self.isHuman = isHuman
        self.playerNumber = playerNumber
    }
    
    // Перевірка чи у гравця є карти
    var hasCards: Bool {
        return !hand.isEmpty
    }
    
    // Кількість карт
    var cardCount: Int {
        return hand.count
    }
}

