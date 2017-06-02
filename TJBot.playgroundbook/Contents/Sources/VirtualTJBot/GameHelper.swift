/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import SceneKit

class GameHelper {
    static let sharedInstance = GameHelper()

    var sounds: [String: SCNAudioSource] = [: ]

    func loadSound(name: String, fileNamed: String) {
        if let sound = SCNAudioSource(fileNamed: fileNamed) {
            sound.isPositional = false
            sound.volume = 0.3
            sound.load()
            sounds[name] = sound
        }
    }

    func playSound(node: SCNNode, name: String) {
        let sound = sounds[name]
        node.runAction(SCNAction.playAudio(sound!, waitForCompletion: false))
    }
}
