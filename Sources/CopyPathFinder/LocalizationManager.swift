import Foundation

class LocalizationManager {
    static let shared = LocalizationManager()
    
    private init() {}
    
    enum Language: String, CaseIterable {
        case english = "en"
        case chineseSimplified = "zh-Hans"
        
        var displayName: String {
            switch self {
            case .english:
                return "English"
            case .chineseSimplified:
                return "简体中文"
            }
        }
    }
    
    private var currentLanguage: Language = {
        // 检测系统首选语言
        let preferredLanguages = Locale.preferredLanguages
        
        // 按优先级检查支持的语言
        for languageCode in preferredLanguages {
            if languageCode.hasPrefix("zh") {
                return .chineseSimplified
            } else if languageCode.hasPrefix("en") {
                return .english
            }
        }
        
        // 如果都不匹配，默认回退到英语
        return .english
    }()
    
    func localizedString(for key: String) -> String {
        guard let path = Bundle.main.path(forResource: currentLanguage.rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            // Fallback to English if current language bundle not found
            guard let englishPath = Bundle.main.path(forResource: "en", ofType: "lproj"),
                  let englishBundle = Bundle(path: englishPath) else {
                return key // Return key as fallback
            }
            return englishBundle.localizedString(forKey: key, value: key, table: nil)
        }
        
        return bundle.localizedString(forKey: key, value: key, table: nil)
    }
    
    func setLanguage(_ language: Language) {
        currentLanguage = language
    }
    
    func getCurrentLanguage() -> Language {
        return currentLanguage
    }
}

// Extension for easier localization
extension String {
    var localized: String {
        return LocalizationManager.shared.localizedString(for: self)
    }
}