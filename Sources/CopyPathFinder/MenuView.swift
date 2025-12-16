import SwiftUI

struct MenuView: View {
    let appDelegate: AppDelegate
    @ObservedObject var shortcutManager = ShortcutManager()
    @State private var showingMoreOptions = false
    @State private var refreshID = UUID()
    
    var body: some View {
        VStack(spacing: 8) {
            // Core Functions
            VStack(spacing: 6) {
                MenuButton(title: "copy_path".localized, 
                          icon: "📋", 
                          shortcut: shortcutManager.copyPathShortcut.displayString,
                          action: { appDelegate.copySelectedPath() })
                
                MenuButton(title: "copy_file_name".localized, 
                          icon: "📄", 
                          shortcut: "",
                          action: { appDelegate.copyFileName() })
                
                MenuButton(title: "open_in_terminal".localized, 
                          icon: "💻", 
                          shortcut: "⌘⇧T",
                          action: { appDelegate.openInTerminal() })
            }
            
            Divider()
                .padding(.vertical, 4)
            
            // Settings, About and Quit
            VStack(spacing: 6) {
                MenuButton(title: "settings".localized, 
                          icon: "⚙️", 
                          shortcut: "",
                          action: { appDelegate.showSettings() })
                
                MenuButton(title: "about".localized, 
                          icon: "ℹ️", 
                          shortcut: "",
                          action: { appDelegate.showAbout() })
                
                MenuButton(title: "quit".localized, 
                          icon: "", 
                          shortcut: "⌘Q",
                          action: { NSApplication.shared.terminate(nil) })
                    .foregroundColor(.secondary)
            }
        }
        .padding(10)
        .frame(width: 220)
        .id(refreshID)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))) { _ in
            // Force view refresh when language changes
            refreshID = UUID()
        }
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let shortcut: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if !icon.isEmpty {
                    Text(icon)
                        .frame(width: 20, alignment: .leading)
                }
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                if !shortcut.isEmpty {
                    Text(shortcut)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 60, alignment: .trailing)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.clear)
        )
        .onHover { isHovered in
            if isHovered {
                NSCursor.pointingHand.set()
            } else {
                NSCursor.arrow.set()
            }
        }
    }
}