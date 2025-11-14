import Foundation
import Combine

struct BotStatistics: Codable {
    var totalGames: Int = 0
    var wins: Int = 0
    var losses: Int = 0
    
    var winRate: Double {
        guard totalGames > 0 else { return 0.0 }
        return Double(wins) / Double(totalGames) * 100.0
    }
}

class StatisticsManager: ObservableObject {
    static let shared = StatisticsManager()
    
    @Published var statistics: [UUID: BotStatistics] = [:]
    
    private let statisticsKey = "BotStatistics"
    
    private init() {
        loadStatistics()
    }
    
    // Завантажити статистику з UserDefaults
    private func loadStatistics() {
        if let data = UserDefaults.standard.data(forKey: statisticsKey),
           let decoded = try? JSONDecoder().decode([String: BotStatistics].self, from: data) {
            // Конвертуємо String ключі в UUID
            statistics = decoded.reduce(into: [UUID: BotStatistics]()) { result, pair in
                if let uuid = UUID(uuidString: pair.key) {
                    result[uuid] = pair.value
                }
            }
        }
    }
    
    // Зберегти статистику в UserDefaults
    private func saveStatistics() {
        // Конвертуємо UUID ключі в String для JSON
        let stringKeyed = statistics.reduce(into: [String: BotStatistics]()) { result, pair in
            result[pair.key.uuidString] = pair.value
        }
        
        if let encoded = try? JSONEncoder().encode(stringKeyed) {
            UserDefaults.standard.set(encoded, forKey: statisticsKey)
        }
    }
    
    // Отримати статистику для бота
    func getStatistics(for botId: UUID) -> BotStatistics {
        return statistics[botId] ?? BotStatistics()
    }
    
    // Додати результат гри
    func recordGame(botId: UUID, didWin: Bool) {
        var stats = statistics[botId] ?? BotStatistics()
        stats.totalGames += 1
        
        if didWin {
            stats.wins += 1
        } else {
            stats.losses += 1
        }
        
        statistics[botId] = stats
        saveStatistics()
    }
    
    // Скинути всю статистику
    func resetStatistics() {
        statistics = [:]
        saveStatistics()
    }
}

