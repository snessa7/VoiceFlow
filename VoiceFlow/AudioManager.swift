import Foundation
import AVFoundation
import Combine

class AudioManager: NSObject, ObservableObject {
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private var audioLevelTimer: Timer?
    
    let audioLevelPublisher = PassthroughSubject<Float, Never>()
    
    override init() {
        super.init()
        setupAudioEngine()
    }
    
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        inputNode = audioEngine?.inputNode
        
        guard let audioEngine = audioEngine,
              let inputNode = inputNode else {
            print("Failed to setup audio engine")
            return
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.processAudioBuffer(buffer)
        }
        
        do {
            try audioEngine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        
        let frameLength = Int(buffer.frameLength)
        var sum: Float = 0.0
        
        for i in 0..<frameLength {
            let sample = channelData[i]
            sum += sample * sample
        }
        
        let rms = sqrt(sum / Float(frameLength))
        let normalizedLevel = min(1.0, rms * 10) // Scale and normalize
        
        DispatchQueue.main.async {
            self.audioLevelPublisher.send(normalizedLevel)
        }
    }
    
    func requestMicrophonePermission() {
        // On macOS, microphone permission is handled automatically by the system
        // when the app first tries to access the microphone
        print("Microphone permission will be requested automatically when needed on macOS")
    }
    
    func startRecording() {
        guard let audioEngine = audioEngine else { return }
        
        if !audioEngine.isRunning {
            do {
                try audioEngine.start()
                startAudioLevelMonitoring()
            } catch {
                print("Failed to start recording: \(error)")
            }
        }
    }
    
    func stopRecording() {
        guard let audioEngine = audioEngine else { return }
        
        if audioEngine.isRunning {
            audioEngine.stop()
            stopAudioLevelMonitoring()
        }
    }
    
    private func startAudioLevelMonitoring() {
        audioLevelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            // Audio level is already being monitored via processAudioBuffer
        }
    }
    
    private func stopAudioLevelMonitoring() {
        audioLevelTimer?.invalidate()
        audioLevelTimer = nil
    }
    
    deinit {
        stopRecording()
        audioLevelTimer?.invalidate()
    }
}
