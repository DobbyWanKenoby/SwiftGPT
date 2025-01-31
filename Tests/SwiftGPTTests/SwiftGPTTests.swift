import Testing
@testable import SwiftGPT

final class SwiftGPTTests {
    
    enum Config {
        static let apiKey = "API_KEY"
    }
    
    @Test
    func chatCompletions() async throws {
        print("")
        print("----PRESETTED MODEL TEST----")
        let chat = OpenAI.Chat(model: .gpt_4, apiKey: .apiKey(Config.apiKey))
        var configuration = chat.ConfigurationType.init()
        configuration.maxTokens = 5
        
        print("")
        print("----NORMAL REQUEST----")
        let response = try await chat.completions(promt: "Please tell me about Space!", configuration: configuration)
        print(response)
        
        do {
            print("")
            print("----STREAM REQUEST----")
            let stream = try await chat.streamCompletions(promt: "Please tell me about Space!", configuration: configuration)
            for try await line in stream {
                print(line)
            }
        } catch {
            print(1111)
        }
        
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
