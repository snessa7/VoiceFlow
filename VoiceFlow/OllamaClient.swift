import Foundation
import Combine

class OllamaClient: ObservableObject {
    private let baseURL = "http://localhost:11434"
    private let session = URLSession.shared
    
    func generate(prompt: String, model: String = "phi3.5") async throws -> String {
        let url = URL(string: "\(baseURL)/api/generate")!
        
        let requestBody = GenerateRequest(
            model: model,
            prompt: prompt,
            stream: false,
            options: GenerateOptions(
                temperature: 0.7,
                topP: 0.9,
                topK: 40,
                numPredict: 1000
            )
        )
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            throw OllamaError.encodingError(error)
        }
        
        do {
            let (data, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw OllamaError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw OllamaError.httpError(httpResponse.statusCode)
            }
            
            let generateResponse = try JSONDecoder().decode(GenerateResponse.self, from: data)
            return generateResponse.response
        } catch {
            if error is OllamaError {
                throw error
            }
            throw OllamaError.networkError(error)
        }
    }
    
    func isModelAvailable(_ model: String) async -> Bool {
        let url = URL(string: "\(baseURL)/api/tags")!
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return false
            }
            
            let tagsResponse = try JSONDecoder().decode(TagsResponse.self, from: data)
            return tagsResponse.models.contains { $0.name == model }
        } catch {
            return false
        }
    }
    
    func downloadModel(_ model: String) async throws {
        let url = URL(string: "\(baseURL)/api/pull")!
        
        let requestBody = PullRequest(name: model)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            request.httpBody = try JSONEncoder().encode(requestBody)
        } catch {
            throw OllamaError.encodingError(error)
        }
        
        do {
            let (_, response) = try await session.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw OllamaError.invalidResponse
            }
            
            guard httpResponse.statusCode == 200 else {
                throw OllamaError.httpError(httpResponse.statusCode)
            }
        } catch {
            if error is OllamaError {
                throw error
            }
            throw OllamaError.networkError(error)
        }
    }
}

// MARK: - Request/Response Models

struct GenerateRequest: Codable {
    let model: String
    let prompt: String
    let stream: Bool
    let options: GenerateOptions
}

struct GenerateOptions: Codable {
    let temperature: Double
    let topP: Double
    let topK: Int
    let numPredict: Int
}

struct GenerateResponse: Codable {
    let model: String
    let response: String
    let done: Bool
}

struct PullRequest: Codable {
    let name: String
}

struct TagsResponse: Codable {
    let models: [ModelInfo]
}

struct ModelInfo: Codable {
    let name: String
    let size: Int64
    let modifiedAt: String
}

// MARK: - Error Types

enum OllamaError: Error, LocalizedError {
    case networkError(Error)
    case encodingError(Error)
    case invalidResponse
    case httpError(Int)
    case modelNotFound
    
    var errorDescription: String? {
        switch self {
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .encodingError(let error):
            return "Encoding error: \(error.localizedDescription)"
        case .invalidResponse:
            return "Invalid response from Ollama server"
        case .httpError(let statusCode):
            return "HTTP error: \(statusCode)"
        case .modelNotFound:
            return "Model not found or not available"
        }
    }
}
