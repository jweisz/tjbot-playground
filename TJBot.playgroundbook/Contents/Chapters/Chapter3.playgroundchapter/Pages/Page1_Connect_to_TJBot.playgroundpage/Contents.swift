//#-hidden-code
/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import PlaygroundSupport
import UIKit

PlaygroundPage.current.assessmentStatus = .pass(message: nil)
//#-end-hidden-code
/*:
 Tinker has completed his transformation into a physical TJBot!
 
 Now that he's arrived in a new world, Tinker would like to show you how to connect to him.
 
 **Goal**: Connect to your TJBot.
 
 1. Tap "Connect TJBot" and choose your TJBot from the list.
 
 2. Tap "Run My Code" to make your TJBot shine!
 
 * Experiment: Try changing the colors your TJBot pulses, how many times he pulses, and the duration of each pulse.
 */
//#-hidden-code
extension Array {
    var randomElement: Element {
        let randomIndex = Int(arc4random_uniform(UInt32(self.count)))
        return self[randomIndex]
    }
}
//#-end-hidden-code
let tj = PhysicalTJBot()

let colors = [/*#-editable-code*/#colorLiteral(red: 1, green: 0.1492801309, blue: 0, alpha: 1), #colorLiteral(red: 0, green: 0.9768045545, blue: 0, alpha: 1), #colorLiteral(red: 0.01680417731, green: 0.1983509958, blue: 1, alpha: 1), #colorLiteral(red: 1, green: 0.9439396262, blue: 0.00457396172, alpha: 1), #colorLiteral(red: 0, green: 0.991381228, blue: 0.9948161244, alpha: 1), #colorLiteral(red: 1, green: 0.6262393594, blue: 0.1212334707, alpha: 1), #colorLiteral(red: 0.5819275379, green: 0.3353917003, blue: 0.8818522096, alpha: 1), #colorLiteral(red: 0.9981537461, green: 0, blue: 0.9764257073, alpha: 1)/*#-end-editable-code*/]

for _ in 0 ..< /*#-editable-code*/6/*#-end-editable-code*/ {
    tj.pulse(color: colors.randomElement, duration: /*#-editable-code*/0.5/*#-end-editable-code*/)
}

/*:
 If your TJBot doesn't pulse the LED, please ensure the tjbot-daemon process is running on your TJBot. If you still have issues, please reach out to us by [opening an issue on GitHub](https://github.com/ibmtjbot/tjbot/issues).
 
 Now that you know how to connect to your TJBot, let's explore what he can do!
 */

//: [Next page: TJBot Tells His Story](@next)
