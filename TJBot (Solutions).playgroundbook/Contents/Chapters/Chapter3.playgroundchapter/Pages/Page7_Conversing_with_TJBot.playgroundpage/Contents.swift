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
 In order to complete this exercise, please ensure your TJBot has a microphone and a speaker.
 
 Did you know you can turn TJBot into a chatbot? TJBot has the ability to engage in a back-and-forth conversation using the [Watson Conversation](https://www.ibm.com/watson/developercloud/conversation.html) service.
 
 * Callout(⚠️ Prerequisite):
 In order to complete this exercise, you will need to define a conversation flow in the [Watson Conversation tool](https://www.ibmwatsonconversation.com/login). Step-by-step instructions for how to do this can be found in this [Instructable](http://www.instructables.com/id/Build-a-Talking-Robot-With-Watson-and-Raspberry-Pi/) (step 6). Log into the [Watson Conversation tool](https://www.ibmwatsonconversation.com/login) tool to create a conversation flow, and take note of the Workspace ID. Note that you need a [Bluemix](http://bluemix.net) account to be able to use the Watson Conversation tool.
 
 **Goal**: Engage in a conversation with TJBot using the `tj.converse(workspaceId:message:)`, `tj.listen(_:)`, and `tj.speak(_:)` methods.
 
 * Callout(💡 Tip):
 If you are near your computer, you can import a sample TJBot conversation flow into the Watson Conversation tool. Check out the [Conversation recipe](https://github.com/ibmtjbot/tjbot/tree/master/recipes/conversation) in TJBot's [GitHub repository](https://github.com/ibmtjbot/tjbot). It has a sample conversation file you can use to get started.
 
 The `tj.converse(workspaceId:message:)` method returns a `ConversationResponse` object. This object contains the `text` response that TJBot should speak.
 
 * Callout(⚠️ Caution):
 Check the `error` property on the `ConversationResponse` just in case Watson returns an error!
 
 
 */
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(identifier, hide, page, proxy)
//#-code-completion(identifier, show, tj, ., shine(color:), pulse(color:duration:), raiseArm(), lowerArm(), wave(), sleep(duration:), speak(_:), listen(_:), see(), read(), converse(workspaceId:message:), description, ConversationResponse, error, text)
//#-code-completion(literal, show, color)
let tj = PhysicalTJBot()

let workspaceId = /*#-editable-code*/""/*#-end-editable-code*/

//#-editable-code
tj.listen { (message) in
    let response = tj.converse(workspaceId: workspaceId, message: message)
    if let error = response.error {
        tj.speak("I'm not sure how to respond to that.")
    } else if let text = response.text {
        tj.speak(text)
    }
}
//#-end-editable-code

//: [Next page: TJBot's Adventures with You](@next)
