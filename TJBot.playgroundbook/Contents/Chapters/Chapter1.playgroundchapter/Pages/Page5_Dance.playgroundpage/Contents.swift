//#-hidden-code
/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import PlaygroundSupport
import UIKit

//#-end-hidden-code
/*:
 After translating Rebus' message, Tinker has learned the steps needed to transform into a real, live TJBot.
 
 **Goal**: Perform the Dance of the TJBot 🤖🕺
 
 1. First, you must shine red.
 2. Next, wave your arm twice.
 3. Shine yellow.
 4. Put your arm down.
 5. Shine blue, then raise your arm.
 
 */
let tinker = VirtualTJBot()

//#-hidden-code
let page = PlaygroundPage.current
let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy
tinker.assessorDelegate = TaskAssessorDelegate(success: successMessage, hints: nil, successBeeCommand: successBeeCommand, successTJBotInternalCommand: successBotCommand)
proxy?.delegate = tinker
//#-end-hidden-code
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(identifier, hide, page, proxy)
//#-code-completion(identifier, show, tinker, ., shine(color:), pulse(color:duration:), sleep(duration:), raiseArm(), lowerArm(), wave())
//#-code-completion(literal, show, color)
//#-editable-code
//#-end-editable-code
