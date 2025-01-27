//
//  Errors.swift
//  SwiftGPT
//
//  Created by USOV Vasily on 30.01.2025.
//

import Foundation
import OpenAPIRuntime

public extension OpenAI {
    enum ChatCompletionsError: LocalizedError {
        case requestError(Error)
        case responseError(Error)
        
        public var errorDescription: String? {
            switch self {
            case .requestError(let error): error.localizedDescription
            case .responseError(let error): error.localizedDescription
            }
        }
    }
    
    static func getError(statusCode: Int, model: String?, payload: UndocumentedPayload?) -> Error {
        var error = "\(statusCode) - "
        if statusCode == 401 {
            error +=
            "Invalid Authentication. Check your OpenAI API Key. Make sure it is correct with sufficient quota"
            if let model {
                error += " and are eligible to use \(model)."
            } else {
                error += "."
            }
        } else if statusCode == 403 {
            error +=
            "Country, region, or territory not supported. Check OpenAI website for supported countries."
        } else if statusCode == 429 {
            error +=
            " Rate limit reached for requests - You are sending requests too quickly or you exceeded your current quota, please check your plan and billing details."
        } else {
            error =
            "Status Code: \(statusCode). Check OpenAI Doc for status code error description."
            if let payload {
                error += " \(payload)"
            }
        }
        
        return error
    }
}
