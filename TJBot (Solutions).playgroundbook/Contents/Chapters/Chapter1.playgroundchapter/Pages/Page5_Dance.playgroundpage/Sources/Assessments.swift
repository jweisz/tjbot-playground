/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import UIKit
import PlaygroundSupport


public var pageName: String = "Page_5_DanceDance"
public var successMessage: AssessmentSuccess = "Congratulations! You have taught Tinker how to become a real TJBot! \n\n[**Next Page**](@next)"
public var successBeeCommand: RebusTheBeeCommand?
public var successBotCommand: TJBotInternalCommand = .botDance

/**
 * Evaluate Method
 * - custom method for each Page to determine if the user properly did the page challenge
 * - accepts
 */
public func evaluate(commandList: [String]?, dataList: [AnyObject]?) -> AssessmentResult {
    guard let commandList = commandList,
        commandList.contains("shine"),
        commandList.contains("wave"),
        commandList.contains("lowerArm"),
        commandList.contains("raiseArm") else {
        return .failed
    }
    guard let colorList = dataList, colorList.count == 3 else {
        return .failed
    }
    let completed = ["shine", "wave", "wave", "shine", "lowerArm", "shine", "raiseArm"]
    var count = 0
    for command in commandList {
        if command != completed[count] {
            return .failed
        }
        count += 1
    }
    count = 0
    let colors = colorList.flatMap { $0 as? UIColor }
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
    switch count {
    case 0:
        //check if the color is red
        if hue < 0.1 || hue > 0.9 {
            return true
        }
    case 1:
        //check if the colors is yellow
        if hue > 0.10 && hue < 0.19 {
            return true
        }
    case 2:
        //check if the color is blue
        if hue > 0.51 && hue < 0.73 {
            return true
        }
    default:
        return false
    }
    return false
}
 
