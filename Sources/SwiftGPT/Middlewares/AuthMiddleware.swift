import Foundation
import HTTPTypes
import OpenAPIRuntime

extension OpenAI {
    
    /// A client middleware that injects a value into the `Authorization` header field of the request.
    struct AuthMiddleware: ClientMiddleware {
        
        /// The value for the `Authorization` header field.
        let apiKey: OpenAI.APIKey?
        
        /// Creates a new middleware.
        /// - Parameter value: The value for the `Authorization` header field.
        func intercept(
            _ request: HTTPRequest,
            body: HTTPBody?,
            baseURL: URL,
            operationID: String,
            next: (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
        ) async throws -> (HTTPResponse, HTTPBody?) {
            var request = request
            // Adds the `Authorization` header field with the provided value.
            let key = if let apiKey = apiKey {
                apiKey
            } else { OpenAI.Configuration.apiKey }
            request.headerFields[.authorization] = "Bearer \(try await key.value)"
            return try await next(request, body, baseURL)
        }
    }
    
}

extension OpenAI.Chat.APIModel: Identifiable, CustomStringConvertible {

    public var id: String { self.rawValue }
    public var description: String { id }

    static var all: [Self] {
        Self.allCases
    }

}
