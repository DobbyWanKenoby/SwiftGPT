//
//  Configuration.swift
//  SwiftGPT
//
//  Created by USOV Vasily on 28.01.2025.
//

import Foundation

extension Array where Element == OpenAI.ChatCompletionsHistoryMessage {
    var contentCount: Int { map { $0.content }.count }
    var content: String { reduce("") { $0 + $1.content } }
}
