/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import PlaygroundSupport

public var pageName: String = "Page_4_SecretDance"
public var successMessage: AssessmentSuccess = "Congratulations, Tinker is now quite the polyglot! \n\n[**Next Page**](@next)"
public var successBeeCommand: RebusTheBeeCommand = .beeSpeak("First, you must shine red, Next, wave your arm twice, Shine yellow, Put your arm down Shine blue, then raise your arm")
public var successBotCommand: TJBotInternalCommand?

/**
 * Evaluate Method
 * - custom method for each Page to determine if the user properly did the page challenge
 * - accepts
 */
public func evaluate(commandList: [String]?, dataList: [AnyObject]?) -> AssessmentResult {
    //check the command list contains translate
    guard let commandList = commandList,
                commandList.contains("translate") else {
        return .failed
    }
    //filter out everything but translate
    let filteredList = commandList.filter { $0 == "translate" }
    //check to make sure it says translate 5 times
    guard  filteredList.count == 5 else { return .failed }
    //check the translated list, make sure something is there
    guard let translationList = dataList else {
            return .failed
    }
    let translated = [
        "First, you must shine red", // French
        "Next, wave your arm twice", // German
        "Shine yellow", // Korean
        "Put your arm down", // Portuguese
        "Shine blue, then raise your arm" // Italian
    ]
    var count = 0
    //loop through the translatedList and check to see if the answers are correct
    for returnTranslated in translationList {
        guard let translatedString = returnTranslated as? String else {
            return .failed
        }
        if translatedString.lowercased() != translated[count].lowercased() {
            return .failed
        }
        count += 1
    }
    return .passed
}

