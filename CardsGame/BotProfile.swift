import Foundation
import Combine

/// Профіль бота-гравця
struct BotProfile: Identifiable {
    let id: UUID
    let avatar: PlayerAvatar
    let name: String
    var rating: Int // Дефолтний рейтинг
    let moneyMultiplier: Double // Коефіцієнт грошей (наприклад, 1.0, 1.5, 2.0)
    let country: String
    let city: String
    let description: String
    let price: Int // Ціна для розблокування (0 = безкоштовний)
    
    init(id: UUID = UUID(), avatar: PlayerAvatar, name: String, rating: Int = 1000, moneyMultiplier: Double = 1.0, country: String, city: String, description: String, price: Int = 0) {
        self.id = id
        self.avatar = avatar
        self.name = name
        self.rating = rating
        self.moneyMultiplier = moneyMultiplier
        self.country = country
        self.city = city
        self.description = description
        self.price = price
    }
}

/// Менеджер профілів ботів
class BotProfileManager: ObservableObject {
    static let shared = BotProfileManager()
    
    @Published var unlockedBots: Set<UUID> = []
    
    private let unlockedBotsKey = "unlockedBots"
    
    private init() {
        loadUnlockedBots()
    }
    
    /// Всі доступні боти (з фіксованими ID для збереження)
    static var allBots: [BotProfile] {
        return [
            // Перший бот - безкоштовний
            BotProfile(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!,
                avatar: .player2,
                name: "Alex",
                rating: 1000,
                moneyMultiplier: 1.0,
                country: "Ukraine",
                city: "Kyiv",
                description: "Beginner player, friendly and calm. Perfect for learning the game.",
                price: 0
            ),
            BotProfile(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000002")!,
                avatar: .player3,
                name: "Maria",
                rating: 1200,
                moneyMultiplier: 1.2,
                country: "Poland",
                city: "Warsaw",
                description: "Experienced player with strategic thinking. Moderate difficulty.",
                price: 10
            ),
            BotProfile(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000003")!,
                avatar: .player4,
                name: "James",
                rating: 1400,
                moneyMultiplier: 1.5,
                country: "USA",
                city: "New York",
                description: "Skilled player known for aggressive playstyle. High rewards.",
                price: 12
            ),
            BotProfile(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000004")!,
                avatar: .player5,
                name: "Sophie",
                rating: 1600,
                moneyMultiplier: 1.8,
                country: "France",
                city: "Paris",
                description: "Expert player with years of experience. Very challenging.",
                price: 15
            ),
            BotProfile(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000005")!,
                avatar: .player6,
                name: "Hiroshi",
                rating: 1800,
                moneyMultiplier: 2.0,
                country: "Japan",
                city: "Tokyo",
                description: "Master player with incredible skills. Maximum rewards.",
                price: 18
            ),
            BotProfile(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000006")!,
                avatar: .player7,
                name: "Emma",
                rating: 1500,
                moneyMultiplier: 1.6,
                country: "Germany",
                city: "Berlin",
                description: "Professional player with tactical approach. High difficulty.",
                price: 21
            ),
            BotProfile(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000007")!,
                avatar: .player8,
                name: "Carlos",
                rating: 1700,
                moneyMultiplier: 1.9,
                country: "Spain",
                city: "Madrid",
                description: "Elite player with unpredictable moves. Extreme challenge.",
                price: 25
            ),
            BotProfile(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000008")!,
                avatar: .player1,
                name: "Luna",
                rating: 2000,
                moneyMultiplier: 2.5,
                country: "Canada",
                city: "Toronto",
                description: "Legendary player, almost unbeatable. Ultimate challenge with highest rewards.",
                price: 30
            )
        ]
    }
    
    /// Перевірити чи бот розблокований
    func isBotUnlocked(_ bot: BotProfile) -> Bool {
        return bot.price == 0 || unlockedBots.contains(bot.id)
    }
    
    /// Розблокувати бота
    func unlockBot(_ bot: BotProfile) -> Bool {
        guard !isBotUnlocked(bot) else { return true }
        
        unlockedBots.insert(bot.id)
        saveUnlockedBots()
        return true
    }
    
    /// Перевірити чи достатньо монет для покупки
    func canAffordBot(_ bot: BotProfile, shopManager: ShopManager) -> Bool {
        return shopManager.coins >= bot.price
    }
    
    /// Зберегти розблокованих ботів
    private func saveUnlockedBots() {
        let ids = unlockedBots.map { $0.uuidString }
        UserDefaults.standard.set(ids, forKey: unlockedBotsKey)
    }
    
    /// Завантажити розблокованих ботів
    private func loadUnlockedBots() {
        if let ids = UserDefaults.standard.array(forKey: unlockedBotsKey) as? [String] {
            unlockedBots = Set(ids.compactMap { UUID(uuidString: $0) })
        }
        
        // Перший бот завжди розблокований
        if let firstBot = BotProfileManager.allBots.first {
            unlockedBots.insert(firstBot.id)
        }
    }
    
    /// Отримати бота за ID
    static func getBot(by id: UUID) -> BotProfile? {
        return allBots.first { $0.id == id }
    }
    
    /// Отримати бота за номером аватара
    static func getBot(by playerNumber: Int) -> BotProfile? {
        return allBots.first { $0.avatar.playerNumber == playerNumber }
    }
}

