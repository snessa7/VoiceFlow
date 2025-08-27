import Foundation
import AppKit

class ClipboardManager {
    static let shared = ClipboardManager()
    
    private init() {}
    
    func copyToClipboard(_ text: String) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        pasteboard.setString(text, forType: .string)
        
        print("Text copied to clipboard: \(text.prefix(50))...")
    }
    
    func getFromClipboard() -> String? {
        let pasteboard = NSPasteboard.general
        return pasteboard.string(forType: .string)
    }
    
    func copyToClipboardWithFormat(_ text: String, format: ClipboardFormat) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        switch format {
        case .plainText:
            pasteboard.setString(text, forType: .string)
        case .richText:
            if let attributedString = createAttributedString(from: text) {
                pasteboard.writeObjects([attributedString])
            } else {
                pasteboard.setString(text, forType: .string)
            }
        case .markdown:
            pasteboard.setString(text, forType: .string)
            // Also set as plain text for compatibility
            pasteboard.setString(text, forType: .string)
        }
        
        print("Formatted text copied to clipboard")
    }
    
    private func createAttributedString(from text: String) -> NSAttributedString? {
        let attributedString = NSMutableAttributedString(string: text)
        
        // Apply basic formatting
        let range = NSRange(location: 0, length: text.count)
        attributedString.addAttribute(.font, value: NSFont.systemFont(ofSize: 12), range: range)
        
        return attributedString
    }
    
    func clearClipboard() {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        print("Clipboard cleared")
    }
    
    func hasClipboardContent() -> Bool {
        let pasteboard = NSPasteboard.general
        return pasteboard.string(forType: .string) != nil
    }
}

enum ClipboardFormat {
    case plainText
    case richText
    case markdown
}
