//
//  Models.swift
//  
//
//  Created by Alfian Losari on 02/03/23.
//

import Foundation

public extension OpenAI {
    
    struct ChatCompletionsHistoryMessage: Codable, Sendable {
        public let role: Role
        public let content: String
        public let name: String?
        
        public init(role: Role, content: String, name: String? = nil) {
            self.role = role
            self.content = content
            self.name = name
        }
        
        public enum Role: String, Codable, Sendable {
            case user
            case assistant
        }
    }
    
    struct Request: Codable {
        let model: String
        let temperature: Double
        let messages: [ChatCompletionsHistoryMessage]
        let stream: Bool
    }

}
