/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import PlaygroundSupport

public var pageName: String = "Page_2_Wave"
public var successMessage: AssessmentSuccess = "Rebus lands on Tinker's head and prepares to tell him a story! \n\n[**Next Page**](@next)"
public var successBeeCommand: RebusTheBeeCommand = .beeRestOnTJ
public var successBotCommand: TJBotInternalCommand?

/**
 * Evaluate Method
 * - custom method for each Page to determine if the user properly did the page challenge
 * - accepts
 */
public func evaluate(commandList: [String]?, dataList: [AnyObject]?) -> AssessmentResult {
    guard let commandList = commandList,
                commandList.contains("wave") else {
        return .failed
    }
    //we have a List of commands so we need to check it for the order to see if its correct
    return .passed
}
