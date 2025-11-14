
import SwiftUI

struct MainMenuView: View {
    @State private var showGameView = false
    @State private var showTutorialView = false
    @State private var numberOfPlayers = 2
    
    var body: some View {
        ZStack {
            // Фон
            Image("bg4")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                MenuButton(title: "Play with 2 Players") {
                    numberOfPlayers = 2
                    showGameView = true
                }
                .padding(.bottom, 20)
                
                MenuButton(title: "Play with 4 Players") {
                    numberOfPlayers = 4
                    showGameView = true
                }
                .padding(.bottom, 20)
                
                MenuButton(title: "Tutorial") {
                    showTutorialView = true
                }
                .padding(.bottom, 20)
                
                MenuButton(title: "Shop") {
                    print("Shop")
                }
                .padding(.bottom, 50)
                
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 60)
        }
        .fullScreenCover(isPresented: $showGameView) {
            GameView(numberOfPlayers: numberOfPlayers)
        }
        .fullScreenCover(isPresented: $showTutorialView) {
            TutorialView()
        }
    }
}

struct MenuButton: View {
    let title: String
    let action: () -> Void
    
    // Колір рамки
    private let borderColor = Color(hex: "A3702C")
    
    var body: some View {
        Button(action: action) {
            ZStack {
                // Фон кнопки
                Image("button")
                    .resizable()
                    .scaledToFill()
                
                // Текст на кнопці
                Text(title)
                    .font(.customBold(size: 24))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: 50)
    }
}

// Розширення для Color з hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    MainMenuView()
}

