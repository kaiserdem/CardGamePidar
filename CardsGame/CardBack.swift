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
}
