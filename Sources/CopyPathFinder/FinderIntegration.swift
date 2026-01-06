import Foundation
import Cocoa

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
        on error errMsg
            return "error:" & errMsg
        end try
    end tell
    """
    
    let appleScript = NSAppleScript(source: script)
    var error: NSDictionary?
    let result = appleScript?.executeAndReturnError(&error)
    
    // Check if AppleScript execution failed
    if let error = error {
        let errorMessage = error[NSLocalizedDescriptionKey] as? String ?? "Unknown AppleScript error"
        let errorCode = error[NSAppleScript.errorNumber] as? Int ?? -1
        
        // Create more specific error messages
        var localizedDescription = "Script Error"
        
        if errorMessage.contains("not authorized") || errorMessage.contains("permission") {
            localizedDescription = "需要授权控制 Finder。请在系统设置 > 隐私与安全性 > 自动化中允许 CopyPathFinder 控制 Finder。"
        } else if errorMessage.contains("not running") {
            localizedDescription = "Finder 未运行。请确保 Finder 处于运行状态。"
        } else if errorMessage.contains("doesn't understand") {
            localizedDescription = "AppleScript 语法错误。"
        } else {
            localizedDescription = "AppleScript 执行失败: \(errorMessage)"
        }
        
        throw NSError(domain: "ScriptError", code: errorCode, userInfo: [
            NSLocalizedDescriptionKey: localizedDescription,
            "OriginalError": errorMessage
        ])
    }
    
    // Check if result contains an error from AppleScript
    guard let path = result?.stringValue else {
        throw NSError(domain: "ScriptError", code: -2, userInfo: [
            NSLocalizedDescriptionKey: "无法获取选中路径，请确保在 Finder 中选中了文件或文件夹。"
        ])
    }
    
    let trimmedPath = path.trimmingCharacters(in: .whitespacesAndNewlines)
    
    // Check if AppleScript returned an error (prefixed with "error:")
    if trimmedPath.hasPrefix("error:") {
        let errorMessage = String(trimmedPath.dropFirst(6))
        
        var localizedDescription = "获取路径失败"
        
        if errorMessage.contains("Not authorized") || errorMessage.contains("permission") || errorMessage.contains("not allowed") {
            localizedDescription = "需要授权控制 Finder。请在系统设置 > 隐私与安全性 > 自动化中允许 CopyPathFinder 控制 Finder。"
        } else if errorMessage.contains("not running") {
            localizedDescription = "Finder 未运行。请确保 Finder 处于运行状态。"
        } else if errorMessage.contains("doesn't understand") {
            localizedDescription = "AppleScript 语法错误。"
        } else {
            localizedDescription = "获取路径失败: \(errorMessage)"
        }
        
        throw NSError(domain: "ScriptError", code: -3, userInfo: [
            NSLocalizedDescriptionKey: localizedDescription,
            "OriginalError": errorMessage
        ])
    }
    
    return trimmedPath
}