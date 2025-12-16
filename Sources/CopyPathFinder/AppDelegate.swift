import Cocoa
import SwiftUI
import UserNotifications
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    var settingsPopover: NSPopover?
    var aboutPopover: NSPopover?
    var shortcutManager = ShortcutManager()
    private var settingsManager: SettingsManager!
    private var launchAtLoginManager = LaunchAtLoginManager()
    private var cancellables = Set<AnyCancellable>()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("AppDelegate: applicationDidFinishLaunching started")
        
        // Initialize managers after app starts
        settingsManager = SettingsManager()
        print("SettingsManager initialized")
        
        setupMenuBar()
        print("MenuBar setup completed")
        
        setupGlobalShortcuts()
        print("Global shortcuts setup completed")
        
        requestNotificationPermission()
        print("Notification permission requested")
        
        // Hide dock icon and main window
        NSApp.setActivationPolicy(.accessory)
        print("Activation policy set to accessory")
        
        print("AppDelegate: applicationDidFinishLaunching completed")
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            button.image = createStatusBarIcon()
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        // Listen for settings changes
        settingsManager.objectWillChange
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.updateStatusBarIcon()
                    self?.updateLaunchAtLogin()
                    self?.updateLanguage()
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupGlobalShortcuts() {
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            if self.shortcutManager.matchesCopyPathShortcut(event) {
                self.copySelectedPath()
            } else if self.shortcutManager.matchesOpenTerminalShortcut(event) {
                self.openInTerminal()
            }
        }
    }
    
    private func createStatusBarIcon() -> NSImage? {
        let bundle = Bundle.main
        let iconType = settingsManager.appIcon
        
        switch iconType {
        case "folder":
            return NSImage(named: NSImage.folderName)
        case "terminal":
            return NSImage(named: NSImage.computerName)
        default: // "default"
            // Try to load custom status bar icon from bundle resources
            if let iconPath = bundle.path(forResource: "StatusIcon", ofType: "png"),
               let image = NSImage(contentsOfFile: iconPath) {
                image.isTemplate = true  // Makes it adapt to light/dark mode
                return image
            }
            
            // Fallback: try to create a small version from app icon
            if let iconPath = bundle.path(forResource: "AppIcon", ofType: "icns"),
               let image = NSImage(contentsOfFile: iconPath) {
                // Resize for status bar
                let size = NSSize(width: 16, height: 16)
                image.size = size
                image.isTemplate = true
                return image
            }
            
            // Final fallback: use system folder icon
            return NSImage(named: NSImage.folderName)
        }
    }
    
    func updateStatusBarIcon() {
        guard let button = statusItem?.button else { return }
        button.image = createStatusBarIcon()
    }
    
    func updateLaunchAtLogin() {
        launchAtLoginManager.isEnabled = settingsManager.launchAtLogin
    }
    
    func updateLanguage() {
        // Note: For full language switching, the app would need to restart
        // For now, this just saves the preference for future launches
        // Temporarily disabled to avoid AppleLanguages issue
        // UserDefaults.standard.set([settingsManager.appLanguage], forKey: "AppleLanguages")
        print("Language would be set to: \(settingsManager.appLanguage)")
    }
    
    private func requestNotificationPermission() {
        // Check if running in app bundle environment
        guard Bundle.main.bundleURL.pathExtension == "app" else {
            print("Running outside app bundle, skipping notification permission request")
            return
        }
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    @objc func togglePopover() {
        if let popover = popover {
            if popover.isShown {
                popover.performClose(nil)
            } else {
                showPopover()
            }
        } else {
            showPopover()
        }
    }
    
    private func showPopover() {
        if popover == nil {
            popover = NSPopover()
            let contentView = NSHostingView(rootView: MenuView(appDelegate: self))
            contentView.frame = NSRect(x: 0, y: 0, width: 220, height: 220)
            popover?.contentViewController = NSViewController()
            popover?.contentViewController?.view = contentView
            popover?.contentSize = NSSize(width: 220, height: 220)
        }
        
        if let button = statusItem?.button {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
    
    @objc func showSettings() {
        if settingsPopover == nil {
            settingsPopover = NSPopover()
            var settingsView = SettingsView(shortcutManager: shortcutManager, settingsManager: settingsManager)
            let contentView = NSHostingView(rootView: settingsView)
            
            // Set close callback
            settingsView.onClose = { [weak self] in
                self?.settingsPopover?.performClose(nil)
                self?.settingsPopover = nil
            }
            
            contentView.frame = NSRect(x: 0, y: 0, width: 450, height: 480)
            settingsPopover?.contentViewController = NSViewController()
            settingsPopover?.contentViewController?.view = contentView
            settingsPopover?.contentSize = NSSize(width: 450, height: 480)
            settingsPopover?.behavior = .transient
        }
        
        if let button = statusItem?.button {
            settingsPopover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
    
    @objc func showAbout() {
        if aboutPopover == nil {
            aboutPopover = NSPopover()
            let aboutView = AboutView(onClose: { [weak self] in
                self?.aboutPopover?.performClose(nil)
                self?.aboutPopover = nil
            })
            let contentView = NSHostingView(rootView: aboutView)
            
            contentView.frame = NSRect(x: 0, y: 0, width: 400, height: 300)
            aboutPopover?.contentViewController = NSViewController()
            aboutPopover?.contentViewController?.view = contentView
            aboutPopover?.contentSize = NSSize(width: 400, height: 300)
            aboutPopover?.behavior = .transient
        }
        
        if let button = statusItem?.button {
            aboutPopover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
    
    @objc func copySelectedPath() {
        do {
            let path = try getSelectedPath()
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(path, forType: .string)
            
            // Add to recent paths
            settingsManager.addRecentPath(path)
            
            showNotification("path_copied".localized, message: path)
        } catch {
            showNotification("error".localized, message: error.localizedDescription)
        }
    }
    
    @objc func openInTerminal() {
        do {
            let path = try getSelectedPath()
            openTerminal(at: path)
            
            // Add to recent paths
            settingsManager.addRecentPath(path)
            
            showNotification("terminal_opened".localized, message: path)
        } catch {
            showNotification("error".localized, message: error.localizedDescription)
        }
    }
    
    @objc func copyFileName() {
        do {
            let path = try getSelectedPath()
            let fileName = (path as NSString).lastPathComponent
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(fileName, forType: .string)
            showNotification("file_name_copied".localized, message: fileName)
        } catch {
            showNotification("error".localized, message: error.localizedDescription)
        }
    }
    
    private func openTerminal(at path: String) {
        let script = """
        tell application "Terminal"
            activate
            do script "cd '\(path.replacingOccurrences(of: "'", with: "'\\''"))'"
        end tell
        """
        
        let appleScript = NSAppleScript(source: script)
        var error: NSDictionary?
        appleScript?.executeAndReturnError(&error)
        
        if let error = error {
            print("AppleScript error: \(error)")
        }
    }
    
    private func showNotification(_ title: String, message: String) {
        // Check if notifications are enabled
        guard settingsManager.showNotifications else {
            if settingsManager.enableDebugMode {
                print("Notification disabled: \(title) - \(message)")
            }
            return
        }
        
        // Check if running in app bundle environment
        guard Bundle.main.bundleURL.pathExtension == "app" else {
            print("Notification: \(title) - \(message)")
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = message
        content.sound = UNNotificationSound.default
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Notification error: \(error)")
            }
        }
    }
}