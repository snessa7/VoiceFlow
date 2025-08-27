import Foundation
import AVFoundation
import Speech
import Combine

@MainActor
class RecordingViewModel: ObservableObject {
    @Published var isRecording = false
    @Published var transcription = ""
    @Published var audioLevel: Float = 0.0
    @Published var isProcessing = false
    @Published var speechRecognitionAvailable = false
    @Published var errorMessage: String?
    
    private var audioManager: AudioManager?
    private var speechRecognizer: SpeechRecognizer?
    private var transcriptionProcessor: TranscriptionProcessor?
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupAudioManager()
        setupSpeechRecognizer()
        setupTranscriptionProcessor()
    }
    
    private func setupAudioManager() {
        audioManager = AudioManager()
        audioManager?.audioLevelPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.audioLevel, on: self)
            .store(in: &cancellables)
    }
    
    private func setupSpeechRecognizer() {
        speechRecognizer = SpeechRecognizer()
        
        // Subscribe to transcription updates
        speechRecognizer?.transcriptionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                self?.handleTranscription(text)
            }
            .store(in: &cancellables)
        
        // Subscribe to availability updates
        speechRecognizer?.isAvailablePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.speechRecognitionAvailable, on: self)
            .store(in: &cancellables)
    }
    
    private func setupTranscriptionProcessor() {
        transcriptionProcessor = TranscriptionProcessor()
    }
    
    func requestPermissions() {
        audioManager?.requestMicrophonePermission()
        speechRecognizer?.requestSpeechRecognitionPermission()
    }
    
    func startRecording() {
        guard !isRecording else { return }
        guard speechRecognitionAvailable else {
            errorMessage = "Speech recognition is not available. Please check your permissions and try again."
            return
        }
        
        isRecording = true
        transcription = ""
        errorMessage = nil
        
        // Start audio level monitoring
        audioManager?.startAudioLevelMonitoring()
        
        // Start speech recognition
        speechRecognizer?.startRecognition()
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        isRecording = false
        
        // Stop audio level monitoring
        audioManager?.stopAudioLevelMonitoring()
        
        // Stop speech recognition
        speechRecognizer?.stopRecognition()
        
        // Process final transcription with AI enhancement
        if !transcription.isEmpty {
            enhanceTranscription()
        }
    }
    
    private func handleTranscription(_ text: String) {
        transcription = text
    }
    
    private func enhanceTranscription() {
        guard !transcription.isEmpty else { return }
        
        isProcessing = true
        
        Task {
            do {
                let enhancedText = try await transcriptionProcessor?.enhanceTranscription(transcription) ?? transcription
                
                await MainActor.run {
                    self.transcription = enhancedText
                    self.isProcessing = false
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = "Failed to enhance transcription: \(error.localizedDescription)"
                    self.isProcessing = false
                }
            }
        }
    }
    
    func copyToClipboard() {
        ClipboardManager.shared.copyToClipboard(transcription)
    }
    
    func clearTranscription() {
        transcription = ""
        errorMessage = nil
    }
    
    func clearError() {
        errorMessage = nil
    }
}
