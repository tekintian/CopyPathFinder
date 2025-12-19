import SwiftUI

struct QuickToggleSettingsView: View {
    @ObservedObject var settingsManager: SettingsManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Quick Toggle 开关
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Toggle("quick_toggle_enable".localized, isOn: $settingsManager.isQuickToggle)
                        .onReceive(settingsManager.$isQuickToggle) { _ in
                            settingsManager.saveAllSettings()
                        }
                    Spacer()
                }
                
                Text("quick_toggle_description".localized)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            // Quick Toggle 类型选择
            if settingsManager.isQuickToggle {
                VStack(alignment: .leading, spacing: 8) {
                    Text("quick_toggle_action".localized)
                        .font(.headline)
                    
                    Picker("select_action".localized, selection: $settingsManager.quickToggleType) {
                        ForEach(QuickToggleType.allCases, id: \.self) { type in
                            Text(type.name).tag(type)
                        }
                    }
                    .onReceive(settingsManager.$quickToggleType) { _ in
                        settingsManager.saveAllSettings()
                    }
                    
                    Text("quick_toggle_action_description".localized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding()
    }
}