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
                    Text("Transcription")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
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
