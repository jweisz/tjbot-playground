/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation

public enum TJBotCapability: String {
    case analyzeTone = "analyze_tone"
    case converse
    case listen
    case see
    case shine
    case speak
    case translate
    case wave
}

extension TJBotCapability {
    static var allCapabilities: [TJBotCapability] = [
        .analyzeTone, .converse, .listen, .see, .shine, .speak, .translate, .wave
    ]
}
