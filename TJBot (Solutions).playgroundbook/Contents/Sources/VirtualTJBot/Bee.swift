/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import SceneKit

public enum BeeStartPosition: String {
    case botHead
    case botArm
    case outOfScreen
}

enum WingsPosition: String {
    case forward
    case center
    case back
}

class Bee {
    var flyingPoints: [SCNNode]?
    var bee: SCNNode
    var wings: SCNNode

    var isFlying = false
    
    var node: SCNNode {
        return bee
    }

    init(node: SCNNode, startPosition: SCNNode, flyingPositions: [SCNNode]?) {
        self.flyingPoints = flyingPositions
        self.bee = node
        self.wings = node.childNode(withName: "WingsControl", recursively: true)!

        let positionInSelf = startPosition.convertPosition(SCNVector3Make(0, 0, 0), to: nil)
        bee.position = positionInSelf
    }

    func moveToRandom() {
        // Check wings movement
        if !isFlying {
            TJLog("Bee calling moveWings()")
            moveWings()
            TJLog("Bee moveWings() called")
        }

        // Select a random point from array
        let newPos = randomPoint().position
        let moveTo = SCNAction.move(to: newPos, duration: 3)
        TJLog("Bee calling runAction()")
        bee.runAction(moveTo, completionHandler: { _ in
            TJLog("Bee completionHandler calling moveToRandom()")
            self.moveToRandom()
            TJLog("Bee completionHandler called moveToRandom()")
        })
        TJLog("Bee runAction() called")
    }

    func restOn(destination: SCNVector3) {
        bee.removeAllActions()

        if !isFlying {
            moveWings()
        }
        let moveTo = SCNAction.move(to: destination, duration: 1.5)
        bee.runAction(moveTo, completionHandler: {_ in self.stopWings()})
    }

    fileprivate func randomPoint() -> SCNNode {
        let pointIndex = Int(arc4random_uniform(UInt32(flyingPoints!.count)))
        return (flyingPoints![pointIndex])
    }

    fileprivate func moveWings() {
        let movementSequence = SCNAction.sequence([moveWingsTo(position: .forward),
                                                   moveWingsTo(position: .center),
                                                   moveWingsTo(position: .back),
                                                   moveWingsTo(position: .center)])

        wings.runAction(SCNAction.repeatForever(movementSequence))

        isFlying = true
    }

    fileprivate func moveWingsTo(position: WingsPosition) -> SCNAction {
        var angle: CGFloat

        switch position {
        case .forward:
            angle = 30
        case .center:
            angle = 0
        case .back:
            angle = -30
        }

        let action = SCNAction.rotateTo(x: angle, y: 0, z: 0, duration: 0.05, usesShortestUnitArc: true)
        action.timingMode = .linear

        return action
    }

    fileprivate func stopWings() {
        wings.removeAllActions()
        wings.runAction(moveWingsTo(position: .center))
        isFlying = false
    }
}
