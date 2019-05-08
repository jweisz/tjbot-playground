//#-hidden-code
/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import PlaygroundSupport
import UIKit

//#-end-hidden-code
/*:
 After recounting her travels, Rebus gets to the real purpose of her visit. Deep in the bowels of the dark web, she learned of a secret of great import to the TJBot kind: a magical dance that enables virtual robots to transform themselves into real live TJBots!
 
 * callout(🐝 Rebus' message):
 Tinker, my friend, I have traveled far and wide in the deep web and have discovered a secret, magical dance that will allow you to transform into a real, live TJBot!  Isn't that exciting?  Here are the dance moves you need to perform. D'abord, tu dois briller rouge. Als nächstes, winken Sie den Arm zweimal. 밝은 노란색으로 밝은 빛을 만들다. Coloque seu braço para baixo. Emetti luce blu, poi alza il braccio. It's that simple!
 
 **Goal**: Rebus told Tinker the instructions for the secret dance, but Tinker didn't understand what she said! Teach Tinker how to interpret the secret dance moves using the [Watson Language Translator](https://www.ibm.com/watson/services/language-translator/) service.
 
 1. Open the [Watson Language Translator](https://console.bluemix.net/catalog/services/language-translator) page and tap the "Create" button on the bottom right to create an instance of the service. Sign up for a free Bluemix account if you do not have one already.
 
 2. Tap "Manage" in the left-hand sidebar, then tap "Show Credentials".
 
 ![Language Translator Credentials](language-translator-credentials.png)
 
 3. Fill in the `apikey` credential below. Note that this credential is saved for future exercises and if you ever need to change your credential, you will need to re-run this page.
 */
Watson.languageTranslator.apikey =
    /*#-editable-code*/""/*#-end-editable-code*/
/*:
 
 4. Use the `tinker.identifyLanguage(text:)` and `tinker.translate(text:sourceLanguage:targetLanguage:)` methods to translate Rebus' instructions into English.
 
 5. Call `rebus.speak(_:)` for each translated sentence to learn the dance moves.
 
 - - -
 
 * Callout(💡 Tip):
 `tinker.identifyLanguage(text:)` will return an array of type `[LanguageIdentification]`. We have extended this type to add a property called `highestConfidenceLanguage` that will help you easily find the language with the highest translation confidence.
 */
let tinker = VirtualTJBot()
let rebus = RebusTheBee()

//#-hidden-code
let page = PlaygroundPage.current
let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy
tinker.assessorDelegate = TaskAssessorDelegate(success: successMessage, hints: nil, successBeeCommand: successBeeCommand, successTJBotInternalCommand: successBotCommand, pageName: pageName)
proxy?.delegate = tinker
//#-end-hidden-code
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(identifier, hide, page, proxy)
//#-code-completion(identifier, show, tinker, ., rebus, shine(color:), pulse(color:duration:), sleep(duration:), raiseArm(), lowerArm(), wave(), analyzeTone(text:), speak(_:), identifyLanguage(text:), translate(text:sourceLanguage:targetLanguage:), TJTranslationLanguage, unknown, arabic, chinese, german, english, french, italian, japanese, korean, spanish, portuguese, languageName, LanguageIdentification, language, confidence, highestConfidenceLanguage)
//#-code-completion(literal, show, color)
//#-code-completion(keyword, show, for)
let instructions = [
    "D'abord, tu dois briller rouge",
    "Als nächstes, winken Sie den Arm zweimal",
    "밝은 노란색으로 밝은 빛을 만들다",
    "Coloque seu braço para baixo",
    "Emetti luce blu, poi alza il braccio"
]
//#-editable-code
for message in instructions {
    let candidates = tinker.identifyLanguage(text: message)
    let language = candidates.highestConfidenceLanguage
    let translatedMessage = tinker.translate(text: message, sourceLanguage: language, targetLanguage: .english)
    if let translated = translatedMessage {
        rebus.speak(translated)
    }
}
//#-end-editable-code
