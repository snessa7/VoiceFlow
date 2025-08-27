import SwiftUI
import AppKit

@main
struct VoiceFlowApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 500, minHeight: 200)
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)
    }
}
