import Foundation

enum PlayingCard: String, CaseIterable {
    
    // ♠ Spades
    case twoSpades = "2Spades"
    case threeSpades = "3Spades"
    case fourSpades = "4Spades"
    case fiveSpades = "5Spades"
    case sixSpades = "6Spades"
    case sevenSpades = "7Spades"
    case eightSpades = "8Spades"
    case nineSpades = "9Spades"
    case tenSpades = "10Spades"
    case jackSpades = "JackSpades"
    case queenSpades = "QueenSpades"
    case kingSpades = "KingSpades"
    case aceSpades = "AceSpades"
    
    // ♥ Hearts
    case twoHearts = "2Hearts"
    case threeHearts = "3Hearts"
    case fourHearts = "4Hearts"
    case fiveHearts = "5Hearts"
    case sixHearts = "6Hearts"
    case sevenHearts = "7Hearts"
    case eightHearts = "8Hearts"
    case nineHearts = "9Hearts"
    case tenHearts = "10Hearts"
    case jackHearts = "JackHearts"
    case queenHearts = "QueenHearts"
    case kingHearts = "KingHearts"
    case aceHearts = "AceHearts"
    
    // ♦ Diamonds
    case twoDiamonds = "2Diamonds"
    case threeDiamonds = "3Diamonds"
    case fourDiamonds = "4Diamonds"
    case fiveDiamonds = "5Diamonds"
    case sixDiamonds = "6Diamonds"
    case sevenDiamonds = "7Diamonds"
    case eightDiamonds = "8Diamonds"
    case nineDiamonds = "9Diamonds"
    case tenDiamonds = "10Diamonds"
    case jackDiamonds = "JackDiamonds"
    case queenDiamonds = "QueenDiamonds"
    case kingDiamonds = "KingDiamonds"
    case aceDiamonds = "AceDiamonds"
    
    // ♣ Clubs
    case twoClubs = "2Clubs"
    case threeClubs = "3Clubs"
    case fourClubs = "4Clubs"
    case fiveClubs = "5Clubs"
    case sixClubs = "6Clubs"
    case sevenClubs = "7Clubs"
    case eightClubs = "8Clubs"
    case nineClubs = "9Clubs"
    case tenClubs = "10Clubs"
    case jackClubs = "JackClubs"
    case queenClubs = "QueenClubs"
    case kingClubs = "KingClubs"
    case aceClubs = "AceClubs"
    
    // MARK: - Computed Properties
    
    var suit: String {
        switch self {
        case .twoSpades, .threeSpades, .fourSpades, .fiveSpades, .sixSpades,
             .sevenSpades, .eightSpades, .nineSpades, .tenSpades,
             .jackSpades, .queenSpades, .kingSpades, .aceSpades:
            return "Spades"
        case .twoHearts, .threeHearts, .fourHearts, .fiveHearts, .sixHearts,
             .sevenHearts, .eightHearts, .nineHearts, .tenHearts,
             .jackHearts, .queenHearts, .kingHearts, .aceHearts:
            return "Hearts"
        case .twoDiamonds, .threeDiamonds, .fourDiamonds, .fiveDiamonds, .sixDiamonds,
             .sevenDiamonds, .eightDiamonds, .nineDiamonds, .tenDiamonds,
             .jackDiamonds, .queenDiamonds, .kingDiamonds, .aceDiamonds:
            return "Diamonds"
        case .twoClubs, .threeClubs, .fourClubs, .fiveClubs, .sixClubs,
             .sevenClubs, .eightClubs, .nineClubs, .tenClubs,
             .jackClubs, .queenClubs, .kingClubs, .aceClubs:
            return "Clubs"
        }
    }
    
    var imageName: String {
        return self.rawValue
    }
    
    var fullName: String {
        let rankName: String
        switch self.rawValue.prefix { $0.isLetter == false } {
        case "2": rankName = "2"
        case "3": rankName = "3"
        case "4": rankName = "4"
        case "5": rankName = "5"
        case "6": rankName = "6"
        case "7": rankName = "7"
        case "8": rankName = "8"
        case "9": rankName = "9"
        case "10": rankName = "10"
        case "Jack": rankName = "Jack"
        case "Queen": rankName = "Queen"
        case "King": rankName = "King"
        case "Ace": rankName = "Ace"
        default: rankName = ""
        }
        return "\(rankName) of \(suit)"
    }
}

/*
 
 let card = PlayingCard.queenDiamonds
 print(card.imageName) // "QueenDiamonds"
 print(card.fullName)  // "Queen of Diamonds"
 print(card.suit)      // "Diamonds"
 
 */

/*
 🧩 1. Концепція гри
 Гра "Пі́дара" — проста карткова гра для 2–4 гравців (на старті можна зробити 1 проти бота).
 Мета — позбутись усіх карт.
 Хто залишився з останньою картою — програв (стає “підаром”).
 🎮 2. Основна механіка гри
 Початок:
 Колода (52 карти) перемішується.
 Кожен гравець отримує однакову кількість карт (для 2 гравців — по 26).
 Всі пари однакових рангів (наприклад, дві 7ки) автоматично скидаються.
 Хід гри:
 Гравець вибирає одну випадкову карту з руки суперника.
 Якщо утворилась пара — обидві карти скидаються.
 Якщо ні — карта залишається у руці.
 Хід переходить до іншого гравця.
 Завершення гри:
 Коли у когось не залишилось карт → він виграв.
 Гра триває, поки не залишиться один із картою.
 Цей гравець програє (стає “підаром”).
 🧠 3. Основна логіка
 Структури даних:
 Deck: створює, перемішує та роздає карти.
 Player: має id, hand: [PlayingCard].
 GameManager: керує станом гри:
 список гравців
 активний гравець
 логіка взяття карти, перевірки пар
 визначення переможця
 🖥️ 4. Інтерфейс (SwiftUI)
 Головні екрани:
 MainMenuView
 Кнопка “Почати гру”
 (опціонально) налаштування: кількість гравців, звук, фон
 GameView
 Показує карти гравця (горизонтально)
 Показує карти суперника (фейсдаун)
 Кнопка “Взяти карту”
 Візуальні ефекти: анімація перемішування, скидання пар
 EndGameView
 Текст: “Ти виграв!” або “Ти підар 😅”
 Кнопка “Почати знову”
 ⚙️ 5. Механіка для 2 гравців (MVP)
 Сценарій:
 Старт → колода роздається.
 Автоматично скидаються всі пари.
 Гравець бачить свої карти.
 Кнопка “Взяти карту у бота” → бот віддає випадкову карту.
 Якщо пара — карти видаляються.
 Потім бот бере карту у гравця.
 Повторюється цикл.
 Як тільки один гравець без карт → перемога.
 🧱 6. План розробки (поетапно)
 🔹 Етап 1. Модель гри (Foundation)
 ✅ Enum PlayingCard (вже є)
 🔹 Створити struct Player
 🔹 Створити struct Deck (створення + перемішування + роздача)
 🔹 Створити class GameManager (основна логіка: скидання пар, вибір карти, хід)
 🔹 Етап 2. UI та ViewModel
 🔹 GameView з двома гравцями (Player і Bot)
 🔹 Кнопки “Взяти карту”, “Завершити хід”
 🔹 Відображення карт гравця (зображення)
 🔹 Простий індикатор стану (текст: “твій хід”, “хід бота”)
 🔹 Етап 3. Анімації та UX
 🔹 Анімація карт при скиданні
 🔹 Анімація при доборі карти
 🔹 Фон, звуки (опціонально)
 🔹 Етап 4. Завершення гри
 🔹 Екран перемоги/поразки
 🔹 Кнопка “Грати знову”
 🔹 Етап 5. (опціонально)
 🔹 Додати 3–4 гравців
 🔹 Онлайн або локальний мультиплеєр
 🔹 Таблицю результатів
 */
