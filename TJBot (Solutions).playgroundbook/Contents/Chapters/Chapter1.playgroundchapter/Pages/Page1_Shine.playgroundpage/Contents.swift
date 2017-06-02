//#-hidden-code
/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import PlaygroundSupport
import UIKit

//#-end-hidden-code
/*:
 Tinker is lonely in his very dark screen. Fortunately, he has an LED light on top of his head!
 
 **Goal**: Help Tinker illuminate his surroundings by shining his light using the `tinker.shine(color:)` method.
 
 * Experiment:
 Try out Tinker's other LED method, `tinker.pulse(color:duration:)`. This method pulses the LED for the given duration (in seconds). Tinker can also be put to sleep with `tinker.sleep(duration:)` in case you want to add a pause between shining or pulsing.
 
 
 */
let tinker = VirtualTJBot()

//#-hidden-code
let page = PlaygroundPage.current
let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy
tinker.assessorDelegate = TaskAssessorDelegate(success: successMessage, hints: nil, successBeeCommand: successBeeCommand, successTJBotInternalCommand: successBotCommand)
proxy?.delegate = tinker

//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(identifier, hide, page, proxy)
//#-code-completion(identifier, show, tinker, ., shine(color:), pulse(color:duration:), sleep(duration:))
//#-code-completion(literal, show, color)
//#-end-hidden-code
//#-editable-code
tinker.shine(color: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1))
//#-end-editable-code
