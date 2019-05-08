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
 * Callout(🤖 TJBot Hardware):
 In order to complete this exercise, please ensure your TJBot has a speaker.
 
 Your TJBot now has the ability to speak! Using the [Watson Text to Speech](https://www.ibm.com/watson/services/text-to-speech/) service, your TJBot is able to express himself with his own voice.
 
 **Goal**: Have your TJBot tell you the details of his life's story aloud. Use the `generateLifeStory()` method to generate TJBot's life story, and the `tj.speak()` method to make your TJBot speak!
 */
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(identifier, hide, page, proxy)
//#-code-completion(identifier, show, tj, ., speak(_:), generateLifeStory())
let tj = PhysicalTJBot()

let lifeStory = [
    "yourName": /*#-editable-code*/""/*#-end-editable-code*/,
    "favoriteCity": /*#-editable-code*/""/*#-end-editable-code*/,
    "favoriteFood": /*#-editable-code*/""/*#-end-editable-code*/,
    "favoriteExercise": /*#-editable-code*/""/*#-end-editable-code*/,
    "favoriteColor": /*#-editable-code*/""/*#-end-editable-code*/,
    "favoriteBand": /*#-editable-code*/""/*#-end-editable-code*/
]
//#-hidden-code
func generateLifeStory() -> String {
    func value(from dictValue: String?, defaultingTo defaultValue: String) -> String {
        if let value = dictValue, !value.isEmpty {
            return value
        } else {
            return defaultValue
        }
    }
    
    let name = value(from: lifeStory["yourName"], defaultingTo: "human")
    let city = value(from: lifeStory["favoriteCity"], defaultingTo: "on Mars")
    let food = value(from: lifeStory["favoriteFood"], defaultingTo: "sushi")
    let exercise = value(from: lifeStory["favoriteExercise"], defaultingTo: "jumping jacks")
    let color = value(from: lifeStory["favoriteColor"], defaultingTo: "red")
    let band = value(from: lifeStory["favoriteBand"], defaultingTo: "the grateful dead")
    
    return "Hello \(name)!  My name is \(tj.configuration.name). It's nice to meet you! I was designed with love by IBM researchers in New York, but if I could live anywhere it would be \(city). I can't eat anything, but if I did, I'd eat \(food) every single day. My legs don't work yet but if I could exercise, I would do \(exercise) all the time. If I had any money, I would buy a \(color) car and drive down the highway listening to \(band) on the radio."
}
//#-end-hidden-code
//#-editable-code
let story = generateLifeStory()
tj.speak(story)
//#-end-editable-code

//: [Next page: Listen and Act](@next)
