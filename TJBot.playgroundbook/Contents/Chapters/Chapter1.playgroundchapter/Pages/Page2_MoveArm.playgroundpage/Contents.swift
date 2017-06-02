//#-hidden-code
/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import PlaygroundSupport
import UIKit

//#-end-hidden-code
/*:
 Tinker is bursting with excitement after being reunited with Rebus. Help him catch Rebus' attention by waving at her.
 
 **Goal**: Teach Tinker to wave his arm using the `tinker.wave()` method.
 
 * Experiment:
 Try out Tinker's other methods for moving his arm, `tinker.raiseArm()` and `tinker.lowerArm()`. Also, try a combination of waving and shining the LED.
 
 
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
//#-code-completion(identifier, show, tinker, ., shine(color:), pulse(color:duration:), raiseArm(), lowerArm(), wave())
//#-code-completion(literal, show, color)
//#-end-hidden-code
//#-editable-code
//#-end-editable-code
