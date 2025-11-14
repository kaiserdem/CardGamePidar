import SwiftUI

struct GameView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // Чорний фон для верхньої частини
            Color.black
                .ignoresSafeArea()
            
            // Фон гри
            VStack(spacing: 0) {
                // Відступ зверху
                Color.black
                    .frame(height: 100)
                
                // Основний фон
                Image("bg1")
                    .resizable()
                    .scaledToFill()
            }
            .ignoresSafeArea()
            
            VStack {
                // Кастомна кнопка назад
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image("back")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                    .padding(.leading, 20)
                    .padding(.top, 100)
                    
                    Spacer()
                }
                
                Spacer()
            }
        }
    }
}
