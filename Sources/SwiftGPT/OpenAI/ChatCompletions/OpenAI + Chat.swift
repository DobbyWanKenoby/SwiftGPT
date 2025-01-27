//
//  ChatGPT + APIClient.swift
//  ChatGPTSwift
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

public extension OpenAI.Chat {
    
    typealias APIModel = Components.Schemas.CreateChatCompletionRequest.ModelPayload.Value2Payload
    typealias APITool = Components.Schemas.ChatCompletionTool
    typealias APIResponseMessage = Components.Schemas.ChatCompletionResponseMessage
    
    typealias StreamResponse = AsyncMapSequence<AsyncThrowingPrefixWhileSequence<AsyncThrowingMapSequence<ServerSentEventsDeserializationSequence<ServerSentEventsLineDeserializationSequence<HTTPBody>>,ServerSentEventWithJSONData<Components.Schemas.CreateChatCompletionStreamResponse>>>, String>
    
}

public extension OpenAI {
    /// Functional for chating with ChatGPT
    ///
    /// Chat completions API documentation: [https://platform.openai.com/docs/api-reference/chat](https://platform.openai.com/docs/api-reference/chat)
    final class Chat<C: ChatCompletionsConfiguration> {
        
        private let client: Client
        public let apiKey: OpenAI.APIKey?
        private let model: GPTModel
        
        let ConfigurationType = C.self
        
        private enum GPTModel {
            case model(OpenAI.Chat.APIModel)
            case custom(String)
            
            var name: String {
                switch self {
                case .model(let apiModel):
                    apiModel.rawValue
                case .custom(let string):
                    string
                }
            }
        }
        
        /// Create new session with chat completions functional
        ///
        /// **Why Use KeyPath Instead of Enum?**
        ///
        /// Different GPT models require different parameters in an HTTP request. For example, gpt-4 uses the parameter maxTokens to specify the maximum number of tokens, while gpt-o1 uses max_completion_tokens.
        ///
        /// From the standpoint of library implementation, it would be easiest for me to provide you with one large generic structure with all the fields, leaving you to figure out which parameters can be passed for the model you are using. However, I decided to make this process more convenient: depending on the selected GPT model, the internal generic type will change so that you configure the model only within the framework of parameters available to it.
        ///
        /// The most convenient way to implement such behavior is by using KeyPath, as it is essentially the only proper way to pass an object with a configuration, configure a generic type, and allow the use of autocompletion.
        /// - Parameters:
        ///   - model: KeyPath to used GPT model
        ///   - apiKey: Used API key. Do not pass (or set `nil`) to using key from global configuration (`OpenAI.Configuration.apiKey`)
        ///   - url: Used URL for requests.
        init(model: KeyPath<OpenAI.ChatGPTModel, OpenAI.ChatGPTModel.Model<C>>,
             apiKey: OpenAI.APIKey? = nil,
             url: String = OpenAI.Configuration.url) {
            let _model = OpenAI.ChatGPTModel()[keyPath: model].openAPIModel
            self.model = .model(_model)
            self.apiKey = apiKey
            let clientTransport: ClientTransport
#if os(Linux)
            clientTransport = AsyncHTTPClientTransport()
#else
            clientTransport = URLSessionTransport()
#endif
            self.client = Client(
                serverURL: URL(string: url)!,
                transport: clientTransport,
                middlewares: [AuthMiddleware(apiKey: apiKey)])
        }
        
        /// Create new session with chat completions functional with custom GPT model name
        ///
        /// - Parameters:
        ///   - customModelName: Name of using model.
        ///   - apiKey: Used API key. Do not pass (or set `nil`) to using key from global configuration (`OpenAI.Configuration.apiKey`)
        ///   - url: Used URL for requests.
        init(customModelName: String,
             apiKey: OpenAI.APIKey? = nil,
             url: String = OpenAI.Configuration.url) where C == OpenAI.ChatCompletionsCommonConfiguration {
            self.model = .custom(customModelName)
            self.apiKey = apiKey
            let clientTransport: ClientTransport
#if os(Linux)
            clientTransport = AsyncHTTPClientTransport()
#else
            clientTransport = URLSessionTransport()
#endif
            self.client = Client(
                serverURL: URL(string: url)!,
                transport: clientTransport,
                middlewares: [AuthMiddleware(apiKey: apiKey)])
        }
        
        // MARK: - Normal completions
        
        /// Creates a model response for the given chat conversation
        ///
        /// - Parameters:
        ///   - promt: User message for request
        ///   - image: User image for reqeust
        ///   - userName: A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
        ///   - developerMessage: Developer-provided instructions that the model should follow, regardless of messages sent by the user.
        ///   - previousMessages: History of messages
        ///   - configuration: Model configuration for current request. See [Chat completions API documentation](https://platform.openai.com/docs/api-reference/chat)
        public func completions(promt: String,
                                image: Data? = nil,
                                userName: String? = nil,
                                developerMessage: String? = nil,
                                previousMessages: [ChatCompletionsHistoryMessage] = [],
                                configuration: C = .default) async throws(ChatCompletionsError) -> String where C: ChatCompletionsConfigurationWithDefaultConfiguration {
            
            try await internalCompletions(promt: promt, image: image, userName: userName, developerMessage: developerMessage, previousMessages: previousMessages, configuration: configuration)
        }
        
        /// Creates a model response for the given chat conversation
        ///
        /// - Parameters:
        ///   - promt: User message for request
        ///   - image: User image for reqeust
        ///   - userName: A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
        ///   - developerMessage: Developer-provided instructions that the model should follow, regardless of messages sent by the user.
        ///   - previousMessages: History of messages
        ///   - configuration: Model configuration for current request
        public func completions(promt: String,
                                image: Data? = nil,
                                userName: String? = nil,
                                developerMessage: String? = nil,
                                previousMessages: [ChatCompletionsHistoryMessage] = [],
                                configuration: C) async throws(ChatCompletionsError) -> String {
            try await internalCompletions(promt: promt, image: image, userName: userName, developerMessage: developerMessage, previousMessages: previousMessages, configuration: configuration)
        }
        
        private func internalCompletions(promt: String,
                                         image: Data?,
                                         userName: String?,
                                         developerMessage: String?,
                                         previousMessages: [ChatCompletionsHistoryMessage],
                                         configuration: C) async throws(ChatCompletionsError) -> String {
            let response: Operations.CreateChatCompletion.Output
            do {
                response = try await client.createChatCompletion(
                    body: requestBody(promt: promt, image: image, userName: userName, developerMessage: developerMessage, configuration: configuration, stream: false)
                )
            } catch {
                throw .requestError(error)
            }
            
            do {
                switch response {
                case .ok(let body):
                    let json = try body.body.json
                    guard let content = json.choices.first?.message.content else {
                        throw "No Response"
                    }
                    return content
                case .undocumented(let statusCode, let payload):
                    throw OpenAI.getError(statusCode: statusCode, model: model.name, payload: payload)
                }
            } catch {
                throw .responseError(error)
            }
        }
        
        // MARK: - Stream completions
        
        /// Creates a model response for the given chat conversation
        ///
        /// - Parameters:
        ///   - promt: User message for request
        ///   - image: User image for reqeust
        ///   - userName: A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
        ///   - developerMessage: Developer-provided instructions that the model should follow, regardless of messages sent by the user.
        ///   - previousMessages: History of messages
        ///   - configuration: Model configuration for current request. See [Chat completions API documentation](https://platform.openai.com/docs/api-reference/chat)
        public func streamCompletions(promt: String,
                                image: Data? = nil,
                                userName: String? = nil,
                                developerMessage: String? = nil,
                                previousMessages: [ChatCompletionsHistoryMessage] = [],
                                configuration: C) async throws(ChatCompletionsError) -> StreamResponse {
            try await internalStreamCompletions(promt: promt, image: image, userName: userName, developerMessage: developerMessage, previousMessages: previousMessages, configuration: configuration)
        }
        
        /// Creates a model stream response for the given chat conversation
        ///
        /// - Parameters:
        ///   - promt: User message for request
        ///   - image: User image for reqeust
        ///   - userName: A unique identifier representing your end-user, which can help OpenAI to monitor and detect abuse.
        ///   - developerMessage: Developer-provided instructions that the model should follow, regardless of messages sent by the user.
        ///   - previousMessages: History of messages
        ///   - configuration: Model configuration for current request. See [Chat completions API documentation](https://platform.openai.com/docs/api-reference/chat)
        public func streamCompletions(promt: String,
                                image: Data? = nil,
                                userName: String? = nil,
                                developerMessage: String? = nil,
                                previousMessages: [ChatCompletionsHistoryMessage] = [],
                                configuration: C = .default) async throws(ChatCompletionsError) -> StreamResponse where C: ChatCompletionsConfigurationWithDefaultConfiguration {
            try await internalStreamCompletions(promt: promt, image: image, userName: userName, developerMessage: developerMessage, previousMessages: previousMessages, configuration: configuration)
        }
        
        private func internalStreamCompletions(promt: String,
                                               image: Data?,
                                               userName: String?,
                                               developerMessage: String?,
                                               previousMessages: [ChatCompletionsHistoryMessage],
                                               configuration: C) async throws(ChatCompletionsError) -> StreamResponse
        {
            var response: Operations.CreateChatCompletion.Output
            do {
                response = try await client.createChatCompletion(
                    .init(
                        headers: .init(accept: [.init(contentType: .textEventStream)]),
                        body: requestBody(promt: promt, image: image, userName: userName, developerMessage: developerMessage, configuration: configuration, stream: true)
                    )
                )
            } catch {
                throw .requestError(error)
            }
            
            do {
                let stream = try response.ok.body.textEventStream
                    .asDecodedServerSentEventsWithJSONData(
                        // TODO: There is a crash if configurations have maxTokens, because answer as [DONE] and cannot decode
                        of: Components.Schemas.CreateChatCompletionStreamResponse.self
                    )
                    .prefix { chunk in
                        if let choice = chunk.data?.choices.first {
                            return choice.finishReason != .stop
                        } else {
                            throw "Invalid data"
                        }
                    }
                    .map { $0.data?.choices.first?.delta.content ?? "" }
                return stream
            } catch {
                let errorDesc = (error as CustomStringConvertible).description
                let pattern = /statusCode:\s(\d+)/
                let statusCode = if let match = errorDesc.firstMatch(of: pattern) {
                    Int(match.output.1) ?? 500
                } else { 500 }
                let localError = OpenAI.getError(statusCode: statusCode, model: model.name, payload: nil)
                throw .responseError(localError)
            }
        }
        
        // MARK: - Common logic
        
        private func requestBody(promt: String,
                                 image: Data? = nil,
                                 userName: String? = nil,
                                 developerMessage: String?,
                                 previousMessages: [ChatCompletionsHistoryMessage] = [],
                                 configuration: C,
                                 stream: Bool) -> Operations.CreateChatCompletion.Input.Body {
            
            let usingOpenAPIFormatModel: Components.Schemas.CreateChatCompletionRequest.ModelPayload = switch model {
            case .model(let apiModel):
                    .init(value1: nil, value2: apiModel)
            case .custom(let modelName):
                    .init(value1: modelName, value2: nil)
            }
            var request = Components.Schemas.CreateChatCompletionRequest(
                messages: generateMessages(userMessage: promt,
                                           userName: userName,
                                           developerMessage: developerMessage,
                                           previousMessages: previousMessages,
                                           configuration: configuration),
                model: usingOpenAPIFormatModel,
                stream: stream,
                temperature: configuration.temperature
            )
            
            if let stop = configuration.stop {
                request.stop = .case2(stop)
            }
            if let _c = configuration as? ChatCompletionsWithMaxTokensParameter {
                request.maxTokens = _c.maxTokens
            }
            if let _c = configuration as? ChatCompletionsWithMaxCompletionTokensParameter {
                request.maxCompletionTokens = _c.maxCompletionTokens
            }
            return .json(request)
        }
        
        private func generateMessages(userMessage: String, userName: String?, developerMessage: String?, previousMessages: [ChatCompletionsHistoryMessage], configuration: C) -> [Components.Schemas.ChatCompletionRequestMessage] {
            var messages: [Components.Schemas.ChatCompletionRequestMessage] = []
            
            if let developerMessage {
                switch configuration.developerMessageKey {
                case .developer: messages.append(.ChatCompletionRequestDeveloperMessage(.init(content: .case1(developerMessage), role: .developer)))
                case .system: messages.append(.ChatCompletionRequestSystemMessage(.init(content: .case1(developerMessage), role: .system)))
                }
                
            }
            for previousMessage in previousMessages {
                switch previousMessage.role {
                case .assistant:
                    messages.append(.ChatCompletionRequestAssistantMessage(.init(content: .case1(previousMessage.content), role: .assistant, name: previousMessage.name)))
                case .user:
                    messages.append(.ChatCompletionRequestUserMessage(.init(content: .case1(previousMessage.content), role: .user, name: previousMessage.name)))
                }
            }
            messages.append(.ChatCompletionRequestUserMessage(.init(content: .case1(userMessage), role: .user, name: userName)))
            return messages
        }
        
        
        
        //        public func callFunction(
        //            prompt: String,
        //            tools: [Tool],
        //            model: Model? = nil,
        //            maxTokens: Int? = nil,
        //            responseFormat: Components.Schemas.CreateChatCompletionRequest.ResponseFormatPayload? =
        //            nil,
        //            stop: Components.Schemas.CreateChatCompletionRequest.StopPayload? = nil,
        //            systemText: String =
        //            "Don't make assumptions about what values to plug into functions. Ask for clarification if a user request is ambiguous.",
        //            imageData: Data? = nil
        //        ) async throws -> APIResponseMessage {
        //            let model = model ?? configuration.model
        //            var messages = await generateInternalMessages(from: prompt, systemText: systemText)
        //            if let imageData {
        //                messages.append(createMessage(imageData: imageData))
        //            }
        //
        //            let response = try await client.createChatCompletion(
        //                .init(
        //                    body: .json(
        //                        .init(
        //                            messages: messages,
        //                            model: .init(value1: nil, value2: model),
        //                            maxTokens: maxTokens,
        //                            responseFormat: responseFormat,
        //                            stop: stop,
        //                            tools: tools,
        //                            toolChoice: .none))))
        //
        //            switch response {
        //            case .ok(let body):
        //                let json = try body.body.json
        //                guard let message = json.choices.first?.message else {
        //                    throw "No Response"
        //                }
        //                return message
        //            case .undocumented(let statusCode, let payload):
        //                throw OpenAI.getError(statusCode: statusCode, model: model.rawValue, payload: payload)
        //            }
        //        }
        
        private func createOpenAIFormatMessage(fromImageData: Data) -> Components.Schemas.ChatCompletionRequestMessage {
            .ChatCompletionRequestUserMessage(
                .init(
                    content: .case2([
                        .ChatCompletionRequestMessageContentPartImage(
                            .init(
                                _type: .imageUrl,
                                imageUrl:
                                        .init(
                                            url:
                                                "data:image/jpeg;base64,\(fromImageData.base64EncodedString())",
                                            detail: .auto)))
                    ]),
                    role: .user))
        }
        
    }
    
}
