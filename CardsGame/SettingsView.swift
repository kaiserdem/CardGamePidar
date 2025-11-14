import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isSoundEnabled: Bool = true
    @State private var soundVolume: Double = 0.7
    
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
                    
                    Text("Settings")
                        .font(.customTitle)
                        .foregroundColor(.white)
                        .offset(x: 20)
                    Spacer()
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 85)
                
                Spacer()
                
                // Налаштування
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        // Налаштування звуку
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Sound Settings")
                                .font(.customBold(size: 24))
                                .foregroundColor(.white)
                            
                            // Перемикач увімкнення/вимкнення звуку
                            HStack {
                                Text("Enable Sound")
                                    .font(.customRegular(size: 20))
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Toggle("", isOn: $isSoundEnabled)
                                    .toggleStyle(SwitchToggleStyle(tint: Color(hex: "A3702C")))
                                    .onChange(of: isSoundEnabled) { newValue in
                                        SoundManager.shared.setSoundEnabled(newValue)
                                        // Зберігаємо налаштування
                                        UserDefaults.standard.set(newValue, forKey: "soundEnabled")
                                    }
                            }
                            .padding(.vertical, 10)
                            
                            // Слайдер гучності
                            if isSoundEnabled {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack {
                                        Text("Volume")
                                            .font(.customRegular(size: 20))
                                            .foregroundColor(.white)
                                        
                                        Spacer()
                                        
                                        Text("\(Int(soundVolume * 100))%")
                                            .font(.customRegular(size: 18))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    
                                    Slider(value: $soundVolume, in: 0.0...1.0)
                                        .tint(Color(hex: "A3702C"))
                                        .onChange(of: soundVolume) { newValue in
                                            SoundManager.shared.setVolume(newValue)
                                            // Зберігаємо налаштування
                                            UserDefaults.standard.set(newValue, forKey: "soundVolume")
                                        }
                                }
                                .padding(.vertical, 10)
                            }
                        }
                        .padding(.horizontal, 30)
                        .padding(.top, 20)
                    }
                    .padding(.bottom, 100) // Відступ знизу для прокрутки
                }
                
                Spacer()
            }
        }
        .onAppear {
            // Завантажуємо налаштування з SoundManager
            isSoundEnabled = SoundManager.shared.getSoundEnabled()
            soundVolume = SoundManager.shared.getVolume()
        }
    }
}

#Preview {
    SettingsView()
}

