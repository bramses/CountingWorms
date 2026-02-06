//
//  AIService.swift
//  CountingWorms
//
//  Created by Bram Adams on 2/5/26.
//

import Foundation
import UIKit

struct FoodAnalysisResult {
    let description: String
    let estimatedCalories: Int
}

enum AIServiceError: Error, LocalizedError {
    case invalidAPIKey
    case invalidResponse
    case networkError(Error)
    case invalidImageData
    case apiError(statusCode: Int, message: String)
    
    var errorDescription: String? {
        switch self {
        case .invalidAPIKey:
            return "API key is missing. Please add your API key in Settings."
        case .invalidResponse:
            return "The AI service returned an invalid response. Please try again."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .invalidImageData:
            return "The image data is invalid. Please try taking the photo again."
        case .apiError(let statusCode, let message):
            return "API Error (\(statusCode)): \(message)"
        }
    }
}

class AIService {
    
    // Analyze food image using the configured AI provider
    func analyzeFood(imageData: Data, provider: LLMProvider, apiKey: String) async throws -> FoodAnalysisResult {
        guard !apiKey.isEmpty else {
            throw AIServiceError.invalidAPIKey
        }
        
        switch provider {
        case .openai:
            return try await analyzeWithOpenAI(imageData: imageData, apiKey: apiKey)
        case .claude:
            return try await analyzeWithClaude(imageData: imageData, apiKey: apiKey)
        }
    }
    
    // OpenAI GPT-4 Vision implementation
    private func analyzeWithOpenAI(imageData: Data, apiKey: String) async throws -> FoodAnalysisResult {
        let base64Image = imageData.base64EncodedString()
        
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let prompt = """
        Analyze this food image and provide:
        1. A brief description of the food items
        2. An estimated calorie count for ONE SERVING of the food shown
        
        IMPORTANT: Assume this is one serving. Estimate calories for a single serving of what you see.
        
        Respond in JSON format:
        {
          "description": "Brief food description",
          "calories": estimated_number
        }
        """
        
        let payload: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "text",
                            "text": prompt
                        ],
                        [
                            "type": "image_url",
                            "image_url": [
                                "url": "data:image/jpeg;base64,\(base64Image)"
                            ]
                        ]
                    ]
                ]
            ],
            "max_tokens": 300
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AIServiceError.invalidResponse
            }
            
            if httpResponse.statusCode != 200 {
                // Try to parse error message from response
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = errorJson["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    throw AIServiceError.apiError(statusCode: httpResponse.statusCode, message: message)
                } else {
                    throw AIServiceError.apiError(statusCode: httpResponse.statusCode, message: "Unknown error from API")
                }
            }
            
            return try parseOpenAIResponse(data)
        } catch let error as AIServiceError {
            throw error
        } catch {
            throw AIServiceError.networkError(error)
        }
    }
    
    private func parseOpenAIResponse(_ data: Data) throws -> FoodAnalysisResult {
        struct OpenAIResponse: Codable {
            struct Choice: Codable {
                struct Message: Codable {
                    let content: String
                }
                let message: Message
            }
            let choices: [Choice]
        }
        
        // Try to decode the OpenAI response
        do {
            let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            guard let content = response.choices.first?.message.content else {
                throw AIServiceError.invalidResponse
            }
            
            // Check if AI couldn't see food in the image
            if content.lowercased().contains("unable to access") || 
               content.lowercased().contains("cannot see") ||
               content.lowercased().contains("can't see") {
                throw AIServiceError.apiError(statusCode: 0, message: "The AI couldn't identify food in the image. Please take a clearer photo of food items.")
            }
            
            // Try to parse JSON from the content
            // Strip markdown code blocks if present
            var jsonString = content
            if jsonString.contains("```json") {
                jsonString = jsonString.replacingOccurrences(of: "```json", with: "")
                jsonString = jsonString.replacingOccurrences(of: "```", with: "")
            } else if jsonString.contains("```") {
                jsonString = jsonString.replacingOccurrences(of: "```", with: "")
            }
            jsonString = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if let jsonData = jsonString.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
               let description = json["description"] as? String,
               let calories = json["calories"] as? Int {
                return FoodAnalysisResult(description: description, estimatedCalories: calories)
            }
            
            // Fallback: try to extract information from plain text
            return try parsePlainTextResponse(content)
        } catch let error as AIServiceError {
            throw error
        } catch {
            // Log the raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("DEBUG: OpenAI Response: \(responseString)")
            }
            throw AIServiceError.invalidResponse
        }
    }
    
    // Claude API implementation
    private func analyzeWithClaude(imageData: Data, apiKey: String) async throws -> FoodAnalysisResult {
        let base64Image = imageData.base64EncodedString()
        
        let url = URL(string: "https://api.anthropic.com/v1/messages")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")
        
        let prompt = """
        Analyze this food image and provide:
        1. A brief description of the food items
        2. An estimated calorie count for ONE SERVING of the food shown
        
        IMPORTANT: Assume this is one serving. Estimate calories for a single serving of what you see.
        
        Respond in JSON format:
        {
          "description": "Brief food description",
          "calories": estimated_number
        }
        """
        
        let payload: [String: Any] = [
            "model": "claude-3-5-sonnet-20241022",
            "max_tokens": 300,
            "messages": [
                [
                    "role": "user",
                    "content": [
                        [
                            "type": "image",
                            "source": [
                                "type": "base64",
                                "media_type": "image/jpeg",
                                "data": base64Image
                            ]
                        ],
                        [
                            "type": "text",
                            "text": prompt
                        ]
                    ]
                ]
            ]
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: payload)
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw AIServiceError.invalidResponse
            }
            
            if httpResponse.statusCode != 200 {
                // Try to parse error message from response
                if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let error = errorJson["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    throw AIServiceError.apiError(statusCode: httpResponse.statusCode, message: message)
                } else {
                    throw AIServiceError.apiError(statusCode: httpResponse.statusCode, message: "Unknown error from API")
                }
            }
            
            return try parseClaudeResponse(data)
        } catch let error as AIServiceError {
            throw error
        } catch {
            throw AIServiceError.networkError(error)
        }
    }
    
    private func parseClaudeResponse(_ data: Data) throws -> FoodAnalysisResult {
        struct ClaudeResponse: Codable {
            struct Content: Codable {
                let text: String
            }
            let content: [Content]
        }
        
        // Try to decode the Claude response
        do {
            let response = try JSONDecoder().decode(ClaudeResponse.self, from: data)
            guard let text = response.content.first?.text else {
                throw AIServiceError.invalidResponse
            }
            
            // Try to parse JSON from the content
            // Strip markdown code blocks if present
            var jsonString = text
            if jsonString.contains("```json") {
                jsonString = jsonString.replacingOccurrences(of: "```json", with: "")
                jsonString = jsonString.replacingOccurrences(of: "```", with: "")
            } else if jsonString.contains("```") {
                jsonString = jsonString.replacingOccurrences(of: "```", with: "")
            }
            jsonString = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if let jsonData = jsonString.data(using: .utf8),
               let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
               let description = json["description"] as? String,
               let calories = json["calories"] as? Int {
                return FoodAnalysisResult(description: description, estimatedCalories: calories)
            }
            
            // Fallback: try to extract information from plain text
            return try parsePlainTextResponse(text)
        } catch {
            // Log the raw response for debugging
            if let responseString = String(data: data, encoding: .utf8) {
                print("DEBUG: Claude Response: \(responseString)")
            }
            throw AIServiceError.invalidResponse
        }
    }
    
    // Fallback parser for plain text responses
    private func parsePlainTextResponse(_ text: String) throws -> FoodAnalysisResult {
        print("DEBUG: Attempting to parse plain text: \(text)")
        
        // Try to extract calories using multiple patterns
        let patterns = [
            #"(\d+)\s*(?:cal|kcal|calories)"#,
            #"calories:\s*(\d+)"#,
            #"estimated\s+calories:\s*(\d+)"#,
            #"approximately\s+(\d+)\s*calories"#
        ]
        
        var calories = 0
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                let nsText = text as NSString
                let matches = regex.matches(in: text, range: NSRange(location: 0, length: nsText.length))
                
                if let match = matches.first,
                   match.numberOfRanges > 1,
                   let range = Range(match.range(at: 1), in: text),
                   let extractedCalories = Int(text[range]) {
                    calories = extractedCalories
                    break
                }
            }
        }
        
        // Extract description (first meaningful line)
        let lines = text.components(separatedBy: "\n").filter { !$0.trimmingCharacters(in: .whitespaces).isEmpty }
        let description = lines.first?.trimmingCharacters(in: .whitespaces) ?? "Food item"
        
        guard calories > 0 else {
            print("DEBUG: Could not extract calories from text")
            throw AIServiceError.apiError(statusCode: 0, message: "Could not parse calorie information from AI response. The AI may not have provided calorie data.")
        }
        
        return FoodAnalysisResult(description: description, estimatedCalories: calories)
    }
}
