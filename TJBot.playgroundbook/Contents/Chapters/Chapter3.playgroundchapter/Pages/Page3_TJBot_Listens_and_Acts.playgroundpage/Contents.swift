//#-hidden-code
/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import PlaygroundSupport
import UIKit

PlaygroundPage.current.assessmentStatus = .pass(message: nil)
PlaygroundPage.current.needsIndefiniteExecution = true
//#-end-hidden-code
/*:
 * Callout(🤖 TJBot Hardware):
 In order to complete this exercise, please ensure your TJBot has an LED and a microphone.
 
 TJBot can listen to your voice and understand what you say using the [Watson Speech to Text](https://www.ibm.com/watson/developercloud/speech-to-text.html) service.
 
 **Goal**: Control the color of your TJBot's LED with your voice. Use the `tj.listen(_:)` method to listen for a speech command to change the LED color (hint: we like to use the phrasing, "turn the light yellow"). Determine what color to change the LED, and use `tj.shine(color:)` to change the color.
 
 We have defined an array of colors to make it easier to interpret which color TJBot should shine. Try adding additional colors to make TJBot even more vibrant!
 
 * Experiment:
 In addition to controlling the LED, add voice commands to control TJBot's arm.
 
 */
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(identifier, hide, page, proxy)
//#-code-completion(identifier, show, tj, ., shine(color:), pulse(color:duration:), sleep(duration:), raiseArm(), lowerArm(), wave(), speak(_:), listen(_:), components(separatedBy:), contains(_:))
//#-code-completion(literal, show, color)
let tj = PhysicalTJBot()

//#-editable-code
var colors = [
    "red": #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1),
    "green": #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1),
    "blue": #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1),
    "yellow": #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
]

//#-end-editable-code

//: [Next page: Eyes of the World](@next)
