import Cocoa
import SwiftUI
import UserNotifications
import Combine

class AppDelegate: NSObject, NSApplicationDelegate, NSPopoverDelegate {
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
        
        // Listen for settings changes
        settingsManager.objectWillChange
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.updateStatusBarIcon()
                    self?.updateLaunchAtLogin()
                    self?.updateLanguage()
                    self?.setStatusToggle()
                }
            }
            .store(in: &cancellables)
        
        setStatusToggle()
    }
    
    func setStatusToggle() {
        if let button = statusItem?.button {
            button.image = createStatusBarIcon()
            
            if settingsManager.isQuickToggle {
                // Quick Toggle 模式：移除菜单，设置点击动作
                statusItem?.menu = nil
                button.action = #selector(statusBarButtonClicked)
                button.target = self
                button.sendAction(on: [.leftMouseUp, .leftMouseDown,
                                       .rightMouseUp, .rightMouseDown])
            } else {
                // 传统菜单模式：显示弹出菜单
                statusItem?.menu = nil
                button.action = #selector(togglePopover)
                button.target = self
            }
        }
    }
    
    @objc func statusBarButtonClicked(sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        if event.type == .rightMouseDown || event.type == .rightMouseUp
            || event.modifierFlags.contains(.control)
        {
            // 右键或 Ctrl+点击：显示传统菜单
            showStatusBarMenu()
        } else if event.type == .leftMouseUp {
            // 左键：执行 Quick Toggle 动作
            performQuickToggleAction()
        }
    }
    
    private func showStatusBarMenu() {
        let menu = NSMenu()
        
        // 拷贝路径
        let copyPathItem = NSMenuItem(title: "copy_path".localized, action: #selector(copySelectedPath), keyEquivalent: "")
        copyPathItem.target = self
        menu.addItem(copyPathItem)
        
        // 拷贝文件名
        let copyFileNameItem = NSMenuItem(title: "copy_file_name".localized, action: #selector(copyFileName), keyEquivalent: "")
        copyFileNameItem.target = self
        menu.addItem(copyFileNameItem)
        
        // 分隔线
        menu.addItem(NSMenuItem.separator())
        
        // 在终端中打开
        let terminalItem = NSMenuItem(title: "open_in_terminal".localized, action: #selector(openInTerminal), keyEquivalent: "")
        terminalItem.target = self
        menu.addItem(terminalItem)
        
        // 分隔线
        menu.addItem(NSMenuItem.separator())
        
        // 设置
        let settingsItem = NSMenuItem(title: "settings".localized, action: #selector(showSettings), keyEquivalent: "")
        settingsItem.target = self
        menu.addItem(settingsItem)
        
        // 关于
        let aboutItem = NSMenuItem(title: "about".localized, action: #selector(showAbout), keyEquivalent: "")
        aboutItem.target = self
        menu.addItem(aboutItem)
        
        // 分隔线
        menu.addItem(NSMenuItem.separator())
        
        // 退出
        let quitItem = NSMenuItem(title: "quit".localized, action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        menu.addItem(quitItem)
        
        // 显示菜单
        statusItem?.menu = menu
        statusItem?.button?.performClick(nil)
        statusItem?.menu = nil
    }
    
    private func performQuickToggleAction() {
        switch settingsManager.quickToggleType {
        case .copyPath:
            copySelectedPath()
        case .copyFileName:
            copyFileName()
        case .openInTerminal:
            openInTerminal()
        }
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
        // Update LocalizationManager with new language
        if let language = LocalizationManager.Language(rawValue: settingsManager.appLanguage) {
            LocalizationManager.shared.setLanguage(language)
        }
        
        // Note: For full language switching, the app would need to restart
        // For now, this just saves the preference for future launches
        // Temporarily disabled to avoid AppleLanguages issue
        // UserDefaults.standard.set([settingsManager.appLanguage], forKey: "AppleLanguages")
        print("Language set to: \(settingsManager.appLanguage)")
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
            popover?.behavior = .transient
        }
        
        if let button = statusItem?.button {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
    
    func hidePopover() {
        popover?.performClose(nil)
    }
    
    @objc func showSettings() {
        if settingsPopover == nil {
            settingsPopover = NSPopover()
            let settingsView = SettingsView(
                shortcutManager: shortcutManager, 
                settingsManager: settingsManager,
                onClose: { [weak self] in
                    self?.settingsPopover?.performClose(nil)
                    self?.settingsPopover = nil
                }
            )
            let contentView = NSHostingView(rootView: settingsView)
            
            contentView.frame = NSRect(x: 0, y: 0, width: 500, height: 450)
            settingsPopover?.contentViewController = NSViewController()
            settingsPopover?.contentViewController?.view = contentView
            settingsPopover?.contentSize = NSSize(width: 500, height: 450)
            settingsPopover?.behavior = .semitransient
            settingsPopover?.animates = true
            settingsPopover?.delegate = self
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
            let errorMessage = extractErrorMessage(error)
            showNotification("error".localized, message: errorMessage)
            
            // If it's a permission issue, also try to open System Preferences
            if errorMessage.contains("授权") || errorMessage.contains("permission") {
                showPermissionHelp()
            }
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
            let errorMessage = extractErrorMessage(error)
            showNotification("error".localized, message: errorMessage)
            
            // If it's a permission issue, show help
            if errorMessage.contains("授权") || errorMessage.contains("permission") {
                showPermissionHelp()
            }
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
            let errorMessage = extractErrorMessage(error)
            showNotification("error".localized, message: errorMessage)
            
            // If it's a permission issue, show help
            if errorMessage.contains("授权") || errorMessage.contains("permission") {
                showPermissionHelp()
            }
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
    
    private func extractErrorMessage(_ error: Error) -> String {
        if let nsError = error as NSError? {
            // If we have a custom error message, use it
            if let customMessage = nsError.userInfo[NSLocalizedDescriptionKey] as? String {
                return customMessage
            }
            
            // Check for specific error codes
            switch nsError.code {
            case -1743: // Permission denied
                return "需要 Apple Events 权限。请在系统设置中授权控制 Finder。"
            case -1719: // Not authorized
                return "未授权访问。请在系统设置 > 隐私与安全性 > 自动化中允许控制 Finder。"
            default:
                return nsError.localizedDescription
            }
        }
        return error.localizedDescription
    }
    
    private func showPermissionHelp() {
        let alert = NSAlert()
        alert.messageText = "需要 Apple Events 权限"
        alert.informativeText = """
        要使用 CopyPathFinder 拷贝路径，需要授予以下权限：
        
        1. 打开 系统设置 > 隐私与安全性 > 自动化
        2. 找到 CopyPathFinder 并允许控制 Finder
        
        如果问题仍然存在，请检查 辅助功能 权限。
        """
        alert.alertStyle = .warning
        alert.addButton(withTitle: "打开系统设置")
        alert.addButton(withTitle: "稍后")
        
        let response = alert.runModal()
        if response == .alertFirstButtonReturn {
            // Try to open System Preferences
            if let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Automation") {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    // MARK: - NSPopoverDelegate
    
    func popoverDidClose(_ notification: Notification) {
        if let popover = notification.object as? NSPopover {
            if popover === settingsPopover {
                settingsPopover = nil
            } else if popover === aboutPopover {
                aboutPopover = nil
            }
        }
    }
}