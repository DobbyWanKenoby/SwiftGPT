////
////  OpenAI + TTS.swift
////  SwiftGPT
////
////  Created by USOV Vasily on 27.01.2025.
////
//
//import Foundation
//import OpenAPIRuntime
//#if os(Linux)
//    import OpenAPIAsyncHTTPClient
//#else
//    import OpenAPIURLSession
//#endif
//
//
//public extension OpenAI.TextToSpeech {
//    typealias Model = Components.Schemas.CreateSpeechRequest.ModelPayload.Value2Payload
//    typealias Voice = Components.Schemas.CreateSpeechRequest.VoicePayload
//    typealias ResponseFormat = Components.Schemas.CreateSpeechRequest.ResponseFormatPayload
//}
//
//public extension OpenAI {
//    final class TextToSpeech {
//        
//        private let configuration: Configuration
//        private let apiKeyProvider: APIKeyProvider
//        private let client: Client
//        private let baseURLPath: String
//        
//        init(apiKeyProvider: APIKeyProvider, baseURLPath: String, configuration: Configuration) {
//            self.apiKeyProvider = apiKeyProvider
//            self.baseURLPath = baseURLPath
//            self.configuration = configuration
//            let clientTransport: ClientTransport
//#if os(Linux)
//            clientTransport = AsyncHTTPClientTransport()
//#else
//            clientTransport = URLSessionTransport()
//#endif
//            self.client = Client(
//                serverURL: URL(string: self.baseURLPath)!,
//                transport: clientTransport,
//                middlewares: [AuthMiddleware(apiKeyProvider: apiKeyProvider)])
//        }
//        
//        public func generateSpeechFrom(
//            input: String,
//            model: Model? = nil,
//            voice: Voice? = nil,
//            format: ResponseFormat? = nil
//        ) async throws -> Data {
//            
//            let model = model ?? configuration.model
//            let voice = voice ?? configuration.voice
//            let format = format ?? configuration.format
//            
//            let response = try await client.createSpeech(
//                body: .json(
//                    .init(
//                        model: .init(value1: nil, value2: model),
//                        input: input,
//                        voice: voice,
//                        responseFormat: format
//                    )))
//            
//            switch response {
//            case .ok(let response):
//                switch response.body {
//                case .binary(let body):
//                    var data = Data()
//                    for try await byte in body {
//                        data.append(contentsOf: byte)
//                    }
//                    return data
//                }
//                
//            case .undocumented(let statusCode, let payload):
//                throw OpenAI.getError(statusCode: statusCode, model: model.rawValue, payload: payload)
//            }
//        }
//    }

#if os(iOS) || os(macOS) || os(watchOS) || os(tvOS) || os(visionOS)
        /// TODO: use swift-openapi-runtime MultipartFormBuilder
//        public func generateAudioTransciptions(
//            audioData: Data,
//            fileName: String = "recording.m4a",
//            model: String = "whisper-1",
//            language: String = "en"
//        ) async throws -> String {
//            var request = URLRequest(
//                url: URL(string: "https://api.openai.com/v1/audio/transcriptions")!)
//            let boundary: String = UUID().uuidString
//            request.timeoutInterval = 30
//            request.httpMethod = "POST"
//            request.setValue("Bearer \(await apiKeyProvider.apiKey)", forHTTPHeaderField: "Authorization")
//            request.setValue(
//                "multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//
//            let bodyBuilder = MultipartFormDataBodyBuilder(
//                boundary: boundary,
//                entries: [
//                    .file(
//                        paramName: "file", fileName: fileName, fileData: audioData,
//                        contentType: "audio/mpeg"),
//                    .string(paramName: "model", value: model),
//                    .string(paramName: "language", value: language),
//                    .string(paramName: "response_format", value: "text"),
//                ])
//            request.httpBody = bodyBuilder.build()
//            let (data, resp) = try await URLSession.shared.data(for: request)
//            guard let httpResp = resp as? HTTPURLResponse, httpResp.statusCode == 200 else {
//                let statusCode = (resp as? HTTPURLResponse)?.statusCode ?? 500
//                throw OpenAI.getError(statusCode: statusCode, model: model, payload: nil)
//            }
//            guard let text = String(data: data, encoding: .utf8) else {
//                throw "Invalid format"
//            }
//
//            return text
//        }
#endif
//}
//
//// MARK: - Configuration
//
//public extension OpenAI.TextToSpeech {
//    struct Configuration: Sendable {
//        let model: Model
//        let voice: Voice
//        let format: ResponseFormat
//        
//        init(model: Model = .tts1,
//             voice: Voice = .alloy,
//             format: ResponseFormat = .aac) {
//            self.model = model
//            self.voice = voice
//            self.format = format
//        }
//    }
//}

