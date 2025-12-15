import Cocoa
import SwiftUI
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        setupGlobalShortcut()
        requestNotificationPermission()
        
        // Hide dock icon and main window
        NSApp.setActivationPolicy(.accessory)
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            button.image = createStatusBarIcon()
            button.action = #selector(togglePopover)
            button.target = self
        }
    }
    
    private func setupGlobalShortcut() {
        NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { event in
            if event.keyCode == 8 && event.modifierFlags.contains([.command, .shift]) {
                self.copySelectedPath()
            }
        }
    }
    
    private func createStatusBarIcon() -> NSImage? {
        let bundle = Bundle.main
        
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
            let contentView = NSHostingView(rootView: MenuView())
            contentView.frame = NSRect(x: 0, y: 0, width: 200, height: 130)
            popover?.contentViewController = NSViewController()
            popover?.contentViewController?.view = contentView
            popover?.contentSize = NSSize(width: 200, height: 130)
        }
        
        if let button = statusItem?.button {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
    
    @objc func copySelectedPath() {
        do {
            let path = try getSelectedPath()
            NSPasteboard.general.clearContents()
            NSPasteboard.general.setString(path, forType: .string)
            showNotification("Path copied", message: path)
        } catch {
            showNotification("Error", message: error.localizedDescription)
        }
    }
    
    @objc func openInTerminal() {
        do {
            let path = try getSelectedPath()
            openTerminal(at: path)
            showNotification("Terminal opened", message: path)
        } catch {
            showNotification("Error", message: error.localizedDescription)
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

struct MenuView: View {
    var body: some View {
        VStack(spacing: 10) {
            Button(action: {
                if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                    appDelegate.copySelectedPath()
                }
            }) {
                HStack {
                    Text("📋")
                    Text("Copy Path")
                    Text("⌘⇧C")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Button(action: {
                if let appDelegate = NSApplication.shared.delegate as? AppDelegate {
                    appDelegate.openInTerminal()
                }
            }) {
                HStack {
                    Text("💻")
                    Text("Open in Terminal")
                }
            }
            
            Divider()
            
            Button(action: {
                NSApplication.shared.terminate(nil)
            }) {
                HStack {
                    Text("Quit")
                    Text("⌘Q")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
    }
}

// MARK: - Finder Integration
func getSelectedPath() throws -> String {
    let script = """
    tell application "Finder"
        try
            set theSelection to selection
            if theSelection is {} then
                set thePath to (target of front Finder window) as alias
            else
                set thePath to item 1 of theSelection as alias
            end if
            return POSIX path of thePath
        on error
            return POSIX path of (path to desktop)
        end try
    end tell
    """
    
    let appleScript = NSAppleScript(source: script)
    var error: NSDictionary?
    let result = appleScript?.executeAndReturnError(&error)
    
    if let error = error {
        throw NSError(domain: "ScriptError", code: -1, userInfo: error as? [String: Any])
    } else if let path = result?.stringValue {
        return path.trimmingCharacters(in: .whitespacesAndNewlines)
    } else {
        throw NSError(domain: "ScriptError", code: -2, userInfo: [NSLocalizedDescriptionKey: "Unable to get selected path"])
    }
}

// Main entry point
let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()