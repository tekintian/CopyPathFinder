import Foundation

public enum QuickToggleType: String, CaseIterable {
    case copyPath
    case copyFileName
    case openInTerminal
    
    public var name: String {
        switch self {
        case .copyPath:
            return "quick_toggle_copy_path".localized
        case .copyFileName:
            return "quick_toggle_copy_file_name".localized
        case .openInTerminal:
            return "quick_toggle_open_terminal".localized
        }
    }
    
    public var action: Selector {
        switch self {
        case .copyPath:
            return #selector(AppDelegate.copySelectedPath)
        case .copyFileName:
            return #selector(AppDelegate.copyFileName)
        case .openInTerminal:
            return #selector(AppDelegate.openInTerminal)
        }
    }
}