import Testing
@testable import SwiftGPT

final class SwiftGPTTests {
    
    enum Config {
        static let apiKey = "API_KEY"
    }
    
    @Test
    @MainActor
    func chatCompletions() async throws {
        OpenAI.Configuration.url = "https://justproxy.su/v1"
        print("")
        print("----PRESETTED MODEL TEST----")
        let chat = OpenAI.Chat(model: .gpt_4o, apiKey: .apiKey(Config.apiKey))
        var configuration = chat.ConfigurationType.init()
//        configuration.responseFormat = .jsonSchema(name: "maths", description: "Maths tasks", strict: false, schema: ["type": "object",
//                                                                                                                      "description": "object with math tasks",
//                                                                                                                      "properties": ["type": "array", "description": "array of tasks", "items": ["type": "string"]]
//                                                                                                                     ] as! [String: (any Sendable)])
        configuration.maxTokens = 5
        print("")
        print("----NORMAL REQUEST----")
        let response = try await chat.completions(promt: "Please give me three math tasks", configuration: configuration)
        print(response)
        
        do {
            print("")
            print("----STREAM REQUEST----")
            let stream = try await chat.streamCompletions(promt: "Please tell me about Space!", configuration: configuration)
            for try await line in stream {
                print(line)
            }
        } catch {}
        
        print("")
        print("----CUSTOM MODEL TEST----")
        let customChat = OpenAI.Chat(model: .custom("gpt-4o-mini"),
                              apiKey: .apiKey(Config.apiKey))
        var customConfiguration = customChat.ConfigurationType.init(developerMessageKey: .developer)
        customConfiguration.maxTokens = 50
        let customResponse = try await customChat.completions(promt: "Please tell me about Space!", configuration: customConfiguration)
        print(customResponse)
    }
}
