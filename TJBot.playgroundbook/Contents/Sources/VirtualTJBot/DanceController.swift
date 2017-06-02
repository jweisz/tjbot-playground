/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import SceneKit

enum MouthPosition: String {
    case open
    case closed
}

enum AsyncFunctions: String {
    case lightColor
    case jump
    case moveMouth
    case wait
}

// MARK: Delegation Protocol

protocol DanceControllerDelegate: class {

    // Arm commands
    func danceMoveArm(_ position: Position, duration: Double) -> SCNAction
    func danceWave()
    func slowWave(_ duration: Double) -> SCNAction

    // Light commands
    func danceLightColor(_ color: UIColor)

    // Music commands
    func removeDanceMusic()
}

final class DanceController {
    weak var delegate: DanceControllerDelegate?

    let totalDuration: Double = 60

    // One node per action sequence
    let armNode: SCNNode
    let bodyNode: SCNNode
    let mouthNode: SCNNode
    let lightNode: SCNNode
    let musicNode: SCNNode

    init (armNode: SCNNode, bodyNode: SCNNode, mouthNode: SCNNode, lightNode: SCNNode, musicNode: SCNNode) {
        self.armNode = armNode
        self.bodyNode = bodyNode
        self.mouthNode = mouthNode
        self.lightNode = lightNode
        self.musicNode = musicNode
    }

    public func startDance() {
        resetAll()

        musicNode.runAction(SCNAction.wait(duration: totalDuration),
                            completionHandler: {_ in self.delegate?.removeDanceMusic()})

        startArmSequence()
        startMouthSequence()
        startBodySequence()
        startLightSequence()
    }

    // Arm commands
    func startArmSequence() {
        if let objectDelegate = delegate {
            var armSequence: [SCNAction] = []
            let slowWave = objectDelegate.slowWave(0.5)
            let _ = objectDelegate.danceMoveArm(.up, duration: 1.0)
            let handMid = objectDelegate.danceMoveArm(.middle, duration: 1.0)
            let handDown = objectDelegate.danceMoveArm(.down, duration: 1.0)

            for _ in 0...5 {
                armSequence.append(SCNAction.wait(duration: 2.0))
                armSequence.append(slowWave)
                armSequence.append(slowWave)
                armSequence.append(slowWave)
                armSequence.append(slowWave)
                armSequence.append(handDown)
            }
            armSequence.append(SCNAction.wait(duration: 2.0))
            armSequence.append(slowWave)
            armSequence.append(slowWave)
            armSequence.append(handMid)
            armNode.runAction(SCNAction.sequence(armSequence))
        }
    }

    // Body commands
    func startBodySequence() {
        bodyNode.runAction(SCNAction.wait(duration: 2.4),
                           completionHandler: {_ in self.bodyNode.runAction(self.bodyBounce(true), forKey: "bounce")})
        bodyNode.runAction(SCNAction.wait(duration: 48.2),
                           completionHandler: {_ in self.bodyNode.removeAction(forKey:"bounce")})
        bodyNode.runAction(SCNAction.wait(duration: 48.5),
                           completionHandler: {_ in self.bodyNode.runAction(self.bodyBounce(false))})
    }

    func bodyBounce(_ activate: Bool) -> SCNAction {
        var action: SCNAction
        if activate {
            let moveUp = SCNAction.move(to: SCNVector3Make(0, 0.59, 0), duration: 0.6)
            moveUp.timingMode = .easeInEaseOut
            let moveDown = SCNAction.move(to: SCNVector3Make(0, 0.42, 0), duration: 0.6)
            moveDown.timingMode = .easeInEaseOut
            action = SCNAction.repeatForever(SCNAction.sequence([moveUp, moveDown]))
        } else {
            action = SCNAction.move(to: SCNVector3Make(0, 0.569, 0), duration: 0.2)
            action.timingMode = .easeOut
        }
        return action
    }

    // Mouth commands
    func startMouthSequence() {
        var mouthSequence: [SCNAction] = []
        let openMouth = moveMouth(.open, duration: 0.3)
        let closeMouth = moveMouth(.closed, duration: 0.3)

        mouthSequence.append(openMouth)
        mouthSequence.append(SCNAction.wait(duration: 1.5))
        mouthSequence.append(closeMouth)

        mouthNode.runAction(SCNAction.sequence(mouthSequence))
    }

    func moveMouth(_ position: MouthPosition, duration: Double) -> SCNAction {
        var angle: CGFloat
        switch position {
        case .open:
            angle = -0.2
            break
        case .closed:
            angle = 0
            break
        }
        let action = SCNAction.rotateTo(x: angle, y: 0, z: 0, duration: 0.3, usesShortestUnitArc: true)
        action.timingMode = .easeInEaseOut
        return action
    }

    // Light commands
    func startLightSequence() {
        var startAt: Double = 0
        while startAt < totalDuration {
            startAt += changeLightColor(UIColor.blue, startAt: startAt, duration: 1.2)
            startAt += changeLightColor(UIColor.yellow, startAt: startAt, duration: 1.2)
            startAt += changeLightColor(UIColor.green, startAt: startAt, duration: 1.2)
            startAt += changeLightColor(UIColor.red, startAt: startAt, duration: 1.2)
            startAt += changeLightColor(UIColor.white, startAt: startAt, duration: 1.2)
        }
    }

    func changeLightColor(_ color: UIColor, startAt: Double, duration: Double) -> Double {
        lightNode.runAction(SCNAction.wait(duration: startAt),
                            completionHandler: {_ in self.delegate?.danceLightColor(color)})
        return duration
    }

    func resetAll() {
        self.delegate?.removeDanceMusic()
        armNode.removeAllActions()
        bodyNode.removeAllActions()
        mouthNode.removeAllActions()
        lightNode.removeAllActions()
        musicNode.removeAllActions()
    }
}
