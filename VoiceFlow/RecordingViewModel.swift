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
        speechRecognizer?.transcriptionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                self?.handleTranscription(text)
            }
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
        
        isRecording = true
        transcription = ""
        
        audioManager?.startRecording()
        speechRecognizer?.startRecognition()
    }
    
    func stopRecording() {
        guard isRecording else { return }
        
        isRecording = false
        
        audioManager?.stopRecording()
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
            let enhancedText = await transcriptionProcessor?.enhanceTranscription(transcription) ?? transcription
            
            await MainActor.run {
                self.transcription = enhancedText
                self.isProcessing = false
            }
        }
    }
    
    func copyToClipboard() {
        ClipboardManager.shared.copyToClipboard(transcription)
    }
    
    func clearTranscription() {
        transcription = ""
    }
}
