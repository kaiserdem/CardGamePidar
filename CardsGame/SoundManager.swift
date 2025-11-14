import AVFoundation
import AudioToolbox

/// Менеджер для управління звуками в грі
class SoundManager {
    static let shared = SoundManager()
    
    private var audioPlayer: AVAudioPlayer?
    private var cardPlaceTimer: Timer?
    private var isSoundEnabled: Bool = true
    private var volume: Float = 0.7
    
    private init() {
        // Налаштування сесії аудіо
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Помилка налаштування аудіо сесії: \(error)")
        }
        
        // Завантажуємо збережені налаштування
        if UserDefaults.standard.object(forKey: "soundEnabled") != nil {
            isSoundEnabled = UserDefaults.standard.bool(forKey: "soundEnabled")
        }
        
        if UserDefaults.standard.object(forKey: "soundVolume") != nil {
            volume = Float(UserDefaults.standard.double(forKey: "soundVolume"))
        }
    }
    
    /// Типи звуків у грі
    enum SoundType: String {
        case shuffle = "shuffle"           // Звук тасування
        case deal = "deal"                 // Звук роздачі
        case coin = "coin"                  // Звук додавання монет
        case cardFlip = "cardFlip"         // Звук перевертання карти
        case cardPlace = "cardPlace"       // Звук кладення карти на стіл
        case pairRemoved = "pairRemoved"   // Звук видалення пари
        case win = "win"                   // Звук виграшу
        case lose = "lose"                 // Звук програшу
        
        /// Ім'я файлу звуку (якщо буде додано власний файл)
        var fileName: String {
            switch self {
            case .shuffle, .deal:
                // Використовуємо файл тасування для обох випадків
                return "playing_cards_deck_flick_through_001_20485"
            case .cardPlace:
                return "016dc355e8df233"
            case .coin:
                return "coins-pour-out"
            default:
                return self.rawValue
            }
        }
        
        /// Системний звук ID (якщо використовуємо системні звуки)
        var systemSoundID: SystemSoundID? {
            switch self {
            case .shuffle:
                return nil // Буде використовуватися власний звук
            case .deal:
                return nil // Буде використовуватися власний звук
            case .coin:
                return 1057 // Системний звук "coin"
            case .cardFlip:
                return 1104 // Системний звук "tink"
            case .cardPlace:
                return nil // Буде використовуватися власний звук
            case .pairRemoved:
                return 1103 // Системний звук "pop"
            case .win:
                return 1054 // Системний звук "fanfare"
            case .lose:
                return 1053 // Системний звук "basso"
            }
        }
    }
    
    /// Увімкнути/вимкнути звуки
    func setSoundEnabled(_ enabled: Bool) {
        isSoundEnabled = enabled
    }
    
    /// Встановити гучність (0.0 - 1.0)
    func setVolume(_ volume: Double) {
        self.volume = Float(volume)
        audioPlayer?.volume = self.volume
    }
    
    /// Отримати поточну гучність
    func getVolume() -> Double {
        return Double(volume)
    }
    
    /// Отримати стан звуку
    func getSoundEnabled() -> Bool {
        return isSoundEnabled
    }
    
    /// Відтворити звук
    func playSound(_ soundType: SoundType) {
        guard isSoundEnabled else { return }
        
        // Спочатку намагаємося відтворити власний звуковий файл
        var customSoundURL: URL?
        if let mp3URL = Bundle.main.url(forResource: soundType.fileName, withExtension: "mp3") {
            customSoundURL = mp3URL
        } else if let wavURL = Bundle.main.url(forResource: soundType.fileName, withExtension: "wav") {
            customSoundURL = wavURL
        } else if let m4aURL = Bundle.main.url(forResource: soundType.fileName, withExtension: "m4a") {
            customSoundURL = m4aURL
        }
        
        if let url = customSoundURL {
            // Для звуку кладення карти зупиняємо через 2 секунди
            let stopAfter: TimeInterval? = (soundType == .cardPlace) ? 2.0 : nil
            playCustomSound(url: url, stopAfter: stopAfter)
            return
        }
        
        // Якщо власного файлу немає, використовуємо системний звук
        if let soundID = soundType.systemSoundID {
            AudioServicesPlaySystemSound(soundID)
        }
    }
    
    /// Відтворити власний звуковий файл
    private func playCustomSound(url: URL, stopAfter: TimeInterval? = nil) {
        do {
            // Зупиняємо попередній звук, якщо він відтворюється
            audioPlayer?.stop()
            cardPlaceTimer?.invalidate()
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.volume = volume
            audioPlayer?.play()
            
            // Якщо вказано час зупинки, встановлюємо таймер
            if let stopTime = stopAfter {
                cardPlaceTimer = Timer.scheduledTimer(withTimeInterval: stopTime, repeats: false) { [weak self] _ in
                    self?.audioPlayer?.stop()
                    self?.cardPlaceTimer = nil
                }
            }
        } catch {
            print("Помилка відтворення звуку: \(error)")
            // Якщо не вдалося відтворити власний файл, використовуємо системний звук
            if let soundID = SoundType(rawValue: url.deletingPathExtension().lastPathComponent)?.systemSoundID {
                AudioServicesPlaySystemSound(soundID)
            }
        }
    }
    
    /// Відтворити звук тасування (можна викликати кілька разів для ефекту)
    func playShuffleSound() {
        playSound(.shuffle)
    }
    
    /// Відтворити звук роздачі карти
    func playDealSound() {
        playSound(.deal)
    }
    
    /// Відтворити звук додавання монет
    func playCoinSound() {
        playSound(.coin)
    }
    
    /// Відтворити звук перевертання карти
    func playCardFlipSound() {
        playSound(.cardFlip)
    }
    
    /// Відтворити звук кладення карти на стіл
    func playCardPlaceSound() {
        playSound(.cardPlace)
    }
    
    /// Відтворити звук видалення пари
    func playPairRemovedSound() {
        playSound(.pairRemoved)
    }
    
    /// Відтворити звук виграшу
    func playWinSound() {
        playSound(.win)
    }
    
    /// Відтворити звук програшу
    func playLoseSound() {
        playSound(.lose)
    }
}

