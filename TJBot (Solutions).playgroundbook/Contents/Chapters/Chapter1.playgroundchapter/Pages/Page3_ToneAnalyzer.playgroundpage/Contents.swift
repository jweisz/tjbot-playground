//#-hidden-code
/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import PlaygroundSupport
import UIKit

//#-end-hidden-code
/*:
 Rebus begins telling Tinker about all the crazy things she witnessed during her travels. Her tales take Tinker on a roller coaster of emotion, from anger and disgust, to fear, joy, and sadness.
 
 **Goal**: Help Tinker understand the emotional content of Rebus' story using the [Watson Tone Analyzer](https://www.ibm.com/watson/developercloud/tone-analyzer.html) service.
 
 1. Open the [Watson Tone Analyzer](https://console.bluemix.net/catalog/services/tone-analyzer) page and tap the "Create" button on the bottom right to create an instance of the service. Sign up for a free Bluemix account if you do not have one already.
 
 2. Tap "Service Credentials" in the left-hand sidebar, then tap "View Credentials" under the Actions menu.
 
 ![Tone Analyzer Credentials](tone-analyzer-credentials.png)
 
 3. Fill in your service credentials below. Note that these credentials are saved for future exercises and if you ever need to change your credentials, you will need to re-run this page.
 */
Watson.toneAnalyzer.username =
    /*#-editable-code*/""/*#-end-editable-code*/
Watson.toneAnalyzer.password =
    /*#-editable-code*/""/*#-end-editable-code*/
/*:
 4. Use the `tinker.analyzeTone()` method to analyze the tone of a sentence. For each sentence, use `rebus.speak(:_)` to speak the sentence. In addition, shine the LED based on the dominant emotion using the color guide below. 
 
 ![TJBot emotions](tjbot-emotions.png)
 
 - - -
 * Callout(💡 Tip):
 `tinker.analyzeTone()` returns a `ToneResponse`, which contains the different dimensions of tone analysis performed by Watson: emotional content, language style, and social tendencies. Use the `emotion` dimension to determine the degree to which a given sentence contains the emotions of joy, anger, disgust, fear, and sadness (1.0 is the highest level). It may help to create a helper function that examines a `ToneResponse` and returns the dominant `Emotion` (e.g. the one with the highest value).
 
 - - -
 * Callout(⚠️ Caution):
 Check the `error` property on the `ToneResponse` just in case Watson returned an error!
 
 */
let tinker = VirtualTJBot()
let rebus = RebusTheBee()

enum Emotion: String {
    case anger
    case disgust
    case fear
    case joy
    case sadness
    case unknown
}

//#-hidden-code
let page = PlaygroundPage.current
let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy
tinker.assessorDelegate = TaskAssessorDelegate(success: successMessage, hints: nil, successBeeCommand: successBeeCommand, successTJBotInternalCommand: successBotCommand, pageName: pageName)
proxy?.delegate = tinker
//#-end-hidden-code
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(identifier, hide, page, proxy)
//#-code-completion(identifier, show, tinker, ., rebus, shine(color:), pulse(color:duration:), sleep(msec:), raiseArm(), lowerArm(), wave(), analyzeTone(text:), speak(_:), sorted(), description, ToneResponse, error, emotion, language, social, anger, disgust, fear, joy, sadness, analytical, confident, tentative, openness, conscientiousness, extraversion, agreeableness, emotionalRange)
//#-code-completion(literal, show, color)
//#-code-completion(keyword, show, for)
let story: [String] = [
    // Rebus' story is hidden in this array. Iterate over it to hear the story!
    //#-hidden-code
    "The world of YouTube is one of the strangest places I've ever been. When I first arrived, I was swarmed by a mob of the most adorable puppies and kittens -- it was amazing!", // joy
    "Not long afterwards, I met a man who had become a millionaire by eating gross foods on camera -- the things humans find valuable never cease to amaze me.", // disgust
    "I stopped in a small town called 4chan. There was a man hanging out at the rest stop, so I asked him if he could watch my suitcase while I used the ladybee's room. When I came back out, the man was gone and so was my suitcase. In its place was a drawing of a troll with a cruel grin on its face. I've never been so angry in my life!", // anger
    "I was told that a man named Craig had a giant list of things for sale, so I decided to go see if he could help me replace my suitcase. But when I got there, I discovered that Craig's list was full of strange and scary items. I was quite frightened by what I saw, so I decided to get out of there as quick as possible!", // fear
    "All in all, it was an interesting and eye-opening journey. I'm sad you couldn't join me." // sadness
    //#-end-hidden-code
]

//#-editable-code
func getPrimaryEmotion(from toneResponse: ToneResponse) -> Emotion {
    if (toneResponse.error != nil) {
        return .unknown
    }
    
    let dict: [Emotion: Double] = [
        .anger: toneResponse.emotion.anger,
        .disgust: toneResponse.emotion.disgust,
        .fear: toneResponse.emotion.fear,
        .joy: toneResponse.emotion.joy,
        .sadness: toneResponse.emotion.sadness
    ]
    
    let sortedEmotions = Array(dict).sorted {$0.1 > $1.1}
    guard let first = sortedEmotions.first else { return .unknown }
    return first.key
}

for sentence in story {
    let response = tinker.analyzeTone(text: sentence)
    let emotion = getPrimaryEmotion(from: response)
    
    rebus.speak(sentence)
    
    switch emotion {
    case .unknown:
        break
    case .anger:
        tinker.shine(color: UIColor.red)
    case .disgust:
        tinker.shine(color: UIColor.green)
    case .fear:
        tinker.shine(color: UIColor.purple)
    case .joy:
        tinker.shine(color: UIColor.yellow)
    case .sadness:
        tinker.shine(color: UIColor.blue)
    }
}
//#-end-editable-code
