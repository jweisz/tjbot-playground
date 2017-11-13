/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import PlaygroundSupport

protocol PlaygroundSerializable {
    init(response: AnyObject)
    init(error: TJBotError)
    static func from<T>(playgroundValue: PlaygroundValue) -> T where T: PlaygroundSerializable
}

extension PlaygroundSerializable {
    static func from<T>(playgroundValue: PlaygroundValue) -> T where T: PlaygroundSerializable {
        guard case let .dictionary(dict) = playgroundValue else {
            return T(error: TJBotError.unableToDeserializeTJBotResponse)
        }
        
        var responseObj: T? = nil
        if let response = dict["response"] {
            if case let .data(data) = response {
                do {
                    let obj = try JSONSerialization.jsonObject(with: data, options: .init(rawValue: 0)) as AnyObject
                    responseObj = T(response: obj)
                } catch let error {
                    TJLog("PlaygroundSerializable.from(): error in convering JSON to JSON object: \(error)")
                }
            }
        } else if let response = dict["error"] {
            if case let .string(val) = response {
                responseObj = T(error: TJBotError.tjbotInternalError(val))
            }
        }
        
        if let responseObj = responseObj {
            TJLog("PlaygroundSerializable.from(): successfully deserialized playgroundValue to: \(responseObj)")
            return responseObj
        } else {
            TJLog("PlaygroundSerializable.from(): unable to deserialize playgroundValue: \(playgroundValue)")
            return T(error: TJBotError.unableToDeserializeTJBotResponse)
        }
    }
}
