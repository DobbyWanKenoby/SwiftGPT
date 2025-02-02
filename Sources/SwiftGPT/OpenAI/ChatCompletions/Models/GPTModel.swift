//
//  ChatGPTModel.swift
//  SwiftGPT
//
//  Created by USOV Vasily on 31.01.2025.
//

extension OpenAI.Chat {
    public struct GPTModel<Configuration>: Sendable {
        
        let ConfigurationType: Configuration.Type
        let apiModel: UsingModelType
        var name: String {
            switch apiModel {
            case .model(let apiModel):
                apiModel.rawValue
            case .custom(let string):
                string
            }
        }
        
        private init(_ configurationType: Configuration.Type, _ openAPIModel: OpenAI.Chat.APIModel) {
            self.ConfigurationType = configurationType.self
            self.apiModel = .model(openAPIModel)
        }
        
        private init(_ configurationType: Configuration.Type, _ modelName: String) {
            self.ConfigurationType = configurationType.self
            self.apiModel = .custom(modelName)
        }
        
        enum UsingModelType {
            case model(OpenAI.Chat.APIModel)
            case custom(String)
        }
    }
}

public extension OpenAI.Chat.GPTModel where Configuration == OpenAI.ChatCompletionsCommonConfiguration {
    static func custom(_ name: String) -> Self {
        .init(Configuration.self, name)
    }
}

public extension OpenAI.Chat.GPTModel where Configuration == OpenAI.ChatCompetionConfigurationGPT3Series {
    static var gpt_3_5_turbo: Self {
        .init(Configuration.self, .gpt3_5Turbo)
    }
}

public extension OpenAI.Chat.GPTModel where Configuration == OpenAI.ChatCompetionConfigurationGPT4Series {
    static var gpt_4: Self {
        .init(Configuration.self, .gpt4)
    }
    static var gpt_4_turbo: Self {
        .init(Configuration.self, .gpt4Turbo)
    }
    static var gpt_4o: Self {
        .init(Configuration.self, .gpt4o)
    }
    static var gpt_4o_latest: Self {
        .init(Configuration.self, .chatgpt4oLatest)
    }
    static var gpt_4o_mini: Self {
        .init(Configuration.self, .gpt4oMini)
    }
}

public extension OpenAI.Chat.GPTModel where Configuration == OpenAI.ChatCompetionConfigurationGPToSeries {
    static var gpt_o3_mini: Self {
        .init(Configuration.self, .o3Mini)
    }
    static var gpt_o1: Self {
        .init(Configuration.self, .o1)
    }
    static var gpt_o1_mini: Self {
        .init(Configuration.self, .o1Mini)
    }
    static var gpt_o1_preview: Self {
        .init(Configuration.self, .o1Preview)
    }
}
