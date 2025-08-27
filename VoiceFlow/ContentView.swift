import SwiftUI

struct ContentView: View {
    @StateObject private var recordingViewModel = RecordingViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Image(systemName: "mic.fill")
                    .font(.title)
                    .foregroundColor(.blue)
                Text("VoiceFlow")
                    .font(.title2)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding(.horizontal)
            
            // Status Information
            VStack(spacing: 10) {
                // Speech Recognition Status
                HStack {
                    Circle()
                        .fill(recordingViewModel.speechRecognitionAvailable ? Color.green : Color.red)
                        .frame(width: 8, height: 8)
                    Text(recordingViewModel.speechRecognitionAvailable ? "Speech Recognition Available" : "Speech Recognition Unavailable")
                        .font(.caption)
                        .foregroundColor(recordingViewModel.speechRecognitionAvailable ? .green : .red)
                    Spacer()
                }
                .padding(.horizontal)
                
                // Error Message
                if let errorMessage = recordingViewModel.errorMessage {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.orange)
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.orange)
                        Spacer()
                        Button("Dismiss") {
                            recordingViewModel.clearError()
                        }
                        .buttonStyle(PlainButtonStyle())
                        .font(.caption)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
            }
            
            // Recording Status
            VStack(spacing: 10) {
                if recordingViewModel.isRecording {
                    HStack {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 12, height: 12)
                            .scaleEffect(recordingViewModel.audioLevel > 0.1 ? 1.2 : 1.0)
                            .animation(.easeInOut(duration: 0.2), value: recordingViewModel.audioLevel)
                        Text("Recording...")
                            .foregroundColor(.red)
                            .fontWeight(.medium)
                        
                        if recordingViewModel.isProcessing {
                            Spacer()
                            HStack(spacing: 4) {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("Enhancing...")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Audio Level Visualization
                    HStack(spacing: 4) {
                        ForEach(0..<20, id: \.self) { index in
                            Rectangle()
                                .fill(Color.blue)
                                .frame(width: 8, height: max(4, CGFloat(recordingViewModel.audioLevel * 40)))
                                .opacity(index < Int(recordingViewModel.audioLevel * 20) ? 1.0 : 0.3)
                        }
                    }
                    .frame(height: 40)
                } else {
                    HStack {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 12, height: 12)
                        Text("Ready to Record")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Transcription Display
            if !recordingViewModel.transcription.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Transcription")
                            .font(.headline)
                            .foregroundColor(.primary)
                        Spacer()
                        Button("Clear") {
                            recordingViewModel.clearTranscription()
                        }
                        .buttonStyle(PlainButtonStyle())
                        .font(.caption)
                    }
                    
                    ScrollView {
                        Text(recordingViewModel.transcription)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.windowBackgroundColor))
                            .cornerRadius(8)
                    }
                    .frame(maxHeight: 200)
                }
                .padding(.horizontal)
            }
            
            // Control Buttons
            HStack(spacing: 20) {
                Button(action: {
                    if recordingViewModel.isRecording {
                        recordingViewModel.stopRecording()
                    } else {
                        recordingViewModel.startRecording()
                    }
                }) {
                    HStack {
                        Image(systemName: recordingViewModel.isRecording ? "stop.fill" : "mic.fill")
                        Text(recordingViewModel.isRecording ? "Stop" : "Start Recording")
                    }
                    .frame(minWidth: 120)
                    .padding()
                    .background(recordingViewModel.isRecording ? Color.red : Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .buttonStyle(PlainButtonStyle())
                .disabled(!recordingViewModel.speechRecognitionAvailable)
                
                if !recordingViewModel.transcription.isEmpty {
                    Button(action: {
                        recordingViewModel.copyToClipboard()
                    }) {
                        HStack {
                            Image(systemName: "doc.on.clipboard")
                            Text("Copy")
                        }
                        .frame(minWidth: 80)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            
            // Settings Button
            HStack {
                Spacer()
                Button(action: {
                    // Open settings
                }) {
                    Image(systemName: "gear")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.vertical)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            recordingViewModel.requestPermissions()
        }
    }
}
