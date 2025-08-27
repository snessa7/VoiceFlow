import Foundation
import Speech
import Combine
import AVFoundation

class SpeechRecognizer: NSObject, ObservableObject {
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    let transcriptionPublisher = PassthroughSubject<String, Never>()
    let isAvailablePublisher = PassthroughSubject<Bool, Never>()
    
    override init() {
        super.init()
        speechRecognizer?.delegate = self
        checkAvailability()
    }
    
    private func checkAvailability() {
        let isAvailable = speechRecognizer?.isAvailable ?? false
        isAvailablePublisher.send(isAvailable)
    }
    
    func requestSpeechRecognitionPermission() {
        SFSpeechRecognizer.requestAuthorization { [weak self] authStatus in
            DispatchQueue.main.async {
                switch authStatus {
                case .authorized:
                    print("Speech recognition authorized")
                    self?.checkAvailability()
                case .denied:
                    print("Speech recognition denied")
                    self?.isAvailablePublisher.send(false)
                case .restricted:
                    print("Speech recognition restricted")
                    self?.isAvailablePublisher.send(false)
                case .notDetermined:
                    print("Speech recognition not determined")
                    self?.isAvailablePublisher.send(false)
                @unknown default:
                    print("Speech recognition unknown status")
                    self?.isAvailablePublisher.send(false)
                }
            }
        }
    }
    
    func startRecognition() {
        guard let speechRecognizer = speechRecognizer,
              speechRecognizer.isAvailable else {
            print("Speech recognizer not available")
            return
        }
        
        // Cancel any existing recognition task
        if let recognitionTask = recognitionTask {
            recognitionTask.cancel()
            self.recognitionTask = nil
        }
        
        // Create recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            print("Failed to create recognition request")
            return
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        // Start recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            if let error = error {
                print("Recognition error: \(error)")
                return
            }
            
            if let result = result {
                let transcribedText = result.bestTranscription.formattedString
                DispatchQueue.main.async {
                    self?.transcriptionPublisher.send(transcribedText)
                }
            }
        }
        
        // Configure audio input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        
        // Start audio engine
        do {
            audioEngine.prepare()
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    func stopRecognition() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        
        recognitionTask?.cancel()
        recognitionTask = nil
    }
    
    func isRecognitionActive() -> Bool {
        return audioEngine.isRunning
    }
}

extension SpeechRecognizer: SFSpeechRecognizerDelegate {
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        DispatchQueue.main.async {
            self.isAvailablePublisher.send(available)
        }
        
        if !available {
            print("Speech recognizer became unavailable")
        }
    }
}
