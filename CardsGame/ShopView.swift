import SwiftUI
import Combine

class ShopManager: ObservableObject {
    @Published var coins: Int {
        didSet {
            UserDefaults.standard.set(coins, forKey: "userCoins")
        }
    }
    
    @Published var unlockedSkins: Set<String> {
        didSet {
            if let encoded = try? JSONEncoder().encode(unlockedSkins) {
                UserDefaults.standard.set(encoded, forKey: "unlockedSkins")
            }
        }
    }
    
    // Ціни скінів
    let skinPrices: [String: Int] = [
        "Vector-0": 0,  // Безкоштовний
        "Vector-1": 300,
        "Vector-2": 600,
        "Vector-3": 1000,
        "Vector-4": 1500
    ]
    
    init() {
        // Завантажуємо гроші (використовуємо _coins для прямого доступу під час ініціалізації)
        let loadedCoins = UserDefaults.standard.integer(forKey: "userCoins")
        let initialCoins = loadedCoins == 0 ? 0 : loadedCoins
        _coins = Published(initialValue: initialCoins)
        
        // Завантажуємо відкриті скіни (використовуємо _unlockedSkins для прямого доступу)
        if let data = UserDefaults.standard.data(forKey: "unlockedSkins"),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            _unlockedSkins = Published(initialValue: decoded)
        } else {
            // Vector-0 відкритий за замовчуванням
            _unlockedSkins = Published(initialValue: ["Vector-0"])
        }
    }
    
    func isSkinUnlocked(_ skinName: String) -> Bool {
        return unlockedSkins.contains(skinName)
    }
    
    func canAfford(_ skinName: String) -> Bool {
        guard let price = skinPrices[skinName] else { return false }
        return coins >= price
    }
    
    func buySkin(_ skinName: String) -> Bool {
        guard let price = skinPrices[skinName] else { return false }
        guard !isSkinUnlocked(skinName) else { return false } // Вже куплено
        guard canAfford(skinName) else { return false } // Недостатньо грошей
        
        coins -= price
        unlockedSkins.insert(skinName)
        return true
    }
    
    func addCoins(_ amount: Int) {
        coins += amount
    }
}

struct ShopView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var shopManager = ShopManager()
    
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
                // Верхня частина: кнопка назад, заголовок, гроші
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
                    
                    Text("Shop")
                        .font(.customTitle)
                        .foregroundColor(.white)
                        .offset(x: 20)
                    
                    Spacer()
                    
                    // Гроші
                    HStack(spacing: 8) {
                        Image("coin")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 30, height: 30)
                        
                        Text("\(shopManager.coins)")
                            .font(.customBold(size: 20))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 120)
                
                Spacer()
                
                // Сітка скінів (по одному в рядку)
                ScrollView {
                    VStack(spacing: 20) {
                        ForEach(CardBack.allCases, id: \.rawValue) { skin in
                            SkinCardView(
                                skin: skin,
                                isUnlocked: shopManager.isSkinUnlocked(skin.imageName),
                                price: shopManager.skinPrices[skin.imageName] ?? 0,
                                canAfford: shopManager.canAfford(skin.imageName),
                                onBuy: {
                                    if shopManager.buySkin(skin.imageName) {
                                        // Успішна покупка
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100)
                }
                
                Spacer()
            }
        }
    }
}

struct SkinCardView: View {
    let skin: CardBack
    let isUnlocked: Bool
    let price: Int
    let canAfford: Bool
    let onBuy: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            // Стопка карт (10 карт зі зворотньою стороною, накладені одна на одну)
            ZStack {
                // 10 карт зі зворотньою стороною з зсувом (тут робиться зсув)
                ForEach(0..<10, id: \.self) { i in
                    Image(skin.imageName)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 112)
                        .offset(x: CGFloat(i * 8) - 20, y: CGFloat(i * 8) - 40) // Зсув вправо і вверх
                        .zIndex(Double(i))
                }
            }
            .frame(width: 180, height: 250)
            
            // Стан та ціна
            VStack(alignment: .leading, spacing: 15) {
                // Назва скіна
                Spacer()
                
                Text(skin.displayName)
                    .font(.customBold(size: 20))
                    .foregroundColor(.white)
                
                // Опис скіна
                Text(skin.description)
                    .font(.customRegular(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(6)
                
                Spacer()
                
                if isUnlocked {
                    Button(action: {}) {
                        Text("Unlocked")
                            .font(.customBold(size: 14))
                            .foregroundColor(.white)
                            .frame(width: 120, height: 40)
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                    .disabled(true)
                } else {
                    VStack(alignment: .leading, spacing: 15) {
                        Text("\(price) coins")
                            .font(.customBold(size: 16))
                            .foregroundColor(canAfford ? .white : .red)
                        
                        Button(action: onBuy) {
                            Text("Buy")
                                .font(.customBold(size: 14))
                                .foregroundColor(.white)
                                .frame(width: 120, height: 40)
                                .background(canAfford ? Color(hex: "A3702C") : Color.gray)
                                .cornerRadius(8)
                        }
                        .disabled(!canAfford)
                    }
                }
                Spacer()
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity)
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
    ShopView()
}

