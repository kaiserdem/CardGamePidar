import Foundation

enum CardBack: String, CaseIterable {
    case vector0 = "Vector-0"
    case vector1 = "Vector-1"
    case vector2 = "Vector-2"
    case vector3 = "Vector-3"
    case vector4 = "Vector-4"
    
    // Дефолтний скін (Vector-0)
    static let `default`: CardBack = .vector0
    
    // Назва зображення для використання в UI
    var imageName: String {
        return self.rawValue
    }
    
    // Красива назва скіна
    var displayName: String {
        switch self {
        case .vector0: return "Classic"
        case .vector1: return "Royal"
        case .vector2: return "Mystic"
        case .vector3: return "Golden"
        case .vector4: return "Elite"
        }
    }
    
    // Короткий опис скіна
    var description: String {
        switch self {
        case .vector0: return "The timeless classic design for true card game enthusiasts."
        case .vector1: return "Elegant royal pattern that exudes sophistication and luxury."
        case .vector2: return "Mysterious and enchanting design with mystical elements."
        case .vector3: return "Prestigious golden finish that shines with every game."
        case .vector4: return "Elite design reserved for the most skilled players."
        }
    }
}
