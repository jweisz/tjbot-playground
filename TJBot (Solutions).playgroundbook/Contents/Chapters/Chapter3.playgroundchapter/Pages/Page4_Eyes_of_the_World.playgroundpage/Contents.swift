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
 In order to complete this exercise, please ensure your TJBot has a microphone, camera, and speaker.
 
 Behind TJBot's left eye there is a camera that allows him to see objects in the real world. Using the [Watson Visual Recognition](https://www.ibm.com/watson/services/visual-recognition/) service, TJBot is able to interpret and understand what he sees.
 
 The method `tj.see()` enables TJBot to see. It tells TJBot to take a picture and interpret it with Watson. It returns a `VisionResponse`, which contains a list of objects TJBot recognized, along with a score that indicates how confident he is about whether or not he identified each object correctly. Confidence levels are in the range [0.0, 1.0], with 1.0 being the highest confidence.
 
 **Goal**: Create a program for TJBot to tell you what he sees using the `tj.listen(_:)`, `tj.see()`, and `tj.speak(_:)` methods.
 
 1. Listen for a speech prompt so TJBot knows you are talking to him. We have defined some example prompts in the code. Check to see that the message returned by `tj.listen(_:)` contains the prompt before calling `tj.see()`. Note that messages returned by `tj.listen(_:)` are all lowercased and don't include punctuation!
 
 2. Announce that TJBot is thinking about what he is seeing. For example, TJBot can say, "Let me think about that."
 
 3. Use `tj.see()` to determine what TJBot is looking at.
 
 * Callout(⚠️ Caution):
 Check the `error` property on the `VisionResponse` just in case Watson returns an error!
 
 4. Use `tj.speak()` to have TJBot say what he is looking at. For example, TJBot can say, "I'm looking at a chair, a person, and a computer." You may wish to check the `confidence` value of each object to make sure TJBot is highly confident in what he is seeing before he announces it!
 
 * Experiment:
 Try having TJBot read text using `tj.read()`.
 */
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(identifier, hide, page, proxy)
//#-code-completion(identifier, show, tj, ., shine(color:), pulse(color:duration:), sleep(duration:), raiseArm(), lowerArm(), wave(), speak(_:), listen(_:), see(), read(), contains(_:), lowercased(), description, VisionResponse, error, objects, VisualObjectIdentification, name, confidence, highestConfidenceObject)
//#-code-completion(literal, show, color)
let tj = PhysicalTJBot()

//#-editable-code
let prompts = [
    "what are you looking at",
    "what are you seeing",
    "what do you see",
    "what can you see"
]

tj.listen { (response) in
    if prompts.contains(response.lowercased()) {
        tj.speak("Let me look around")
        let visionResponse = tj.see()
        if let error = visionResponse.error {
            tj.speak("Uh oh, I can't see anything!")
        } else {
            var msg = "I'm looking at"
            for object in visionResponse.objects {
                guard let last = visionResponse.objects.last else { break }
                if object == last {
                    msg.append(" and a \(object.name).")
                } else {
                    msg.append(" a \(object.name),")
                }
            }
            tj.speak(msg)
        }
    }
}
//#-end-editable-code

//: [Next page: Rock, Paper, TJBot! (Part I)](@next)
