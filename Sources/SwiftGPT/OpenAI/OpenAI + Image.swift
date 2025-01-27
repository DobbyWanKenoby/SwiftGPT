////
////  OpenAI + Image.swift
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
//public extension OpenAI.ImageGenerator {
//    typealias APIModel = Components.Schemas.CreateImageRequest.ModelPayload.Value2Payload
//    typealias ImageQuality = Components.Schemas.CreateImageRequest.QualityPayload
//    typealias ResponseFormat = Components.Schemas.CreateImageRequest.ResponseFormatPayload
//    typealias ImageStyle = Components.Schemas.CreateImageRequest.StylePayload
//}
//
//public extension OpenAI {
//    final class ImageGenerator {
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
//        public func generateImage(
//            prompt: String,
//            model: APIModel? = nil,
//            quality: ImageQuality? = nil,
//            responseFormat: ResponseFormat? = nil,
//            style: ImageStyle? = nil
//        ) async throws -> Components.Schemas.Image {
//            
//            let model = model ?? configuration.model
//            let quality = quality ?? configuration.quality
//            let responseFormat = responseFormat ?? configuration.responseFormat
//            let style = style ?? configuration.style
//            
//            let response = try await client.createImage(
//                .init(
//                    body: .json(
//                        .init(
//                            prompt: prompt,
//                            model: .init(value1: nil, value2: model),
//                            n: 1,
//                            quality: quality,
//                            responseFormat: responseFormat,
//                            size: ._1024x1024,
//                            style: style
//                        ))))
//            
//            switch response {
//            case .ok(let response):
//                switch response.body {
//                case .json(let imageResponse) where imageResponse.data.first != nil:
//                    return imageResponse.data.first!
//                    
//                default:
//                    throw "Unknown response"
//                }
//                
//            case .undocumented(let statusCode, let payload):
//                throw OpenAI.getError(
//                    statusCode: statusCode,
//                    model: model.rawValue,
//                    payload: payload)
//            }
//        }
//    }
//}
//
//// MARK: - Configuration
//
//public extension OpenAI.ImageGenerator {
//    struct Configuration: Sendable {
//        let model: APIModel
//        let quality: ImageQuality
//        let responseFormat: ResponseFormat
//        let style: ImageStyle
//        
//        init(model: APIModel = .dallE3,
//             quality: ImageQuality = .standard,
//             responseFormat: ResponseFormat = .url,
//             style: ImageStyle = .vivid) {
//            self.model = model
//            self.quality = quality
//            self.responseFormat = responseFormat
//            self.style = style
//        }
//    }
//}
