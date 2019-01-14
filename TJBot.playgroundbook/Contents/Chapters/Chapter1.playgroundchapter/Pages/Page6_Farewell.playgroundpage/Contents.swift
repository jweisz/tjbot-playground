//#-hidden-code
/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import PlaygroundSupport
import UIKit

//#-end-hidden-code
/*:
 Before Tinker begins his adventures in the real world, he would like to share his gratitude with Rebus.
 
 **Goal**: Use a combination of the commands you have learned to say goodbye to Rebus in a creative, original way.
 
 * Experiment:
 Use this page to play around with Tinker and Rebus using all of their available commands. Use autocomplete to see everything they can do. For example, try exploring the language and social dimensions returned by Tone Analyzer, or see what other languages you can translate amongst. Be creative, and have fun!
 
 */
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(identifier, hide, page, proxy)
//#-code-completion(identifier, show, tinker, ., rebus, shine(color:), pulse(color:duration:), sleep(duration:), raiseArm(), lowerArm(), wave(), analyzeTone(text:), speak(_:), identifyLanguage(text:), translate(text:sourceLanguage:targetLanguage:), sorted(), description, ToneResponse, error, emotion, language, social, anger, fear, joy, sadness, analytical, confident, tentative, openness, conscientiousness, extraversion, agreeableness, emotionalRange, TJTranslationLanguage, unknown, arabic, chinese, german, english, french, italian, japanese, korean, spanish, portuguese, languageName, LanguageIdentification, language, confidence)
//#-code-completion(literal, show, color)
let tinker = VirtualTJBot()

//#-hidden-code
let page = PlaygroundPage.current
let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy
proxy?.delegate = tinker
//#-end-hidden-code
//#-editable-code
//#-end-editable-code

//: [Next chapter: Building TJBot](@next)
