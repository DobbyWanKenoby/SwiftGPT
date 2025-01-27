//
//  Models.swift
//  
//
//  Created by Alfian Losari on 02/03/23.
//

import Foundation

public extension OpenAI {
    
     struct ChatGPTModel {
         public let gpt_3_5_turbo = Model(ChatCompetionConfigurationGPT3Series.self, .gpt3_5Turbo)
         public let gpt_4 = Model(ChatCompetionConfigurationGPT4Series.self, .gpt4)
         public let gpt_4_turbo = Model(ChatCompetionConfigurationGPT4Series.self, .gpt4Turbo)
         public let gpt_4o = Model(ChatCompetionConfigurationGPT4Series.self, .gpt4o)
         public let gpt_4o_latest = Model(ChatCompetionConfigurationGPT4Series.self, .chatgpt4oLatest)
         public let gpt_4o_mini = Model(ChatCompetionConfigurationGPT4Series.self, .gpt4oMini)
         public let gpt_o1 = Model(ChatCompetionConfigurationGPTo1Series.self, .o1)
         public let gpt_o1_mini = Model(ChatCompetionConfigurationGPTo1Series.self, .o1Mini)
         public let gpt_o1_preview = Model(ChatCompetionConfigurationGPTo1Series.self, .o1Preview)
 
        public struct Model<Configuration> {
            let configurationType: Configuration.Type
            let openAPIModel: OpenAI.Chat.APIModel
            
            init(_ configurationType: Configuration.Type, _ openAPIModel: OpenAI.Chat.APIModel) {
                self.configurationType = configurationType.self
                self.openAPIModel = openAPIModel
            }
        }
    }
    
    struct ChatCompletionsHistoryMessage: Codable, Sendable {
        public let role: Role
        public let content: String
        public let name: String?
        
        init(role: Role, content: String, name: String? = nil) {
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
