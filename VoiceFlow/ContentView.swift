import SwiftUI

struct ContentView: View {
    @StateObject private var recordingViewModel = RecordingViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    var body: some View {
        VStack(spacing: 12) {
            // Header - More compact
            HStack {
                Image(systemName: "mic.fill")
                    .font(.title2)
                    .foregroundColor(.blue)
                Text("VoiceFlow")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
                
                // Clear button moved to top right
                Button("Clear") {
                    recordingViewModel.clearTranscription()
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            // Status Information - More compact
            VStack(spacing: 6) {
                // Speech Recognition Status
                HStack(spacing: 8) {
                    Circle()
                        .fill(recordingViewModel.speechRecognitionAvailable ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(recordingViewModel.speechRecognitionAvailable ? "Speech Recognition Available" : "Speech Recognition Unavailable")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                
                // Recording Status
                HStack(spacing: 8) {
                    Circle()
                        .fill(recordingViewModel.isRecording ? Color.red : Color.gray)
                        .frame(width: 8, height: 8)
                    Text(recordingViewModel.isRecording ? "Recording..." : "Ready to Record")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding(.horizontal, 16)
            
            // Audio Level Indicator - Compact
            if recordingViewModel.isRecording {
                HStack(spacing: 8) {
                    Text("Audio Level:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.blue)
                        .frame(width: max(20, CGFloat(recordingViewModel.audioLevel) * 100), height: 8)
                        .animation(.easeInOut(duration: 0.1), value: recordingViewModel.audioLevel)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
            
            // Transcription Area - More compact
            VStack(alignment: .leading, spacing: 4) {
                Text("Transcription")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                ScrollView {
                    Text(recordingViewModel.transcription.isEmpty ? "Start recording to see transcription here..." : recordingViewModel.transcription)
                        .font(.body)
                        .foregroundColor(recordingViewModel.transcription.isEmpty ? .secondary : .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(12)
                        .background(Color(.textBackgroundColor))
                        .cornerRadius(8)
                }
                .frame(maxHeight: 200) // Limit height to fit window
            }
            .padding(.horizontal, 16)
            
            // Error Message - Compact
            if let errorMessage = recordingViewModel.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text(errorMessage)
                        .font(.caption)
                        .foregroundColor(.orange)
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(6)
                .padding(.horizontal, 16)
            }
            
            // Processing Status - Compact
            if recordingViewModel.isProcessing {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Processing with AI...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
            }
            
            Spacer(minLength: 8)
            
            // Action Buttons - More compact
            HStack(spacing: 16) {
                Button(action: {
                    if recordingViewModel.isRecording {
                        recordingViewModel.stopRecording()
                    } else {
                        recordingViewModel.startRecording()
                    }
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: recordingViewModel.isRecording ? "stop.fill" : "mic.fill")
                            .font(.system(size: 14))
                        Text(recordingViewModel.isRecording ? "Stop Recording" : "Start Recording")
                            .font(.system(size: 14, weight: .medium))
                    }
                    .frame(minWidth: 120)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.regular)
                .disabled(!recordingViewModel.speechRecognitionAvailable)
                
                Button("Copy") {
                    recordingViewModel.copyToClipboard()
                }
                .buttonStyle(.bordered)
                .controlSize(.regular)
                .disabled(recordingViewModel.transcription.isEmpty)
            }
            .padding(.bottom, 16)
        }
        .frame(minWidth: 500, minHeight: 400)
        .background(Color(.windowBackgroundColor))
    }
}
