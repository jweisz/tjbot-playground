/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import SceneKit

enum QueueWaitMode: String {
    case wait
    case noWait
}

enum QueueActionType: String {
    case nodeAction
    case removeAllNodeActions
    case functionCall
}

enum QueueCommand {
    case QC_ChangeSceneColor
    case QC_RemoveAllNodeActions
    case QC_PlaySound
    case QC_ChangeMusic
    case QC_BeeSpeak
}

protocol Queues {
    func runActionQueue() -> Bool
}

// MARK: Delegation Protocol
protocol VirtualTJBotActionsQueueDelegate: class {
    func changeSceneColor(color: UIColor)
    func playSound(name: String)
    func changeMusic(fileNamed: String)
    func beeWillSpeak(message: String)
    func actionQueueDidFinish()
    
}

// MARK: Define Supported objects in queue Array
protocol ActionQueueElement {
    var type: QueueActionType { get }
}

struct AnimationAction: ActionQueueElement {
    var type: QueueActionType
    let node: SCNNode
    let action: SCNAction
    let waitingMode: QueueWaitMode

    public init(node: SCNNode, waitingMode: QueueWaitMode = .noWait) {
        self.type = .removeAllNodeActions
        self.node = node
        self.action = SCNAction()
        self.waitingMode  = waitingMode
    }

    public init(node: SCNNode, action: SCNAction, waitingMode: QueueWaitMode = .wait) {
        self.type = .nodeAction
        self.node = node
        self.action = action
        self.waitingMode = waitingMode
    }
}

struct FunctionCallAction: ActionQueueElement {
    var type: QueueActionType
    var command: QueueCommand
    var parameter: AnyObject?

    public init(command: QueueCommand, parameter: AnyObject? = nil) {
        self.type = .functionCall
        self.command = command
        self.parameter = parameter
    }
}

// MARK: Queue Class Definition
class VirtualTJBotActionsQueue {
    weak var delegate: VirtualTJBotActionsQueueDelegate?

    var sequence = [ActionQueueElement]()
    var currentActionIndex = 0
    var currentAction: SCNAction?
    var currentNode: SCNNode?

    var containsItems: Bool {
        if sequence.count > 0 {
            return true
        }
        return false
    }
    
    public init() {
    }

    func runActionQueue() -> Bool {
       return executeAction()
    }

    func addAction(node: SCNNode, action: SCNAction, waitingMode: QueueWaitMode) {
        let action = AnimationAction(node: node, action: action, waitingMode: waitingMode)
        enqueue(action)
    }

    func removeAllNodeActions(node: SCNNode) {
        let function = FunctionCallAction(command: .QC_RemoveAllNodeActions, parameter: node)
        sequence.append(function)
    }

    func addFunction(function: QueueCommand, parameter: AnyObject?) {
        let function = FunctionCallAction(command: function, parameter: parameter)
        sequence.append(function)
    }

    func enqueue(_ element: ActionQueueElement) {
        sequence.append(element)
    }

    func dequeue() -> ActionQueueElement? {
        guard !sequence.isEmpty, let element = sequence.first else { return nil }
        
        let _ = sequence.removeFirst()
        return element
    }

    func executeAction() -> Bool {
        //check if queue has anything left
        guard let element = dequeue()  else {
            //call the delegate when actions are done
            delegate?.actionQueueDidFinish()
            return false
        }
        let elementType = element.type
        //switching on QueueActionType
        switch elementType {
        case .nodeAction:
            if let action = element as? AnimationAction {
                runNodeAction(seq: action)
            }
        case .functionCall:
            if let function = element as? FunctionCallAction {
                runNodeCommand(seq: function)
            }
        case .removeAllNodeActions:
            break
        }
        return true
    }

    func runNodeAction(seq: AnimationAction) {
        let currentNode = seq.node
        let currentAction = seq.action
        if seq.waitingMode == .wait {
            let _ = currentNode.runAction(currentAction, completionHandler: { () -> Void in let _ = self.executeAction()})
        } else {
            currentNode.runAction(currentAction)
           let _ = executeAction()
        }
    }

    func runNodeCommand(seq: FunctionCallAction) {
        switch seq.command {
        case .QC_ChangeSceneColor:
            let color = seq.parameter as! UIColor
            delegate?.changeSceneColor(color: color)

        case .QC_RemoveAllNodeActions:
            let node = seq.parameter as! SCNNode
            node.removeAllActions()

        case .QC_PlaySound:
            let sound = seq.parameter as! String
            delegate?.playSound(name: sound)

        case .QC_ChangeMusic:
            let fileNamed = seq.parameter as! String
            delegate?.changeMusic(fileNamed: fileNamed)
        
        case .QC_BeeSpeak:
            TJLog("what is sequence \(seq.parameter as Optional)")
            if let message = seq.parameter as? String {
                delegate?.beeWillSpeak(message: message)
            }

        }
        let _ = executeAction()
    }
}
