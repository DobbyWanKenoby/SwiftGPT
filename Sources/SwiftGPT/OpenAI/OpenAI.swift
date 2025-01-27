//
//  ChatGPT.swift
//  SwiftGPT
//
//  Created by USOV Vasily on 27.01.2025.
//

import Foundation
import OpenAPIRuntime
#if os(Linux)
    import OpenAPIAsyncHTTPClient
#else
    import OpenAPIURLSession
#endif

public enum OpenAI {}

public extension OpenAI {

    
    /// Default configuration of OpenAI models
    actor Configuration {
        public static var url = "https://api.openai.com/v1"
        public static var apiKey: APIKey = .apiKey("")
    }
    
    enum APIKey: Sendable {
        case apiKey(String)
        case provider(APIKeyProvider)
        
        var value: String {
            get async throws {
                switch self {
                case .apiKey(let string):
                    string
                case .provider(let provider):
                    try await provider.apiKey
                }
            }
        }
    }
    
    protocol APIKeyProvider: Sendable {
        var apiKey: String { get async throws }
    }
}
