import SwiftUI

struct StatisticsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var statisticsManager = StatisticsManager.shared
    
    var body: some View {
        ZStack {
            // Чорний фон для верхньої частини
            Color.black
                .ignoresSafeArea()
            
            // Фон
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
                // Верхня частина: кнопка назад та заголовок
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
                    
                    Text("Statistics")
                        .font(.customTitle)
                        .foregroundColor(.white)
                        .offset(x: 20)
                    Spacer()
                    
                    // Пустий простір для вирівнювання
                    Color.clear
                        .frame(width: 40, height: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 85)
                
                // Список ботів зі статистикою
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(BotProfileManager.allBots) { bot in
                            let stats = statisticsManager.getStatistics(for: bot.id)
                            
                            StatisticsCardView(
                                bot: bot,
                                statistics: stats
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
            }
        }
    }
}

struct StatisticsCardView: View {
    let bot: BotProfile
    let statistics: BotStatistics
    
    var body: some View {
        HStack(spacing: 15) {
            // Аватар
            Image(bot.avatar.roundedVersion.imageName)
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(Color(hex: "A3702C"), lineWidth: 2)
                )
            
            // Інформація
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(bot.name)
                        .font(.customBold(size: 20))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Рейтинг
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 14))
                        Text("\(bot.rating)")
                            .font(.customRegular(size: 16))
                            .foregroundColor(.white)
                    }
                }
                
                // Країна, місто
                Text("\(bot.city), \(bot.country)")
                    .font(.customRegular(size: 14))
                    .foregroundColor(.white.opacity(0.7))
                
                // Статистика
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("Games:")
                            .font(.customRegular(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Text("\(statistics.totalGames)")
                            .font(.customBold(size: 14))
                            .foregroundColor(.white)
                    }
                    
                    HStack {
                        Text("Wins:")
                            .font(.customRegular(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Text("\(statistics.wins)")
                            .font(.customBold(size: 14))
                            .foregroundColor(.green)
                    }
                    
                    HStack {
                        Text("Losses:")
                            .font(.customRegular(size: 14))
                            .foregroundColor(.white.opacity(0.8))
                        Spacer()
                        Text("\(statistics.losses)")
                            .font(.customBold(size: 14))
                            .foregroundColor(.red)
                    }
                    
                    if statistics.totalGames > 0 {
                        HStack {
                            Text("Win Rate:")
                                .font(.customRegular(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                            Spacer()
                            Text("\(String(format: "%.1f", statistics.winRate))%")
                                .font(.customBold(size: 14))
                                .foregroundColor(.yellow)
                        }
                    }
                }
            }
            
            Spacer()
        }
        .padding(15)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(hex: "1C1C2C"),
                    Color(hex: "212135"),
                    Color(hex: "171726")
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
        .cornerRadius(30)
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color(hex: "A3702C"), lineWidth: 2)
        )
    }
}

#Preview {
    StatisticsView()
}

