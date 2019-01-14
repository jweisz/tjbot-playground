/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import UIKit
import PlaygroundSupport

public var pageName: String = "Page_3_Emotional"
public var successMessage: AssessmentSuccess = "Tinker has vertigo after that emotional rollercoaster! \n\n[**Next Page**](@next)"
public var successBeeCommand: RebusTheBeeCommand?
public var successBotCommand: TJBotInternalCommand?


public var hints: AssessmentHints = [
    "Use the colored diagrams to know what color to turn Tinker's light.",
    "The autocomplete feature will show all of Tinker's arm capabilities."
]

/**
 * Evaluate Method
 * - custom method for each Page to determine if the user properly did the page challenge
 * - accepts
 */
public func evaluate(commandList: [String]?, dataList: [AnyObject]?) -> AssessmentResult {
    //this should contain 4 shines
    guard let commandList = commandList,
                commandList.contains("shine"),
                commandList.count == 4 else {
        return .failed
    }
    for command in commandList {
        guard command == "shine" else { return .failed }
    }
    //this should contain 4 specific colors
    guard let colorList = dataList,
              colorList.count == 4 else {
        return .failed
    }
    var count = 0
    let colors = colorList.compactMap { $0 as? UIColor }
    for color in colors {
        if !checkColorInRange(color: color, count: count) {
            return .failed
        }
        count += 1
    }
    return .passed
}

func checkColorInRange(color: UIColor, count: Int) -> Bool {
    var hue: CGFloat = 0.0
    var sat: CGFloat = 0.0
    var bright: CGFloat = 0.0
    var alpha: CGFloat = 0.0
    let hueConversion = color.getHue(&hue, saturation: &sat, brightness: &bright, alpha: &alpha)
    let hueDegrees = hue * 360
    switch count {
    case 0:
        // JOY check if the colors is yellow
        if hueDegrees > 50 && hueDegrees < 70 {
            return true
        }
    case 1:
        //Anger
        //check if the color is red
        if hueDegrees < 35 || hueDegrees > 340 {
            return true
        }
    case 2:
       //Fear
        //check if the color is Magenta
        if hueDegrees > 270 && hueDegrees < 340 {
            return true
        }
    case 3:
        //check if the color is blue
        if hueDegrees > 170 && hueDegrees < 255 {
            return true
        }
    default:
        return false
    }
    return false
}

//order that is should come in
//joy
//anger
//fear 
//sadness
