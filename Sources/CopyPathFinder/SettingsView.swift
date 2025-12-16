import SwiftUI

struct SettingsView: View {
    @ObservedObject var shortcutManager: ShortcutManager
    @ObservedObject var settingsManager: SettingsManager
    var onClose: (() -> Void)?
    @State private var refreshID = UUID()
    @State private var selectedTab: Int = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with title and close button
            HStack {
                Text("settings".localized)
                    .font(.title)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: {
                    onClose?()
                }) {
                    Text("✕")
                        .font(.title)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding()
            
            // Content
            TabView(selection: $selectedTab) {
                // General Tab
                GeneralSettingsView(settingsManager: settingsManager)
                    .tabItem {
                        VStack {
                            Text("⚙️")
                            Text("general".localized)
                        }
                    }
                    .tag(0)
                
                // Shortcuts Tab
                ShortcutSettingsView(shortcutManager: shortcutManager)
                    .tabItem {
                        VStack {
                            Text("⌨️")
                            Text("shortcuts".localized)
                        }
                    }
                    .tag(1)
                
                // Advanced Tab
                AdvancedSettingsView(settingsManager: settingsManager, shortcutManager: shortcutManager)
                    .tabItem {
                        VStack {
                            Text("🔧")
                            Text("advanced".localized)
                        }
                    }
                    .tag(2)
            }
            .frame(height: 380)
        }
        .frame(width: 500, height: 450)
        .id(refreshID)
        .onReceive(settingsManager.$appLanguage) { _ in
            // Force view refresh when language changes
            let currentTab = selectedTab
            refreshID = UUID()
            // Preserve the current tab selection after refresh
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                selectedTab = currentTab
            }
        }
    }
}

struct GeneralSettingsView: View {
    @ObservedObject var settingsManager: SettingsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Group {
                Toggle("launch_at_login".localized, isOn: $settingsManager.launchAtLogin)
                    .onReceive(settingsManager.$launchAtLogin) { _ in
                        settingsManager.saveAllSettings()
                    }
                Toggle("show_notifications".localized, isOn: $settingsManager.showNotifications)
                    .onReceive(settingsManager.$showNotifications) { _ in
                        settingsManager.saveAllSettings()
                    }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("app_icon".localized)
                    .font(.headline)
                Picker("select_icon".localized, selection: $settingsManager.appIcon) {
                    Text("icon_default".localized).tag("default")
                    Text("icon_folder".localized).tag("folder")
                    Text("icon_terminal".localized).tag("terminal")
                }
                .onReceive(settingsManager.$appIcon) { _ in
                    settingsManager.saveAllSettings()
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("app_language".localized)
                    .font(.headline)
                Picker("select_language".localized, selection: $settingsManager.appLanguage) {
                    Text("lang_chinese".localized).tag("zh-Hans")
                    Text("lang_english".localized).tag("en")
                }
                .onReceive(settingsManager.$appLanguage) { newLanguage in
                    settingsManager.saveAllSettings()
                    // Force UI refresh by updating localization
                    LocalizationManager.shared.setLanguage(LocalizationManager.Language(rawValue: newLanguage) ?? .chineseSimplified)
                    // Notify other views that language has changed
                    NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

struct ShortcutSettingsView: View {
    @ObservedObject var shortcutManager: ShortcutManager
    @State private var showingCopyPathRecordingAlert = false
    @State private var showingTerminalRecordingAlert = false
    @State private var refreshID = UUID()
    @State private var keyMonitor: Any?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("configure_shortcuts".localized)
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 15) {
                HStack {
                    Text("copy_path_shortcut".localized)
                        .frame(width: 120, alignment: .leading)
                    
                    if shortcutManager.isRecordingCopyPathShortcut {
                        Text("recording".localized)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(6)
                            .foregroundColor(.orange)
                    } else {
                        Text(shortcutManager.copyPathShortcut.displayString)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(6)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Button(shortcutManager.isRecordingCopyPathShortcut ? "cancel".localized : "change".localized) {
                        if shortcutManager.isRecordingCopyPathShortcut {
                            shortcutManager.stopRecordingCopyPathShortcut()
                        } else {
                            shortcutManager.startRecordingCopyPathShortcut()
                            setupShortcutRecorder(forCopyPath: true)
                        }
                    }
                    .foregroundColor(shortcutManager.isRecordingCopyPathShortcut ? .orange : .blue)
                }
                
                HStack {
                    Text("open_terminal_shortcut".localized)
                        .frame(width: 120, alignment: .leading)
                    
                    if shortcutManager.isRecordingOpenTerminalShortcut {
                        Text("recording".localized)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange.opacity(0.2))
                            .cornerRadius(6)
                            .foregroundColor(.orange)
                    } else {
                        Text(shortcutManager.openTerminalShortcut.displayString)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(6)
                            .foregroundColor(.primary)
                    }
                    
                    Spacer()
                    
                    Button(shortcutManager.isRecordingOpenTerminalShortcut ? "cancel".localized : "change".localized) {
                        if shortcutManager.isRecordingOpenTerminalShortcut {
                            shortcutManager.stopRecordingOpenTerminalShortcut()
                        } else {
                            shortcutManager.startRecordingOpenTerminalShortcut()
                            setupShortcutRecorder(forCopyPath: false)
                        }
                    }
                    .foregroundColor(shortcutManager.isRecordingOpenTerminalShortcut ? .orange : .blue)
                }
            }
            
            Spacer()
            
            if shortcutManager.isRecordingCopyPathShortcut || shortcutManager.isRecordingOpenTerminalShortcut {
                Text("press_shortcut_hint".localized)
                    .font(.caption)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
            } else {
                Text("shortcut_note".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .id(refreshID)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))) { _ in
            // Force view refresh when language changes
            refreshID = UUID()
        }
        .onReceive(shortcutManager.$isRecordingCopyPathShortcut) { isRecording in
            if isRecording {
                // Setup key monitoring
                keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    if self.shortcutManager.isRecordingCopyPathShortcut {
                        if self.shortcutManager.recordShortcut(event, forCopyPath: true) {
                            self.shortcutManager.saveShortcuts()
                        }
                        return nil // Consume the event
                    }
                    return event // Pass through other key events
                }
            } else {
                // Remove key monitoring
                if let monitor = keyMonitor {
                    NSEvent.removeMonitor(monitor)
                    keyMonitor = nil
                }
            }
        }
        .onReceive(shortcutManager.$isRecordingOpenTerminalShortcut) { isRecording in
            if isRecording {
                // Setup key monitoring
                keyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
                    if self.shortcutManager.isRecordingOpenTerminalShortcut {
                        if self.shortcutManager.recordShortcut(event, forCopyPath: false) {
                            self.shortcutManager.saveShortcuts()
                        }
                        return nil // Consume the event
                    }
                    return event // Pass through other key events
                }
            } else {
                // Remove key monitoring
                if let monitor = keyMonitor {
                    NSEvent.removeMonitor(monitor)
                    keyMonitor = nil
                }
            }
        }
        .onDisappear {
            // Clean up key monitor when view disappears
            if let monitor = keyMonitor {
                NSEvent.removeMonitor(monitor)
                keyMonitor = nil
            }
        }
        .onAppear {
            // Only setup key monitoring if we're actually recording
            // This prevents interference with normal TabView navigation
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))) { _ in
            // Force view refresh when language changes
            refreshID = UUID()
        }
    }
    
    private func setupShortcutRecorder(forCopyPath: Bool) {
        // This will be handled by the key monitor in onAppear
        // The recording state is already set by the button action
    }
}

struct AdvancedSettingsView: View {
    @ObservedObject var settingsManager: SettingsManager
    @ObservedObject var shortcutManager: ShortcutManager
    
    init(settingsManager: SettingsManager, shortcutManager: ShortcutManager) {
        self.settingsManager = settingsManager
        self._shortcutManager = ObservedObject(wrappedValue: shortcutManager)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Group {
                Toggle("debug_mode".localized, isOn: $settingsManager.enableDebugMode)
                    .onReceive(settingsManager.$enableDebugMode) { _ in
                        settingsManager.saveAllSettings()
                    }
                
                HStack {
                    Text("log_level".localized)
                        .font(.headline)
                    Spacer()
                    Picker("select_log_level".localized, selection: $settingsManager.logLevel) {
                        Text("log_error".localized).tag("Error")
                        Text("log_warning".localized).tag("Warning")
                        Text("log_info".localized).tag("Info")
                        Text("log_debug".localized).tag("Debug")
                    }
                    .onReceive(settingsManager.$logLevel) { _ in
                        settingsManager.saveAllSettings()
                    }
                }
                
                HStack {
                    Text(String(format: "max_recent_paths".localized, settingsManager.maxRecentPaths))
                        .font(.headline)
                    Spacer()
                    HStack {
                        Stepper("", value: Binding(
                            get: { settingsManager.maxRecentPaths },
                            set: { newValue in
                                settingsManager.maxRecentPaths = newValue
                                settingsManager.saveAllSettings()
                            }
                        ), in: 5...50, step: 5)
                        Text("\(settingsManager.maxRecentPaths)")
                            .frame(width: 40)
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("recent_paths".localized)
                            .font(.headline)
                        Spacer()
                        if !settingsManager.recentPaths.isEmpty {
                            Button("clear_recent_paths".localized) {
                                settingsManager.recentPaths = []
                            }
                            .font(.caption)
                        }
                    }
                    
                    if settingsManager.recentPaths.isEmpty {
                        Text("no_recent_paths".localized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(Array(settingsManager.recentPaths.enumerated()), id: \.offset) { index, path in
                                    HStack {
                                        Text("\(index + 1).")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .frame(width: 20, alignment: .leading)
                                        Text(path)
                                            .font(.caption)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                            .truncationMode(.middle)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color(NSColor.controlBackgroundColor))
                                    .cornerRadius(4)
                                    .onTapGesture {
                                        // Copy path to clipboard when clicked
                                        NSPasteboard.general.clearContents()
                                        NSPasteboard.general.setString(path, forType: .string)
                                    }
                                }
                            }
                            .padding(.vertical, 2)
                        }
                        .frame(maxHeight: 150)
                    }
                }
            }
            
            Divider()
            
            HStack {
                Button("reset_to_defaults".localized) {
                    settingsManager.resetToDefaults()
                    shortcutManager.resetToDefaults()
                }
                
                Spacer()
                
                Button("save_all".localized) {
                    settingsManager.saveAllSettings()
                    shortcutManager.saveShortcuts()
                }
            }
            
            Spacer()
        }
        .padding()
    }
}