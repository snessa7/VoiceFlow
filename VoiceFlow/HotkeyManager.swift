import Foundation
import Carbon
import AppKit

class HotkeyManager {
    static let shared = HotkeyManager()
    
    private var hotkeyRef: EventHotKeyRef?
    private let hotkeyID = EventHotKeyID(signature: OSType("VFHK".utf8.reduce(0) { ($0 << 8) + OSType($1) }), id: 1)
    
    private init() {}
    
    func registerHotkey() {
        // Register for hotkey events
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))
        
        InstallEventHandler(GetApplicationEventTarget(), { (nextHandler, theEvent, userData) -> OSStatus in
            HotkeyManager.shared.handleHotkey()
            return noErr
        }, 1, &eventType, nil, nil)
        
        // Register the hotkey (Cmd+Shift+Space)
        let modifiers = UInt32(cmdKey | shiftKey)
        let keyCode = UInt32(kVK_Space)
        
        let status = RegisterEventHotKey(keyCode, modifiers, hotkeyID, GetApplicationEventTarget(), 0, &hotkeyRef)
        
        if status == noErr {
            print("Global hotkey registered successfully")
        } else {
            print("Failed to register global hotkey: \(status)")
        }
    }
    
    func unregisterHotkey() {
        if let hotkeyRef = hotkeyRef {
            UnregisterEventHotKey(hotkeyRef)
            self.hotkeyRef = nil
            print("Global hotkey unregistered")
        }
    }
    
    @objc func handleHotkey() {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .hotkeyPressed, object: nil)
        }
    }
    
    deinit {
        unregisterHotkey()
    }
}

extension Notification.Name {
    static let hotkeyPressed = Notification.Name("hotkeyPressed")
}
