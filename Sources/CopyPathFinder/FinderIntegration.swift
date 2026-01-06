import Foundation
import Cocoa

func getSelectedPath() throws -> String {
    let script = """
    try
        tell application "Finder"
            set theSelection to selection
            if theSelection is {} then
                set thePath to (target of front Finder window) as alias
            else
                set thePath to item 1 of theSelection as alias
            end if
            POSIX path of thePath
        end tell
    on error errMsg
        POSIX path of (path to desktop)
    end try
    """
    
    let appleScript = NSAppleScript(source: script)
    var error: NSDictionary?
    let result = appleScript?.executeAndReturnError(&error)
    
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
    } else if let path = result?.stringValue {
        return path.trimmingCharacters(in: .whitespacesAndNewlines)
    } else {
        throw NSError(domain: "ScriptError", code: -2, userInfo: [
            NSLocalizedDescriptionKey: "无法获取选中路径，请确保在 Finder 中选中了文件或文件夹。"
        ])
    }
}