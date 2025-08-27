# 🎤 VoiceFlow - AI-Powered Voice Transcription for macOS

> A SuperWhisper clone built with SwiftUI, leveraging Apple's native AI capabilities and local LLMs for enhanced transcription quality.

## 🎯 Project Overview

**VoiceFlow** is a native macOS application that provides real-time voice-to-text transcription using Apple's Speech Framework and local AI enhancement via Phi-3.5 model. Inspired by SuperWhisper, it offers privacy-first offline transcription with a clean, SwiftUI-based interface optimized for **macOS 26 beta** and **Xcode 26 beta**.

### Core Features
- **Standard macOS App**: Clean, focused interface without menu bar complexity
- **Offline AI Transcription**: Uses Apple's native Speech framework + local Phi-3.5 model
- **Real-time Processing**: Live transcription with minimal latency
- **Privacy-First**: All processing happens locally on device
- **Multi-language Support**: 100+ languages with automatic detection
- **System Integration**: Clipboard integration, global hotkeys, universal app compatibility
- **SwiftUI Interface**: Modern, accessible, and responsive design
- **Local AI Enhancement**: Phi-3.5 model for post-processing and quality improvement

## 🏗️ Architecture

### Technology Stack
- **Frontend**: SwiftUI with modern macOS design patterns
- **Backend**: Swift with Apple's Speech Framework
- **AI/ML**: Apple's Speech Framework + Phi-3.5 local model via Ollama
- **Development**: **Xcode 26 beta** on **macOS 26 beta**
- **Architecture**: MVVM with Combine for reactive programming

### Key Components
1. **Main Window Scene** - Primary UI interface in standard macOS window
2. **SpeechRecognizer** - Core transcription using Apple's Speech framework
3. **AudioManager** - Audio input/output handling and processing
4. **TranscriptionProcessor** - AI post-processing with Phi-3.5 for enhancement
5. **SettingsManager** - User preferences and configuration
6. **ClipboardManager** - System clipboard integration
7. **HotkeyManager** - Global hotkey registration and management

## 📁 Project Structure

```
VoiceFlow/
├── VoiceFlowApp.swift              # Main app entry point
├── Models/                         # Data models
├── ViewModels/                     # Business logic
│   ├── RecordingViewModel.swift    # Recording state management
│   └── SettingsViewModel.swift     # User preferences
├── Views/                          # UI components
│   ├── ContentView.swift           # Main interface
│   └── SettingsView.swift          # Settings interface
├── Services/                       # Core services
│   ├── AudioManager.swift          # Audio capture and processing
│   ├── SpeechRecognizer.swift      # Apple Speech framework integration
│   ├── TranscriptionProcessor.swift # Phi-3.5 local AI processing
│   ├── ClipboardManager.swift      # System clipboard integration
│   ├── OllamaClient.swift          # Local LLM integration
│   └── HotkeyManager.swift         # Global hotkey management
└── Resources/                      # Assets and config
    ├── Assets.xcassets/            # App icons and images
    └── Info.plist                  # App configuration
```

## 🚀 Getting Started

### Prerequisites
- **macOS 26 beta** or later
- **Xcode 26 beta** or later
- **Ollama** installed with Phi-3.5 model

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/snessa7/VoiceFlow.git
   cd VoiceFlow
   ```

2. Open in Xcode:
   ```bash
   open VoiceFlow.xcodeproj
   ```

3. Build and run the project (⌘+R)

### Ollama Setup
1. Install Ollama: https://ollama.ai
2. Pull the Phi-3.5 model:
   ```bash
   ollama pull phi3.5
   ```

## 🎯 Development Status

### ✅ Completed (Phase 1)
- [x] Xcode project with proper macOS 16.0+ targeting
- [x] Basic macOS app structure with standard window interface
- [x] App permissions and entitlements configuration
- [x] Project structure with Models, Views, ViewModels, Services
- [x] **CRITICAL FIX**: Resolved duplicate directory issue (Shh vs VoiceFlow)
- [x] **CRITICAL FIX**: Updated project structure and file organization
- [x] **CRITICAL FIX**: Fixed macOS 26 beta compatibility issues
- [x] **COMPLETED**: Fixed project build configuration (dynamic library vs app)
- [x] **COMPLETED**: Restructured as proper full macOS app
- [x] **COMPLETED**: Fixed missing file compilation and linking issues

### 🔄 In Progress (Phase 2)
- [ ] Basic audio capture functionality
- [ ] Audio level monitoring and visualization
- [ ] Apple Speech Recognition integration
- [ ] Real-time transcription pipeline
- [ ] **Phi-3.5 local AI integration** for post-processing
- [ ] Basic UI for transcription display

## 🧠 Local AI Integration Strategy

### Phi-3.5 Model Integration
**Goal**: Use Phi-3.5 (3.8B) model for enhanced transcription quality and post-processing.

**Integration Points**:
1. **Post-Processing Pipeline**: Enhance raw transcription with local AI
2. **Grammar Correction**: Fix punctuation, grammar, and structure
3. **Context Understanding**: Improve transcription accuracy
4. **Format Enhancement**: Add proper formatting and structure

### Technical Implementation
```swift
// TranscriptionProcessor.swift
class TranscriptionProcessor: ObservableObject {
    private let ollamaClient: OllamaClient
    
    func enhanceTranscription(_ rawText: String) async -> String {
        // Use Phi-3.5 to enhance transcription quality
        let prompt = """
        Enhance this transcription by:
        1. Adding proper punctuation
        2. Fixing grammar and spelling
        3. Improving sentence structure
        4. Maintaining the original meaning
        
        Raw transcription: \(rawText)
        
        Enhanced version:
        """
        
        return await ollamaClient.generate(prompt: prompt, model: "phi3.5")
    }
}
```

## 🔧 Development Environment
- **macOS**: 26 beta
- **Xcode**: 26 beta
- **Target**: macOS 16.0+
- **Architecture**: Apple Silicon (ARM64)
- **Local AI**: Phi-3.5 via Ollama

## 📝 License

This project is open source and available under the [MIT License](LICENSE).

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📚 References

- [SuperWhisper](https://superwhisper.com) - Inspiration and feature reference
- [Apple Speech Framework](https://developer.apple.com/documentation/speech) - Core transcription engine
- [Ollama](https://ollama.ai) - Local LLM hosting
- [Phi-3.5 Model](https://huggingface.co/microsoft/Phi-3.5) - Local AI enhancement

---

**🎉 SUCCESS**: The app is now functional! Basic macOS app structure is working with clean builds. Ready to proceed with speech recognition implementation and Phi-3.5 integration.