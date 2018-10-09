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
 
 1. First, you have to shine red.
 2. Next, wave your arm twice.
 3. Make a bright yellow light.
 4. Put your arm down.
 5. Emit blue light, then raise your arm.
 
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
tinker.shine(color: #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1))
tinker.wave()
tinker.wave()
tinker.shine(color: #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1))
tinker.lowerArm()
tinker.shine(color: #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1))
tinker.raiseArm()
//#-end-editable-code
