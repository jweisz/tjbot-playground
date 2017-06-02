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
 
 Now that he's arrived in a new world, Tinker thinks it's time for a new name.
 
 **Goal**: Give your TJBot a name.
 
 * Callout(💡 How to name your TJBot):
 The name you set below is used to find your TJBot over Bluetooth. This name must be the same as the one you used when setting up your TJBot. If you leave the name below blank, then we will automatically connect to the nearest TJBot. Note that the name is not case sensitive.
 */

PhysicalTJBot.tjbotName = /*#-editable-code*/""/*#-end-editable-code*/

/*:
 * Important:
 If you ever want to connect to a different TJBot, make sure to set the new name on this page and tap the "Run My Code" button.
 
 Let's make sure we have found your TJBot. The code below will connect to your TJBot and pulse the LED yellow.
 */
let tj = PhysicalTJBot()

for _ in 0..<3 {
    tj.pulse(color: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1), duration: 0.5)
}

/*:
 If your TJBot doesn't pulse the LED, please ensure the tjbot-daemon process is running on your TJBot. If you still have issues, please reach out to us by [opening an issue on GitHub](https://github.com/ibmtjbot/tjbot/issues).
 
 Now that you've given your TJBot a name, let's explore what he can do!
 */

//: [Next page: TJBot Tells His Story](@next)
