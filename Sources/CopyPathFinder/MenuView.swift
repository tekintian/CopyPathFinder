import SwiftUI

struct MenuView: View {
    let appDelegate: AppDelegate
    @ObservedObject var shortcutManager = ShortcutManager()
    @State private var showingMoreOptions = false
    @State private var refreshID = UUID()
    @State private var buttonAnimations: [String: Bool] = [:] // Track animation state for each button
    
    var body: some View {
        VStack(spacing: 8) {
            // Core Functions
            VStack(spacing: 6) {
                MenuButton(title: "copy_path".localized, 
                          icon: "📋", 
                          shortcut: shortcutManager.copyPathShortcut.displayString,
                          action: { 
                              animateAndPerformAction("copy_path") { 
                                  appDelegate.copySelectedPath() 
                              }
                          })
                
                MenuButton(title: "copy_file_name".localized, 
                          icon: "📄", 
                          shortcut: "",
                          action: { 
                              animateAndPerformAction("copy_file_name") { 
                                  appDelegate.copyFileName() 
                              }
                          })
                
                MenuButton(title: "open_in_terminal".localized, 
                          icon: "💻", 
                          shortcut: "⌘⇧T",
                          action: { 
                              animateAndPerformAction("open_in_terminal") { 
                                  appDelegate.openInTerminal() 
                              }
                          })
            }
            
            Divider()
                .padding(.vertical, 4)
            
            // Settings, About and Quit
            VStack(spacing: 6) {
                MenuButton(title: "settings".localized, 
                          icon: "⚙️", 
                          shortcut: "",
                          action: { 
                              animateAndPerformAction("settings") { 
                                  appDelegate.showSettings() 
                              }
                          })
                
                MenuButton(title: "about".localized, 
                          icon: "ℹ️", 
                          shortcut: "",
                          action: { 
                              animateAndPerformAction("about") { 
                                  appDelegate.showAbout() 
                              }
                          })
                
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
    
    // Animation and action handler
    private func animateAndPerformAction(_ buttonId: String, action: @escaping () -> Void) {
        // Trigger animation
        buttonAnimations[buttonId] = true
        
        // Perform the action
        action()
        
        // Reset animation state after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            buttonAnimations[buttonId] = false
        }
        
        // Hide menu after animation completes
        if ["copy_path", "copy_file_name", "open_in_terminal"].contains(buttonId) {
            let delay = (buttonId == "copy_path" || buttonId == "copy_file_name") ? 1.5 : 1.0  // Longer delay for copy buttons to show checkmark
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                appDelegate.hidePopover()
            }
        }
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let shortcut: String
    let action: () -> Void
    @State private var isPressed = false
    @State private var isAnimating = false
    @State private var showSuccessIcon = false
    @State private var currentIcon: String
    
    init(title: String, icon: String, shortcut: String, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.shortcut = shortcut
        self.action = action
        self._currentIcon = State(initialValue: icon)
    }
    
    var body: some View {
        Button(action: {
            // Trigger press animation
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = true
                isAnimating = true
            }
            
            // Perform action
            action()
            
            // For copy path and copy file name buttons, show success animation
            if title == "copy_path".localized || title == "copy_file_name".localized {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        showSuccessIcon = true
                        currentIcon = "✅"
                    }
                    
                    // Reset to original icon after success animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            showSuccessIcon = false
                            currentIcon = icon
                        }
                    }
                }
            }
            
            // Reset animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    isPressed = false
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isAnimating = false
            }
        }) {
            HStack {
                if !currentIcon.isEmpty {
                    Text(currentIcon)
                        .frame(width: 20, alignment: .leading)
                        .scaleEffect(isPressed ? 0.8 : 1.0)
                        .scaleEffect(showSuccessIcon ? 1.2 : 1.0)
                        .foregroundColor(showSuccessIcon ? .green : .primary)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: showSuccessIcon)
                        .animation(.easeInOut(duration: 0.15), value: isPressed)
                }
                Text(title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .opacity(isAnimating ? 0.7 : 1.0)
                if !shortcut.isEmpty {
                    Text(shortcut)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 60, alignment: .trailing)
                        .opacity(isAnimating ? 0.7 : 1.0)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(isPressed ? Color.accentColor.opacity(0.2) : 
                      (isAnimating ? Color.accentColor.opacity(0.1) : Color.clear))
                .animation(.easeInOut(duration: 0.15), value: isPressed)
                .animation(.easeInOut(duration: 0.3), value: isAnimating)
        )
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isPressed)
        .onHover { isHovered in
            if isHovered {
                NSCursor.pointingHand.set()
            } else {
                NSCursor.arrow.set()
            }
        }
    }
}