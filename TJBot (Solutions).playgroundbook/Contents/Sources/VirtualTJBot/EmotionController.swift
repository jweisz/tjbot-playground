/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import SceneKit

enum BotEmotion: String {
    case anger
    case disgust
    case fear
    case joy
    case sadness
}

enum BotEmotionImages: String {
    case anger = "Anger.png"
    case disgust = "Disgust.png"
    case fear = "Fear.png"
    case joy = "Joy.png"
    case sadness = "Sadness.png"
}

class EmotionController {
    var emotionDisplay: SCNNode!

    init (displayNode: SCNNode) {
        self.emotionDisplay = displayNode
    }

    func showEmotion(_ emotion: BotEmotionImages) {
        // Load image and set emotion
        let image = UIImage(named: "art.scnassets/Emotion/\(emotion.rawValue)")
        emotionDisplay.isHidden = false
        emotionDisplay.geometry?.firstMaterial?.diffuse.contents = image
        emotionDisplay.geometry?.firstMaterial?.emission.contents = image

        // Hide emotion after 10 sec.
        //emotionDisplay.runAction(SCNAction.wait(duration: 10), completionHandler: {_ in self.hideDisplay()})
    }

    func hideDisplay() {
        emotionDisplay.isHidden = true
    }
}
