import Foundation
import SwiftUI

class SettingsManager: ObservableObject {
    // General Settings
    @Published var launchAtLogin: Bool = false
    @Published var showNotifications: Bool = true
    @Published var appIcon: String = "default"
    @Published var appLanguage: String = "zh-Hans"
    
    // Quick Toggle Settings
    @Published var isQuickToggle: Bool = false
    @Published var quickToggleType: QuickToggleType = .copyPath
    
    // Advanced Settings
    @Published var enableDebugMode: Bool = false
    @Published var logLevel: String = "Info"
    @Published var maxRecentPaths: Int = 10
    @Published var recentPaths: [String] = []
    
    private let userDefaults = UserDefaults.standard
    
    // Keys for UserDefaults
    private enum Keys {
        static let launchAtLogin = "LaunchAtLogin"
        static let showNotifications = "ShowNotifications"
        static let appIcon = "AppIcon"
        static let appLanguage = "AppLanguage"
        static let isQuickToggle = "IsQuickToggle"
        static let quickToggleType = "QuickToggleType"
        static let enableDebugMode = "EnableDebugMode"
        static let logLevel = "LogLevel"
        static let maxRecentPaths = "MaxRecentPaths"
        static let recentPaths = "RecentPaths"
    }
    
    init() {
        // Get system default language
        let systemLanguage = LocalizationManager.shared.getCurrentLanguage().rawValue
        
        // Initialize with default values (using system language)
        self.launchAtLogin = false
        self.showNotifications = true
        self.appIcon = "default"
        self.appLanguage = systemLanguage
        self.isQuickToggle = false
        self.quickToggleType = .copyPath
        self.enableDebugMode = false
        self.logLevel = "Info"
        self.maxRecentPaths = 10
        self.recentPaths = []
        
        // Load from UserDefaults safely (will override system language if user has set a preference)
        loadSettings()
        
        // Set initial language in LocalizationManager
        if let language = LocalizationManager.Language(rawValue: self.appLanguage) {
            LocalizationManager.shared.setLanguage(language)
        }
        
        print("SettingsManager initialized with language: \(self.appLanguage) (system: \(systemLanguage))")
    }
    
    private func loadSettings() {
        self.launchAtLogin = userDefaults.bool(forKey: Keys.launchAtLogin)
        if userDefaults.object(forKey: Keys.showNotifications) != nil {
            self.showNotifications = userDefaults.bool(forKey: Keys.showNotifications)
        }
        if let icon = userDefaults.string(forKey: Keys.appIcon) {
            self.appIcon = icon
        }
        if let language = userDefaults.string(forKey: Keys.appLanguage) {
            self.appLanguage = language
        }
        self.isQuickToggle = userDefaults.bool(forKey: Keys.isQuickToggle)
        if let quickToggleTypeRaw = userDefaults.string(forKey: Keys.quickToggleType),
           let quickToggleType = QuickToggleType(rawValue: quickToggleTypeRaw) {
            self.quickToggleType = quickToggleType
        }
        self.enableDebugMode = userDefaults.bool(forKey: Keys.enableDebugMode)
        if let level = userDefaults.string(forKey: Keys.logLevel) {
            self.logLevel = level
        }
        if let max = userDefaults.object(forKey: Keys.maxRecentPaths) as? Int {
            self.maxRecentPaths = max
        }
        if let paths = userDefaults.array(forKey: Keys.recentPaths) as? [String] {
            self.recentPaths = paths
        }
    }
    
    private func saveSettings() {
        userDefaults.set(launchAtLogin, forKey: Keys.launchAtLogin)
        userDefaults.set(showNotifications, forKey: Keys.showNotifications)
        userDefaults.set(appIcon, forKey: Keys.appIcon)
        userDefaults.set(appLanguage, forKey: Keys.appLanguage)
        userDefaults.set(isQuickToggle, forKey: Keys.isQuickToggle)
        userDefaults.set(quickToggleType.rawValue, forKey: Keys.quickToggleType)
        userDefaults.set(enableDebugMode, forKey: Keys.enableDebugMode)
        userDefaults.set(logLevel, forKey: Keys.logLevel)
        userDefaults.set(maxRecentPaths, forKey: Keys.maxRecentPaths)
        userDefaults.set(recentPaths, forKey: Keys.recentPaths)
    }
    
    func resetToDefaults() {
        // Reset to default values (using system default language)
        let systemLanguage = LocalizationManager.shared.getCurrentLanguage().rawValue
        
        launchAtLogin = false
        showNotifications = true
        appIcon = "default"
        appLanguage = systemLanguage
        isQuickToggle = false
        quickToggleType = .copyPath
        enableDebugMode = false
        logLevel = "Info"
        maxRecentPaths = 10
        recentPaths = []
    }
    
    func saveAllSettings() {
        saveSettings()
    }
    
    func addRecentPath(_ path: String) {
        // Remove if already exists
        recentPaths.removeAll { $0 == path }
        
        // Add to beginning
        recentPaths.insert(path, at: 0)
        
        // Limit to maxRecentPaths
        if recentPaths.count > maxRecentPaths {
            recentPaths = Array(recentPaths.prefix(maxRecentPaths))
        }
        
        // Auto-save
        saveSettings()
    }
}