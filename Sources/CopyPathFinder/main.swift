import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBar()
        setupGlobalShortcut()
        
        // Hide dock icon and main window
        NSApp.setActivationPolicy(.accessory)
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(named: NSImage.folderName)
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
            contentView.frame = NSRect(x: 0, y: 0, width: 200, height: 100)
            popover?.contentViewController = NSViewController()
            popover?.contentViewController?.view = contentView
            popover?.contentSize = NSSize(width: 200, height: 100)
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
    
    private func showNotification(_ title: String, message: String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = message
        NSUserNotificationCenter.default.deliver(notification)
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
                    Image(systemName: "doc.on.clipboard")
                    Text("Copy Path")
                }
            }
            .keyboardShortcut("c", modifiers: [.command, .shift])
            
            Divider()
            
            Button("Quit") {
                NSApplication.shared.terminate(nil)
            }
            .keyboardShortcut("q")
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