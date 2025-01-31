# SwiftGPT

![my badge](https://badgen.net/static/SPM/compatible/green) ![my badge](https://badgen.net/static/Swift/6&nbsp;|&nbsp;5.10/orange) ![my badge](https://badgen.net/static/license/MIT/blue)

Access OpenAI ChatGPT Official API using Swift. 

## Main features

- OpenAI like API, written on Swift.
- Works on all Apple platforms and Linux.
- Full Swift Concurrency and Swift 6 integration.
- Supported ChatCompletion (text generation), and later Assistant API, Audio (voice generation, text transcriptions), Image generation functions.

### Thanks

Current project based on a [ChatGPTSwift](https://github.com/alfianlosari/ChatGPTSwift.git) package.

#### Main differences from ChatGPTSwift

- OpenAI like API, not one class for all functions. 
- Full Swift Concurrency integration without data races, `unchecked @Sendable` and other non-Sendable classes.
- Added the ability to use your own server URL for requests (it is relevant if necessary to use proxy).
- Used actual version of OpenAPI.yaml.
- Used friendly ChatGPT models an other names, such as `.gpt4o` instead of `.gpt_hyphen_4o`, `.textEventStream` instead of `.text_event_hyphen_stream` and etc.
- Improved bugs in internal logic.
- Removed logic of store messages list (`historyList` property). It was an outdated solution that requires improvements, and now Assistants API is able to reduce the size of the context in auto mode.
- Removed deprecated support of CocoaPods.

## Supported Platforms

- iOS/tvOS 18 and above
- macOS 15 and above
- watchOS 11 and above
- Linux

## Installation

### Swift Package Manager
- File > Swift Packages > Add Package Dependency
- Add https://github.com/DobbyWanKenoby/SwiftGPT.git

## Requirement

Register for API key from [OpenAI](https://openai.com/api).

## Usage

### Global configuration

Specify global configuration, that are common to all sessions, using static properties of type `OpenAI.Configuration`. You can later override the settings on individually for each session.

#### API KEY

Firstly set API key:

```swift
OpenAI.Configuration.apiKey = .apiKey("API_KEY")
```

If you require more complex logic of working with an API key, then use `APIKeyProvider`. Below is an example in which the API key is requested asynchronously from a remote server, and during this time, all requests will wait for the completion of the retrieval process.

```swift
// Custom APIKeyProvider imlementation
actor ServiceAPIKeyProvider: OpenAI.APIKeyProvider {
    private var _apiKey: String?
    var apiKey: String {
        get async throws {
            // Wait while API key not setted
            while _apiKey == nil {
                try Task.checkCancellation()
                await Task.yield()
            }
            return _apiKey!
        }
    }
    init(apiKey: String? = nil) {
        _apiKey = apiKey
    }
    
    func fetchAPIKey() async throws -> String {
        _apiKey = nil
        let newAPIKey = try await // ... fetching logic
        _apiKey = newAPIKey
    }
}

// Set provider to global configuration
let provider = ServiceAPIKeyProvider(apiKey: "API_KEY")
OpenAI.Configuration.apiKey = .provider(provider)
```

#### Server URL

You can specify server URL:

```swift
OpenAI.Configuration.url = "https://you_own_proxy_chatgpt.com"
```

> Other sesttings you can see in specification of `OpenAI.Configuration`.

### Chat Completions

`ChatCompletions` type allow you generate text from a promt.

First create `OpenAI.Chat` instance with passing used model:

```swift
// Pass model version
let chat = OpenAI.Chat(model: .gpt4o)
```

if current package have not KeyPath with needed model, you can use another `OpenAI.Chat.init` to pass custom model name:

```swift
// Pass textual name of model
let chat = OpenAI.Chat(model: .custom("gpt-4o-2024-11-20"))
```

There are 2 APIs: stream and normal

#### Normal

A normal HTTP request and response lifecycle. Server will send the complete text (it will take more time to response):

```swift
let response = try await chat.completions(promt: "Please tell me about Space")
print(response)
```

#### Stream

The server will stream chunks of data until complete, the method `AsyncThrowingStream` which you can loop using For-Loop like so:

```swift
let stream = try await chat.streamCompletions(promt: "What is ChatGPT?")
for try await line in stream {
    print(line)
}
```

#### Configurate request

##### Request configuration

Optionally, you can pass additional configuration to `completions` method. Because `OpenAI.Chat` is a generic, you must take certain using configuration-type. You can do this using the property `ConfigurationType` of `OpenAI.Chat` instance:

```swift
// Create empty configuration
var configuration = chat.ConfigurationType.init()

// Configure
configuration.maxTokens = 100
configuration.temperature = 0.8

// Pass configuration to completion method
let response = chat.completion(promt: "What is ChatGPT?", configuration: configuration)
```

To learn more about those parameters, you can visit the official [ChatGPT API documentation](https://platform.openai.com/docs/guides/chat/introduction) and [ChatGPT API Introduction Page](https://openai.com/blog/introducing-chatgpt-and-whisper-apis)

##### Context (messages history)

Optionally, you can pass developer (system) message and history of messages to request. Just use properties from completions method:

```swift
let response = try await chat.completions(
	promt: "Please tell me about Space", 
	developerText: "You a senior Swift developer with 20 years of experience", 
	previousMessages: [/** Array with previous messages**/]
)
```

> Some models use `developer` key, and some - `system` key for developer-provided instructions that the model should follow (parameter `messages` in HTTP-request, see [official API documentation](https://platform.openai.com/docs/api-reference/chat) for additional info). SwiftGPT incapsulate this logic and use needed key automatically. Only when you create `OpenAI.Chat` instance with `init(customModelName:)` you need to specify which keys to use (property `developerMessageKey` in configuration instance).

##### Image

You can pass image to completions request. Just use image property:

```swift
let image: Data = ...
let response = try await chat.completions(
	promt: "Is there an notebook on this image?",
	image: image
) 
```

## Contribute

If you want to contribute to the project by adding new parameters to existing APIs or creating new APIs, simply create a Merge Request.

## TODO

- Add parameters to ChatCompetions (such as tools and etc)
- Add Audio (TTS, STT) API
- Add Assistants API
- Add Image Generation API
