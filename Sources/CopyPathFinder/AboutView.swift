import SwiftUI

struct AboutView: View {
    var onClose: () -> Void
    @State private var refreshID = UUID()
    
    var body: some View {
        VStack(spacing: 20) {
            Text("app_name".localized)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("app_description".localized)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Divider()
            
            VStack(spacing: 12) {
                HStack {
                    Text("author".localized + ":")
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("tekintian@gmail.com")
                }
                
                HStack {
                    Text("website".localized + ":")
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("https://dev.tekin.cn") {
                        if let url = URL(string: "https://dev.tekin.cn") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .foregroundColor(.blue)
                }
                
                HStack {
                    Text("github".localized + ":")
                        .foregroundColor(.secondary)
                    Spacer()
                    Button("https://github.com/tekintian/CopyPathFinder") {
                        if let url = URL(string: "https://github.com/tekintian/CopyPathFinder") {
                            NSWorkspace.shared.open(url)
                        }
                    }
                    .foregroundColor(.blue)
                }
            }
            
            Spacer()
            
            Button("close".localized, action: onClose)
                .frame(maxWidth: .infinity)
        }
        .padding()
        .frame(width: 400, height: 300)
        .id(refreshID)
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))) { _ in
            // Force view refresh when language changes
            refreshID = UUID()
        }
    }
}