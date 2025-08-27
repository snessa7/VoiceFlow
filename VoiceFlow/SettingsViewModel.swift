import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var selectedLanguage: String = "en-US"
    @Published var enableAIEnhancement: Bool = true
    @Published var autoCopyToClipboard: Bool = true
    @Published var showAudioLevels: Bool = true
    @Published var hotkeyEnabled: Bool = true
    @Published var ollamaModel: String = "phi3.5"
    @Published var ollamaServerURL: String = "http://localhost:11434"
    
    private let userDefaults = UserDefaults.standard
    private let settingsKey = "VoiceFlowSettings"
    
    init() {
        loadSettings()
    }
    
    private func loadSettings() {
        if let data = userDefaults.data(forKey: settingsKey),
           let settings = try? JSONDecoder().decode(Settings.self, from: data) {
            selectedLanguage = settings.selectedLanguage
            enableAIEnhancement = settings.enableAIEnhancement
            autoCopyToClipboard = settings.autoCopyToClipboard
            showAudioLevels = settings.showAudioLevels
            hotkeyEnabled = settings.hotkeyEnabled
            ollamaModel = settings.ollamaModel
            ollamaServerURL = settings.ollamaServerURL
        }
    }
    
    func saveSettings() {
        let settings = Settings(
            selectedLanguage: selectedLanguage,
            enableAIEnhancement: enableAIEnhancement,
            autoCopyToClipboard: autoCopyToClipboard,
            showAudioLevels: showAudioLevels,
            hotkeyEnabled: hotkeyEnabled,
            ollamaModel: ollamaModel,
            ollamaServerURL: ollamaServerURL
        )
        
        if let data = try? JSONEncoder().encode(settings) {
            userDefaults.set(data, forKey: settingsKey)
        }
    }
    
    func resetToDefaults() {
        selectedLanguage = "en-US"
        enableAIEnhancement = true
        autoCopyToClipboard = true
        showAudioLevels = true
        hotkeyEnabled = true
        ollamaModel = "phi3.5"
        ollamaServerURL = "http://localhost:11434"
        
        saveSettings()
    }
    
    var availableLanguages: [Language] {
        return [
            Language(code: "en-US", name: "English (US)"),
            Language(code: "en-GB", name: "English (UK)"),
            Language(code: "es-ES", name: "Spanish"),
            Language(code: "fr-FR", name: "French"),
            Language(code: "de-DE", name: "German"),
            Language(code: "it-IT", name: "Italian"),
            Language(code: "pt-BR", name: "Portuguese (Brazil)"),
            Language(code: "ja-JP", name: "Japanese"),
            Language(code: "ko-KR", name: "Korean"),
            Language(code: "zh-CN", name: "Chinese (Simplified)")
        ]
    }
    
    var availableOllamaModels: [String] {
        return [
            "phi3.5",
            "phi3.5-mini",
            "llama3.1:8b",
            "llama3.1:3b",
            "mistral:7b",
            "gemma:2b"
        ]
    }
}

struct Settings: Codable {
    let selectedLanguage: String
    let enableAIEnhancement: Bool
    let autoCopyToClipboard: Bool
    let showAudioLevels: Bool
    let hotkeyEnabled: Bool
    let ollamaModel: String
    let ollamaServerURL: String
}

struct Language: Identifiable {
    let id = UUID()
    let code: String
    let name: String
}
