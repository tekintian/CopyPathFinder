import Foundation
import Cocoa

func getSelectedPath() throws -> String {
    let script = """
    tell application "Finder"
        set theSelection to selection
        set theCount to count of theSelection
        
        if theCount is 0 then
            -- 没有选中项，获取当前 Finder 窗口的路径
            try
                set theWindow to front Finder window
                set theTarget to target of theWindow
                return POSIX path of (theTarget as alias)
            on error
                -- 如果无法获取窗口，返回桌面
                return POSIX path of (path to desktop folder)
            end try
        else
            -- 有选中项，返回第一个选中项的路径
            return POSIX path of (item 1 of theSelection as alias)
        end if
    end tell
    """
    
    let appleScript = NSAppleScript(source: script)
    var error: NSDictionary?
    let result = appleScript?.executeAndReturnError(&error)
    
    // Check if AppleScript execution failed at NSAppleScript level
    if let error = error {
        let errorMessage = error[NSLocalizedDescriptionKey] as? String ?? "Unknown AppleScript error"
        let errorCode = error[NSAppleScript.errorNumber] as? Int ?? -1
        
        // Debug logging
        print("AppleScript NSAppleScript error: \(errorMessage) (code: \(errorCode))")
        
        // Check for specific permission errors
        if errorMessage.contains("Not authorized") || errorMessage.contains("not authorized") ||
           errorMessage.contains("not allowed") || errorMessage.contains("not privileged") ||
           errorCode == -1743 || errorCode == -1719 {
            throw NSError(domain: "PermissionError", code: errorCode, userInfo: [
                NSLocalizedDescriptionKey: "需要 Apple Events 权限。请在系统设置 > 隐私与安全性 > 自动化中允许 CopyPathFinder 控制 Finder。"
            ])
        } else if errorMessage.contains("not running") {
            throw NSError(domain: "FinderError", code: errorCode, userInfo: [
                NSLocalizedDescriptionKey: "Finder 未运行。请确保 Finder 处于运行状态。"
            ])
        } else {
            throw NSError(domain: "ScriptError", code: errorCode, userInfo: [
                NSLocalizedDescriptionKey: "AppleScript 执行失败: \(errorMessage)"
            ])
        }
    }
    
    // Get the path string
    guard let path = result?.stringValue else {
        print("AppleScript returned nil value")
        throw NSError(domain: "ScriptError", code: -2, userInfo: [
            NSLocalizedDescriptionKey: "无法获取选中路径，请确保在 Finder 中选中了文件或文件夹。"
        ])
    }
    
    let trimmedPath = path.trimmingCharacters(in: .whitespacesAndNewlines)
    
    // Debug logging
    print("AppleScript returned: \(trimmedPath)")
    
    // Check if the returned path is valid
    if trimmedPath.isEmpty {
        print("AppleScript returned empty path")
        throw NSError(domain: "ScriptError", code: -3, userInfo: [
            NSLocalizedDescriptionKey: "获取的路径为空，请确保在 Finder 中选中了文件或文件夹。"
        ])
    }
    
    return trimmedPath
}