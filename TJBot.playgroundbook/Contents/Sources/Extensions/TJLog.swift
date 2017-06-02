/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import PlaygroundSupport

func TJLog(_ message: String) {
    //NSLog("[TJBot] \(message)")
}

func TJLogResponse(_ response: PlaygroundValue) {
    switch response {
    case .dictionary(let dict):
        guard let response = dict["response"] else {
            TJLog("TJLogResponse unable to inspect dict: \(dict)")
            return
        }
        guard case let .data(data) = response else {
            TJLog("TJLogResponse unable to pull out data: \(response)")
            return
        }
        guard let str = String(data: data, encoding: .utf8) else {
            TJLog("TJLogResponse unable to decode as utf8: \(response)")
            return
        }
        TJLog("TJLogResponse: \(str)")
    default:
        TJLog("response is not a dictionary: \(response)")
    }
}
