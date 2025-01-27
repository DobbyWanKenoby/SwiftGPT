//
//  Configurations.swift
//  SwiftGPT
//
//  Created by USOV Vasily on 30.01.2025.
//

// Configurations for ChatCompletions GPT models

public extension OpenAI {
    
    /// Field for all GPT models
    protocol ChatCompletionsConfiguration {
        var temperature: Double? { get set }
        var stop: [String]? { get set }
        /// How many chat completion choices to generate for each input message. Note that you will be charged based on the number of generated tokens across all of the choices. Keep n as 1 to minimize costs.
        ///
        /// In OpenAI API named as `n`. [See on official documentation](https://platform.openai.com/docs/api-reference/chat/create#chat-create-n)
        var competionsNumber: Int? { get set }
        var seed: Int? { get set }
        /// Developer-provided instructions that the model should follow, regardless of messages sent by the user. With o1 models and newer, `developer` messages replace the previous `system`
        var developerMessageKey: DeveloperMessageKey { get }
    }
    
    protocol ChatCompletionsConfigurationWithDefaultConfiguration {
        init()
        static var `default`: Self { get }
    }
    
    protocol ChatCompletionsWithMaxTokensParameter {
        /// The maximum number of tokens that can be generated in the chat completion. This value can be used to control costs for text generated via API.
        var maxTokens: Int? { get set }
    }
    
    protocol ChatCompletionsWithMaxCompletionTokensParameter {
        /// An upper bound for the number of tokens that can be generated for a completion, including visible output tokens and reasoning tokens.
        var maxCompletionTokens: Int? { get set }
    }
    
    /// Configuration suitable for all objects. Has all properties.
    ///
    /// See the [official OpenAI API documentation](https://platform.openai.com/docs/api-reference/chat/create) to determine what parameters can be used with the model.
    struct ChatCompletionsCommonConfiguration: ChatCompletionsConfiguration, ChatCompletionsWithMaxTokensParameter, ChatCompletionsWithMaxCompletionTokensParameter {
        public var developerMessageKey: DeveloperMessageKey
        public var competionsNumber: Int?
        public var temperature: Double? = nil
        public var maxTokens: Int? = nil
        public var maxCompletionTokens: Int? = nil
        public var stop: [String]? = nil
        public var seed: Int? = nil
        public init(developerMessageKey: DeveloperMessageKey) {
            self.developerMessageKey = developerMessageKey
        }
    }
    
    /// Configuration for models chatGPT 3.5
    struct ChatCompetionConfigurationGPT3Series: ChatCompletionsConfiguration, ChatCompletionsWithMaxTokensParameter, ChatCompletionsConfigurationWithDefaultConfiguration {
        public var developerMessageKey: DeveloperMessageKey { .system }
        public var competionsNumber: Int? = nil
        public var temperature: Double? = nil
        public var maxTokens: Int? = nil
        public var stop: [String]? = nil
        public var seed: Int? = nil
        public init() {}
    }
    
    /// Configuration for models chatGPT 4, 4o
    struct ChatCompetionConfigurationGPT4Series: ChatCompletionsConfiguration, ChatCompletionsWithMaxTokensParameter, ChatCompletionsConfigurationWithDefaultConfiguration {
        public var developerMessageKey: DeveloperMessageKey { .system }
        public var competionsNumber: Int? = nil
        public var temperature: Double? = nil
        public var maxTokens: Int? = nil
        public var stop: [String]? = nil
        public var seed: Int? = nil
        public init() {}
    }
    
    /// Configuration for models chatGPT o1
    struct ChatCompetionConfigurationGPTo1Series: ChatCompletionsConfiguration, ChatCompletionsWithMaxCompletionTokensParameter, ChatCompletionsConfigurationWithDefaultConfiguration {
        public var developerMessageKey: DeveloperMessageKey { .developer }
        public var competionsNumber: Int? = nil
        public var temperature: Double? = nil
        public var maxCompletionTokens: Int? = nil
        public var stop: [String]? = nil
        public var seed: Int? = nil
        public init() {}
    }
    
    // MARK: - Subtypes
    
    enum DeveloperMessageKey {
        case developer
        case system
    }
}

public extension OpenAI.ChatCompletionsConfigurationWithDefaultConfiguration {
    static var `default`: Self {
        Self.init()
    }
}
