import Foundation

enum PlayerAvatar: String, CaseIterable {
    // Квадратні зображення
    case player1 = "Player1"
    case player2 = "Player2"
    case player3 = "Player3"
    case player4 = "Player4"
    case player5 = "Player5"
    case player6 = "Player6"
    case player7 = "Player7"
    case player8 = "Player8"
    
    // Заокруглені зображення
    case player1c = "Player1c"
    case player2c = "Player2c"
    case player3c = "Player3c"
    case player4c = "Player4c"
    case player5c = "Player5c"
    case player6c = "Player6c"
    case player7c = "Player7c"
    case player8c = "Player8c"
    
    // Назва зображення для використання в UI
    var imageName: String {
        return self.rawValue
    }
    
    // Отримати квадратну версію
    var squareVersion: PlayerAvatar {
        switch self {
        case .player1, .player1c: return .player1
        case .player2, .player2c: return .player2
        case .player3, .player3c: return .player3
        case .player4, .player4c: return .player4
        case .player5, .player5c: return .player5
        case .player6, .player6c: return .player6
        case .player7, .player7c: return .player7
        case .player8, .player8c: return .player8
        }
    }
    
    // Отримати заокруглену версію
    var roundedVersion: PlayerAvatar {
        switch self {
        case .player1, .player1c: return .player1c
        case .player2, .player2c: return .player2c
        case .player3, .player3c: return .player3c
        case .player4, .player4c: return .player4c
        case .player5, .player5c: return .player5c
        case .player6, .player6c: return .player6c
        case .player7, .player7c: return .player7c
        case .player8, .player8c: return .player8c
        }
    }
    
    // Отримати номер гравця (1-8)
    var playerNumber: Int {
        switch self {
        case .player1, .player1c: return 1
        case .player2, .player2c: return 2
        case .player3, .player3c: return 3
        case .player4, .player4c: return 4
        case .player5, .player5c: return 5
        case .player6, .player6c: return 6
        case .player7, .player7c: return 7
        case .player8, .player8c: return 8
        }
    }
}

