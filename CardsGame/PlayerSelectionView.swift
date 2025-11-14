import SwiftUI

struct PlayerSelectionView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var botManager = BotProfileManager.shared
    @StateObject private var shopManager = ShopManager()
    @State private var selectedBot: BotProfile?
    @State private var showGameView = false
    
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
                // Верхня частина: кнопка назад, заголовок та монети
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
                    
                    Text("Select Opponent")
                        .font(.customTitle)
                        .foregroundColor(.white)
                        .offset(x: 20)
                    Spacer()
                    
                    // Відображення монет
                    HStack(spacing: 8) {
                        Image("coin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        
                        Text("\(shopManager.coins)")
                            .font(.customHeadline)
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 85)
                
                // Список ботів
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(BotProfileManager.allBots) { bot in
                            BotCardView(
                                bot: bot,
                                isUnlocked: botManager.isBotUnlocked(bot),
                                isSelected: selectedBot?.id == bot.id,
                                shopManager: shopManager,
                                onSelect: {
                                    if botManager.isBotUnlocked(bot) {
                                        selectedBot = bot
                                    }
                                },
                                onUnlock: {
                                    if botManager.canAffordBot(bot, shopManager: shopManager) {
                                        if botManager.unlockBot(bot) {
                                            shopManager.spendCoins(bot.price)
                                            // Оновлюємо стан після розблокування
                                            if botManager.isBotUnlocked(bot) {
                                                selectedBot = bot
                                            }
                                        }
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
                
                // Кнопка "Start Game"
                if let selectedBot = selectedBot {
                    Button(action: {
                        showGameView = true
                    }) {
                        Text("Start Game")
                            .font(.customHeadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
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
                    .padding(.horizontal, 30)
                    .padding(.bottom, 80)
                }
            }
        }
        .fullScreenCover(isPresented: $showGameView) {
            if let selectedBot = selectedBot {
                GameView(selectedBot: selectedBot)
            }
        }
        .onAppear {
            // За замовчуванням вибираємо першого (безкоштовного) бота
            if selectedBot == nil, let firstBot = BotProfileManager.allBots.first {
                selectedBot = firstBot
            }
        }
    }
}

struct BotCardView: View {
    let bot: BotProfile
    let isUnlocked: Bool
    let isSelected: Bool
    @ObservedObject var shopManager: ShopManager
    let onSelect: () -> Void
    let onUnlock: () -> Void
    
    var body: some View {
        Button(action: {
            if isUnlocked {
                onSelect()
            }
        }) {
            HStack(spacing: 15) {
                // Аватар
                Image(bot.avatar.roundedVersion.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(isSelected ? Color(hex: "A3702C") : Color.clear, lineWidth: 3)
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
                    
                    // Опис
                    Text(bot.description)
                        .font(.customRegular(size: 12))
                        .foregroundColor(.white.opacity(0.6))
                        .lineLimit(2)
                    
                    // Коефіцієнт грошей
                    HStack(spacing: 4) {
                        Image("coin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 16, height: 16)
                        Text("\(String(format: "%.1f", bot.moneyMultiplier))x rewards")
                            .font(.customRegular(size: 12))
                            .foregroundColor(.yellow)
                    }
                }
                
                Spacer()
                
                // Кнопка розблокування або статус
                if isUnlocked {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.system(size: 30))
                    } else {
                        Text("Select")
                            .font(.customRegular(size: 14))
                            .foregroundColor(.white)
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(Color(hex: "A3702C"))
                            .cornerRadius(15)
                    }
                } else {
                    Button(action: {
                        onUnlock()
                    }) {
                        VStack(spacing: 4) {
                            Image("coin")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                            Text("\(bot.price)")
                                .font(.customRegular(size: 12))
                                .foregroundColor(.white)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(
                            shopManager.coins >= bot.price ?
                            Color(hex: "A3702C") :
                            Color.gray.opacity(0.5)
                        )
                        .cornerRadius(15)
                    }
                    .disabled(shopManager.coins < bot.price)
                }
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
                    .stroke(isSelected ? Color(hex: "A3702C") : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PlayerSelectionView()
}

