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
    }
    
    func requestMicrophonePermission() {
        // On macOS, microphone permission is handled automatically by the system
        // when the app first tries to access the microphone
        print("Microphone permission will be requested automatically when needed on macOS")
    }
    
    func startAudioLevelMonitoring() {
        guard audioEngine == nil else { return }
        
        audioEngine = AVAudioEngine()
        inputNode = audioEngine?.inputNode
        
        guard let audioEngine = audioEngine,
              let inputNode = inputNode else {
            print("Failed to setup audio engine for level monitoring")
            return
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.processAudioBuffer(buffer)
        }
        
        do {
            try audioEngine.start()
            startAudioLevelTimer()
        } catch {
            print("Failed to start audio engine for level monitoring: \(error)")
        }
    }
    
    func stopAudioLevelMonitoring() {
        audioEngine?.stop()
        audioEngine?.inputNode.removeTap(onBus: 0)
        audioEngine = nil
        inputNode = nil
        stopAudioLevelTimer()
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
    
    private func startAudioLevelTimer() {
        audioLevelTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            // Audio level is already being monitored via processAudioBuffer
        }
    }
    
    private func stopAudioLevelTimer() {
        audioLevelTimer?.invalidate()
        audioLevelTimer = nil
    }
    
    deinit {
        stopAudioLevelMonitoring()
    }
}
