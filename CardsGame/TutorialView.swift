import SwiftUI

struct TutorialView: View {
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
                    .frame(height: 80)
                
                // Основний фон
                Image("bg5")
                    .resizable()
                    .scaledToFill()
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Верхня частина: кнопка назад
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image("back")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                    }
                    Spacer()
                    
                    Text("Tutorial")
                        .font(.customTitle)
                        .foregroundColor(.white)
                        .offset(x: 20)
                    Spacer()
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 100)
                               
                
                Spacer()
                
                // Текст з правилами
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        rulesSection
                    }
                    .padding(.horizontal, 30)
                    .padding(.top, 20)
                    .padding(.bottom, 100) // Відступ знизу для прокрутки
                }
                
                Spacer()
            }
        }
    }
    
    private var rulesSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Мета гри
            VStack(alignment: .leading, spacing: 10) {
                Text("Goal of the Game")
                    .font(.customBold(size: 22))
                    .foregroundColor(.white)
                
                Text("The goal is to get rid of all your cards. The player who is left with the last card loses (becomes the \"loser\").")
                    .font(.customRegular(size: 19))
                    .foregroundColor(.white)
            }
            
            // Початок гри
            VStack(alignment: .leading, spacing: 10) {
                Text("Game Start")
                    .font(.customBold(size: 22))
                    .foregroundColor(.white)
                
                Text("• A deck of 52 cards is shuffled")
                    .font(.customRegular(size: 19))
                    .foregroundColor(.white)
                
                Text("• Each player receives an equal number of cards (26 cards for 2 players, 13 cards for 4 players)")
                    .font(.customRegular(size: 19))
                    .foregroundColor(.white)
                
                Text("• All pairs of the same rank (for example, two 7s) are automatically discarded")
                    .font(.customRegular(size: 19))
                    .foregroundColor(.white)
            }
            
            // Хід гри
            VStack(alignment: .leading, spacing: 10) {
                Text("Gameplay")
                    .font(.customBold(size: 22))
                    .foregroundColor(.white)
                
                Text("• On your turn, tap \"Take Card\" to take a random card from your opponent")
                    .font(.customRegular(size: 19))
                    .foregroundColor(.white)
                
                Text("• If a pair is formed (two cards of the same rank), both cards are automatically discarded")
                    .font(.customRegular(size: 19))
                    .foregroundColor(.white)
                
                Text("• If no pair is formed, the card remains in your hand")
                    .font(.customRegular(size: 19))
                    .foregroundColor(.white)
                
                Text("• The turn passes to the next player")
                    .font(.customRegular(size: 19))
                    .foregroundColor(.white)
            }
            
            // Завершення гри
            VStack(alignment: .leading, spacing: 10) {
                Text("Game End")
                    .font(.customBold(size: 22))
                    .foregroundColor(.white)
                
                Text("• When someone has no cards left, they win!")
                    .font(.customRegular(size: 19))
                    .foregroundColor(.white)
                
                Text("• The game continues until only one player has cards left")
                    .font(.customRegular(size: 19))
                    .foregroundColor(.white)
                
                Text("• That player loses (becomes the \"loser\")")
                    .font(.customRegular(size: 19))
                    .foregroundColor(.white)
            }
            
            // Поради
            VStack(alignment: .leading, spacing: 10) {
                Text("Tips")
                    .font(.customBold(size: 22))
                    .foregroundColor(.white)
                
                Text("• Pay attention to which cards you have - this will help you form pairs")
                    .font(.customRegular(size: 19))
                    .foregroundColor(.white)
                
                Text("• Try to remember which cards your opponent might have")
                    .font(.customRegular(size: 19))
                    .foregroundColor(.white)
                
                Text("• The game is based on luck, but strategy also matters!")
                    .font(.customRegular(size: 19))
                    .foregroundColor(.white)
            }
        }
    }
}

#Preview {
    TutorialView()
}

