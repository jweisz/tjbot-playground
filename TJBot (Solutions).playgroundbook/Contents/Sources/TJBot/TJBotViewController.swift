/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import UIKit
import PlaygroundSupport

public class TJBotViewController: UIViewController, PlaygroundLiveViewMessageHandler {
    var taskAssessor: TaskAssessor?
    var isActionRunning: Bool = false
    
    public func liveViewMessageConnectionOpened() {
        // We don't need to do anything in particular when the connection opens.
        TJLog("liveViewMessageConnectionOpened()")
    }
    
    public func liveViewMessageConnectionClosed() {
        // We don't need to do anything in particular when the connection closes.
        TJLog("liveViewMessageConnectionClosed()")
    }
    
    public func receive(_ message: PlaygroundValue) {
        guard case let .dictionary(dict) = message else { return }
        guard case let .string(cmd)? = dict["cmd"] else { return }
        guard case let .dictionary(args)? = dict["args"] else { return }
        
        TJLog("TJBotViewController receive: received message from Playground content: cmd: \(cmd), args: \(args)")
        
        switch cmd {
        // TJBotInternalCommand
        case "dance":
            if let tj = self as? Dances {
                tj.botDance()
            }
        case "displayEmotion":
            guard case let .string(emotion)? = args["emotion"] else { return }
            if let tj = self as? Emotes {
                tj.displayBotEmotion(emotion as String)
            }
        // TJBotCommand
        case "sleep":
            guard case let .string(durationStr)? = args["duration"] else { return }
            guard let duration = TimeInterval(durationStr) else { return }
            if let tj = self as? Sleeps {
                tj.sleep(duration: duration)
            }
        case "listen":
            if let tj = self as? Listens {
                tj.listen { (text) in
                    self.sendListenText(text)
                }
            }
        case "shine":
            guard case let .string(color)? = args["color"] else { return }
            if let tj = self as? Shines {
                let shineColor = UIColor(hexString: color)
                tj.shine(color: shineColor)
                taskAssessor?.save(answer: Answer(key: .color, color: shineColor))
                taskAssessor?.save(answer: Answer(key: .command, command: cmd))
            }
        case "pulse":
            guard case let .string(color)? = args["color"] else { return }
            guard case let .string(durationStr)? = args["duration"] else { return }
            guard let duration = Double(durationStr) else { return }
            if let tj = self as? Shines {
                let shineColor = UIColor(hexString: color)
                tj.pulse(color: shineColor, duration: duration)
                taskAssessor?.save(answer: Answer(key: .color, color: shineColor))
                taskAssessor?.save(answer: Answer(key:.command, command: cmd))
            }
        case "raiseArm":
            if let tj = self as? Waves {
                tj.raiseArm()
                taskAssessor?.save(answer: Answer(key:.command, command: cmd))
            }
        case "lowerArm":
            if let tj = self as? Waves {
                tj.lowerArm()
                taskAssessor?.save(answer: Answer(key:.command, command: cmd))
            }
        case "wave":
            if let tj = self as? Waves {
                tj.wave()
                taskAssessor?.save(answer: Answer(key:.command, command: "wave"))
            }
        // TJBotRequest
        case "hardware":
            if let tj = self as? CarriesTJBotState {
                let hardware: [String] = Array(tj.hardware.map { $0.rawValue })
                self.sendResponse(hardware)
            }
        case "configuration":
            if let tj = self as? CarriesTJBotState {
                self.sendResponse(tj.configuration)
            }
        case "capabilities":
            if let tj = self as? CarriesTJBotState {
                let capabilities: [String] = Array(tj.capabilities.map { $0.rawValue })
                self.sendResponse(capabilities)
            }
        case "analyzeTone":
            guard case let .string(text)? = args["text"] else { return }
            if let tj = self as? AnalyzesTone {
                let response = tj.analyzeTone(text: text)
                self.sendResponse(response)
            } else {
                let response = ToneResponse(error: TJBotError.requiredCapabilityNotPresent(.analyzeTone))
                self.sendResponse(response)
            }
        case "converse":
            guard case let .string(workspaceId)? = args["workspaceId"] else { return }
            guard case let .string(message)? = args["message"] else { return }
            if let tj = self as? Converses {
                let response = tj.converse(workspaceId: workspaceId, message: message)
                self.sendResponse(response)
            } else {
                let response = ConversationResponse(error: TJBotError.requiredCapabilityNotPresent(.converse))
                self.sendResponse(response)
            }
        case "see":
            if let tj = self as? Sees {
                let response = tj.see()
                self.sendResponse(response)
            } else {
                let response = VisionResponse(error: TJBotError.requiredCapabilityNotPresent(.see))
                self.sendResponse(response)
            }
        case "read":
            if let tj = self as? Sees {
                let response = tj.read()
                self.sendResponse(response)
            } else {
                let response = VisionResponse(error: TJBotError.requiredCapabilityNotPresent(.see))
                self.sendResponse(response)
            }
        case "speak":
            guard case let .string(message)? = args["message"] else { return }
            if let tj = self as? Speaks {
                tj.speak(message)
                self.sendResponse(true)
            }
        case "translate":
            guard case let .string(text)? = args["text"] else { return }
            guard case let .string(sourceLanguage)? = args["sourceLanguage"] else { return }
            guard case let .string(targetLanguage)? = args["targetLanguage"] else { return }
            guard let source = TJTranslationLanguage(rawValue: sourceLanguage) else { return }
            guard let target = TJTranslationLanguage(rawValue: targetLanguage) else { return }
            
            if let tj = self as? Translates {
                let response = tj.translate(text: text, sourceLanguage: source, targetLanguage: target)
                taskAssessor?.save(answer: Answer(key: .translation, translation: response))
                taskAssessor?.save(answer: Answer(key: .command, command: cmd))
                self.sendResponse(response)
            } else {
                self.sendResponse("")
            }
        case "identifyLanguage":
            guard case let .string(text)? = args["text"] else { return }
            if let tj = self as? Translates {
                let response = tj.identifyLanguage(text: text)
                self.sendResponse(response)
            } else {
                self.sendResponse("")
            }
        // RebusTheBeeCommand
        case "beeAppear":
            if let tj = self as? Buzzes {
                tj.beeAppear()
            }
        case "beeRestOnTJ":
            if let tj = self as? Buzzes {
                tj.beeRestOnTJ()
            }
        case "beeRestOnTJArm":
            if let tj = self as? Buzzes {
                tj.beeRestOnTJArm()
            }
        case "beeSpeak":
            guard case let .string(message)? = args["message"] else { return }
            if let tj = self as? Buzzes {
                tj.beeSpeak(message)
            }
        default:
            break
        }
        
        if let tj = self as? Queues {
            TJLog("TJBotViewController our TJ queues")
            //checks to see if the queue is currently executing, if it is no need to start it
            //NOTE: there is a delegate method in VirtualTJBotViewController that tells us when queue is finished
            if !isActionRunning {
                TJLog("TJBotViewController no action is running, call tj.runActionQueue()")
                isActionRunning = tj.runActionQueue()
                TJLog("TJBotViewController tj.runActionQueue() called")
            }
        }
    }
    
    private func sendResponse(_ value: String?) {
        TJLog("TJBotViewController sendResponse: sending a String: \(value as Optional)")
        if let value = value {
            let response = PlaygroundValue.string(value)
            self.send(response)
        } else {
            let response = PlaygroundValue.string("")
            self.send(response)
        }
    }
    
    private func sendResponse(_ value: Bool) {
        TJLog("TJBotViewController sendResponse: sending a boolean value: \(value)")
        let response = PlaygroundValue.boolean(value)
        self.send(response)
    }
    
    private func sendResponse(_ sequence: [String]) {
        TJLog("TJBotViewController sendResponse: sending a [String]: \(sequence)")
        let response = PlaygroundValue.array(sequence.map { PlaygroundValue.string($0) })
        self.send(response)
    }
    
    private func sendResponse<T>(_ object: T) where T: JSONRepresentable {
        TJLog("TJBotViewController sendResponse: sending a JSON object: \(object)")
        guard let jsonData = object.asJSONData() else {
            let errorDict = PlaygroundValue.dictionary(["error": .string("error encoding object to JSON")])
            self.send(errorDict)
            return
        }
        
        let responseDict = PlaygroundValue.dictionary(["response": .data(jsonData)])
        self.send(responseDict)
    }
    
    private func sendResponse<T>(_ objects: [T]) where T: JSONRepresentable {
        TJLog("TJBotViewController sendResponse: sending a list of JSON objects: \(objects)")
        let jsonObjectData = objects.compactMap { $0.asJSONData() }
        let playgroundData = jsonObjectData.map { PlaygroundValue.data($0) }
        let responseDict = PlaygroundValue.array(playgroundData)
        self.send(responseDict)
    }
    
    private func sendListenText(_ text: String) {
        let responseDict = PlaygroundValue.dictionary(["listenText": .string(text)])
        self.send(responseDict)
    }
    
    func evaluate() {
        TJLog("About to Evaluate")
        if let assessor = taskAssessor {
            TJLog("AND ASSESSMENT COMMENCE")
            let result: AssessmentResult = assessor.assessmentStatus()
            
            let message = PlaygroundValue.dictionary(["assessment": .string(result.rawValue)])
            self.send(message)
        }
    }
}
