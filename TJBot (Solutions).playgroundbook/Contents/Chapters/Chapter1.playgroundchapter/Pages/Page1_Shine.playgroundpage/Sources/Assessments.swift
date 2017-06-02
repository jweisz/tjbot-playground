/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import PlaygroundSupport


public var pageName: String = "Page1_Shine"
public var successMessage: AssessmentSuccess = "Tinker's LED has attracted his old friend Rebus the Bee! She has much to share with Tinker spending months and months buzzing around the interwebs. \n\n[**Next Page**](@next)"
public var successBeeCommand: RebusTheBeeCommand = .beeAppear
public var successBotCommand: TJBotInternalCommand?

/**
 * Evaluate Method
 * - custom method for each Page to determine if the user properly did the page challenge
 * - accepts
 */
public func evaluate(commandList: [String]?, dataList: [AnyObject]?) -> AssessmentResult {
    //need to convert playground values to actual strings or data, only 2 types
    guard let commandList = commandList, commandList.contains("shine") else {
        return .failed
    }
    //we have a List of commands so we need to check it for the order to see if its correct
    return .passed
}
