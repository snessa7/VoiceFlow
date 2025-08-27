import Foundation
import Combine

class TranscriptionProcessor: ObservableObject {
    private let ollamaClient: OllamaClient
    
    init() {
        self.ollamaClient = OllamaClient()
    }
    
    func enhanceTranscription(_ rawText: String) async throws -> String {
        guard !rawText.isEmpty else { return rawText }
        
        let enhancedText = try await ollamaClient.generate(
            prompt: createEnhancementPrompt(for: rawText),
            model: "phi3.5"
        )
        
        return enhancedText.isEmpty ? rawText : enhancedText
    }
    
    private func createEnhancementPrompt(for text: String) -> String {
        return """
        You are a professional transcription editor. Enhance the following raw transcription by:
        
        1. Adding proper punctuation (periods, commas, question marks, etc.)
        2. Fixing obvious grammar and spelling errors
        3. Improving sentence structure and flow
        4. Adding paragraph breaks where appropriate
        5. Maintaining the original meaning and intent
        6. Preserving any technical terms or proper nouns
        
        Raw transcription:
        "\(text)"
        
        Enhanced version:
        """
    }
    
    func summarizeTranscription(_ text: String) async throws -> String {
        guard !text.isEmpty else { return text }
        
        let summary = try await ollamaClient.generate(
            prompt: createSummaryPrompt(for: text),
            model: "phi3.5"
        )
        
        return summary.isEmpty ? text : summary
    }
    
    private func createSummaryPrompt(for text: String) -> String {
        return """
        Create a concise summary of the following transcription, highlighting the key points and main ideas:
        
        Transcription:
        "\(text)"
        
        Summary:
        """
    }
    
    func formatTranscription(_ text: String, format: TranscriptionFormat) async throws -> String {
        guard !text.isEmpty else { return text }
        
        let formattedText = try await ollamaClient.generate(
            prompt: createFormattingPrompt(for: text, format: format),
            model: "phi3.5"
        )
        
        return formattedText.isEmpty ? text : formattedText
    }
    
    private func createFormattingPrompt(for text: String, format: TranscriptionFormat) -> String {
        let formatInstructions = format.instructions
        
        return """
        Format the following transcription according to these requirements:
        
        \(formatInstructions)
        
        Transcription:
        "\(text)"
        
        Formatted version:
        """
    }
}

enum TranscriptionFormat {
    case plainText
    case markdown
    case structured
    case meetingMinutes
    
    var instructions: String {
        switch self {
        case .plainText:
            return "Convert to clean, readable plain text with proper paragraphs and spacing."
        case .markdown:
            return "Convert to Markdown format with appropriate headers, lists, and emphasis."
        case .structured:
            return "Organize into clear sections with headers, bullet points, and structured format."
        case .meetingMinutes:
            return "Format as meeting minutes with date, attendees, agenda items, and action items."
        }
    }
}
