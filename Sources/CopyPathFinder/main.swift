import Cocoa
import SwiftUI

// Main entry point
print("Starting CopyPathFinder...")
let app = NSApplication.shared

// Set activation policy before creating delegate
app.setActivationPolicy(.accessory)

// Create delegate
let delegate = AppDelegate()
app.delegate = delegate

print("Delegate created, running app...")
app.run()