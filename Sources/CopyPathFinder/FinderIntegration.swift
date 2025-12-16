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