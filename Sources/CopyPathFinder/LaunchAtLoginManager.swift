import Foundation

class LaunchAtLoginManager {
    private let bundleIdentifier = Bundle.main.bundleIdentifier ?? "com.tekin.CopyPathFinder"
    
    var isEnabled: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "LaunchAtLoginEnabled")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "LaunchAtLoginEnabled")
            print("Launch at login \(newValue ? "enabled" : "disabled") (simulated)")
            print("Note: For actual launch-at-login functionality, please use System Preferences > Users & Groups > Login Items")
        }
    }
}