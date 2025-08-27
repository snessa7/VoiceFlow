import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                // Language Settings
                Section("Speech Recognition") {
                    Picker("Language", selection: $viewModel.selectedLanguage) {
                        ForEach(viewModel.availableLanguages) { language in
                            Text(language.name).tag(language.code)
                        }
                    }
                    .onChange(of: viewModel.selectedLanguage) { oldValue, newValue in
                        viewModel.saveSettings()
                    }
                }
                
                // AI Enhancement Settings
                Section("AI Enhancement") {
                    Toggle("Enable AI Enhancement", isOn: $viewModel.enableAIEnhancement)
                        .onChange(of: viewModel.enableAIEnhancement) { oldValue, newValue in
                            viewModel.saveSettings()
                        }
                    
                    if viewModel.enableAIEnhancement {
                        Picker("Ollama Model", selection: $viewModel.ollamaModel) {
                            ForEach(viewModel.availableOllamaModels, id: \.self) { model in
                                Text(model).tag(model)
                            }
                        }
                        .onChange(of: viewModel.ollamaModel) { oldValue, newValue in
                            viewModel.saveSettings()
                        }
                        
                        TextField("Ollama Server URL", text: $viewModel.ollamaServerURL)
                            .onChange(of: viewModel.ollamaServerURL) { oldValue, newValue in
                                viewModel.saveSettings()
                            }
                    }
                }
                
                // User Experience Settings
                Section("User Experience") {
                    Toggle("Auto-copy to Clipboard", isOn: $viewModel.autoCopyToClipboard)
                        .onChange(of: viewModel.autoCopyToClipboard) { oldValue, newValue in
                            viewModel.saveSettings()
                        }
                    
                    Toggle("Show Audio Levels", isOn: $viewModel.showAudioLevels)
                        .onChange(of: viewModel.showAudioLevels) { oldValue, newValue in
                            viewModel.saveSettings()
                        }
                    
                    Toggle("Enable Global Hotkey", isOn: $viewModel.hotkeyEnabled)
                        .onChange(of: viewModel.hotkeyEnabled) { oldValue, newValue in
                            viewModel.saveSettings()
                        }
                }
                
                // Actions
                Section {
                    Button("Reset to Defaults") {
                        viewModel.resetToDefaults()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 400, height: 500)
    }
}

#Preview {
    SettingsView(viewModel: SettingsViewModel())
}
