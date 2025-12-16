import Cocoa
import SwiftUI

struct ShortcutConfiguration: Codable {
    let keyCode: Int
    let modifiers: UInt
    
    init(keyCode: Int, modifiers: UInt) {
        self.keyCode = keyCode
        self.modifiers = modifiers
    }
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.keyCode = try container.decode(Int.self)
        self.modifiers = try container.decode(UInt.self)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(keyCode)
        try container.encode(modifiers)
    }
    
    func matches(event: NSEvent) -> Bool {
        return event.keyCode == keyCode && 
               NSEvent.ModifierFlags(rawValue: modifiers).intersection(event.modifierFlags).rawValue == modifiers
    }
    
    var displayString: String {
        var parts: [String] = []
        
        if (modifiers & NSEvent.ModifierFlags.command.rawValue) != 0 {
            parts.append("⌘")
        }
        if (modifiers & NSEvent.ModifierFlags.option.rawValue) != 0 {
            parts.append("⌥")
        }
        if (modifiers & NSEvent.ModifierFlags.control.rawValue) != 0 {
            parts.append("⌃")
        }
        if (modifiers & NSEvent.ModifierFlags.shift.rawValue) != 0 {
            parts.append("⇧")
        }
        
        let keyName = keyCodeToString(keyCode)
        parts.append(keyName)
        
        return parts.joined()
    }
    
    private func keyCodeToString(_ code: Int) -> String {
        switch code {
        case 0: return "A"
        case 1: return "S"
        case 2: return "D"
        case 3: return "F"
        case 4: return "H"
        case 5: return "G"
        case 6: return "Z"
        case 7: return "X"
        case 8: return "C"
        case 9: return "V"
        case 11: return "B"
        case 12: return "Q"
        case 13: return "W"
        case 14: return "E"
        case 15: return "R"
        case 16: return "Y"
        case 17: return "T"
        case 18: return "1"
        case 19: return "2"
        case 20: return "3"
        case 21: return "4"
        case 22: return "6"
        case 23: return "5"
        case 24: return "="
        case 25: return "9"
        case 26: return "7"
        case 27: return "-"
        case 28: return "8"
        case 29: return "0"
        case 30: return "]"
        case 31: return "O"
        case 32: return "U"
        case 33: return "["
        case 34: return "I"
        case 35: return "P"
        case 36: return "Return"
        case 37: return "L"
        case 38: return "J"
        case 39: return "'"
        case 40: return "K"
        case 41: return ";"
        case 42: return "\\"
        case 43: return ","
        case 44: return "/"
        case 45: return "N"
        case 46: return "M"
        case 47: return "."
        case 48: return "Tab"
        case 49: return "Space"
        case 50: return "`"
        case 51: return "Delete"
        case 52: return "Enter"
        case 53: return "Esc"
        default: return "?"
        }
    }
}

class ShortcutManager: ObservableObject {
    @Published var copyPathShortcut: ShortcutConfiguration = ShortcutConfiguration(keyCode: 8, modifiers: NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue)
    @Published var openTerminalShortcut: ShortcutConfiguration = ShortcutConfiguration(keyCode: 17, modifiers: NSEvent.ModifierFlags.command.rawValue | NSEvent.ModifierFlags.shift.rawValue) // T key
    @Published var isRecordingCopyPathShortcut = false
    @Published var isRecordingOpenTerminalShortcut = false
    
    private let userDefaults = UserDefaults.standard
    private let copyPathKey = "CopyPathShortcut"
    private let openTerminalKey = "OpenTerminalShortcut"
    
    init() {
        loadShortcuts()
        print("ShortcutManager initialized")
    }
    
    func loadShortcuts() {
        if let data = userDefaults.data(forKey: copyPathKey),
           let shortcut = try? JSONDecoder().decode(ShortcutConfiguration.self, from: data) {
            copyPathShortcut = shortcut
        }
        
        if let data = userDefaults.data(forKey: openTerminalKey),
           let shortcut = try? JSONDecoder().decode(ShortcutConfiguration.self, from: data) {
            openTerminalShortcut = shortcut
        }
    }
    
    func saveShortcuts() {
        if let data = try? JSONEncoder().encode(copyPathShortcut) {
            userDefaults.set(data, forKey: copyPathKey)
        }
        
        if let data = try? JSONEncoder().encode(openTerminalShortcut) {
            userDefaults.set(data, forKey: openTerminalKey)
        }
    }
    
    func matchesCopyPathShortcut(_ event: NSEvent) -> Bool {
        return copyPathShortcut.matches(event: event)
    }
    
    func matchesOpenTerminalShortcut(_ event: NSEvent) -> Bool {
        return openTerminalShortcut.matches(event: event)
    }
    
    func startRecordingCopyPathShortcut() {
        isRecordingCopyPathShortcut = true
    }
    
    func startRecordingOpenTerminalShortcut() {
        isRecordingOpenTerminalShortcut = true
    }
    
    func stopRecordingCopyPathShortcut() {
        isRecordingCopyPathShortcut = false
    }
    
    func stopRecordingOpenTerminalShortcut() {
        isRecordingOpenTerminalShortcut = false
    }
    
    func recordShortcut(_ event: NSEvent, forCopyPath: Bool = true) -> Bool {
        // Ignore if no modifiers are pressed (to avoid conflicts with normal typing)
        guard event.modifierFlags.contains(.command) || 
              event.modifierFlags.contains(.control) ||
              event.modifierFlags.contains(.option) else {
            return false
        }
        
        // Don't allow modifier-only shortcuts
        guard event.keyCode != 54 && event.keyCode != 55 && event.keyCode != 56 && event.keyCode != 57 else {
            return false
        }
        
        let newShortcut = ShortcutConfiguration(
            keyCode: Int(event.keyCode),
            modifiers: event.modifierFlags.intersection([.command, .option, .control, .shift]).rawValue
        )
        
        if forCopyPath {
            copyPathShortcut = newShortcut
            isRecordingCopyPathShortcut = false
        } else {
            openTerminalShortcut = newShortcut
            isRecordingOpenTerminalShortcut = false
        }
        
        return true
    }
}