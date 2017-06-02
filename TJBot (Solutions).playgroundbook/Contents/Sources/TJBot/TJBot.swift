/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import UIKit
import PlaygroundSupport

// MARK: TJBot Abilities

protocol Sleeps {
    func sleep(duration: TimeInterval)
}

protocol AnalyzesTone {
    func analyzeTone(text: String) -> ToneResponse
}

protocol Converses {
    func converse(workspaceId: String, message: String) -> ConversationResponse
}

protocol Listens {
    func listen(_ completion: @escaping ((String) -> Void))
}

protocol Sees {
    func see() -> VisionResponse
    func read() -> VisionResponse
}

protocol Shines {
    func shine(color: UIColor)
    func pulse(color: UIColor, duration: TimeInterval)
}

protocol Speaks {
    func speak(_ message: String)
}

protocol Translates {
    func translate(text: String, sourceLanguage: TJTranslationLanguage, targetLanguage: TJTranslationLanguage) -> String?
    func identifyLanguage(text: String) -> [LanguageIdentification]
}

protocol Waves {
    func raiseArm()
    func lowerArm()
    func wave()
}

// MARK: - Internal TJBot Abilities

/// This protocol is only applied to PhysicalTJBotViewController
/// so PhysicalTJBot can tell it to start connecting.
internal protocol RemotelyConnects {
    func connectToTJBot(scanDuration: TimeInterval) -> Bool
}

/// This protocol is only applied to VirtualTJBotViewController
/// so we can send it commands to control the bee.
internal protocol Buzzes {
    func beeAppear()
    func beeRestOnTJ()
    func beeRestOnTJArm()
    func beeSpeak(_ message: String)
}

// MARK: - CarriesTJBotState

protocol CarriesTJBotState {
    var hardware: Set<TJBotHardware> { get }
    var configuration: TJBotConfiguration { get }
    var capabilities: Set<TJBotCapability> { get }
    func hasCapability(capability: TJBotCapability) -> Bool
}

extension CarriesTJBotState {
    public func hasCapability(capability: TJBotCapability) -> Bool {
        return self.capabilities.contains(capability)
    }
}

// MARK: - TJBotCommand

enum TJBotCommand {
    case sleep(TimeInterval)
    case listen
    case shine(String)
    case pulse(String, TimeInterval)
    case raiseArm
    case lowerArm
    case wave
    case runActionQueue
}

extension TJBotCommand: CustomStringConvertible {
    public var description: String {
        switch self {
        case .sleep(_):
            return "sleep"
        case .listen:
            return "listen"
        case .shine(_):
            return "shine"
        case .pulse(_, _):
            return "pulse"
        case .raiseArm:
            return "raiseArm"
        case .lowerArm:
            return "lowerArm"
        case .wave:
            return "wave"
        case .runActionQueue:
            return "runActionQueue"
        }
    }
}

extension TJBotCommand {
    private var args: [String: String] {
        var args: [String: String] = [:]

        switch self {
        case .sleep(let duration):
            args["duration"] = String(duration)
        case .shine(let color):
            args["color"] = color
        case .pulse(let color, let duration):
            args["color"] = color
            args["duration"] = String(duration)
        default:
            break
        }

        return args
    }

    func serialize() -> Data? {
        do {
            let command: [String : Any] = ["cmd": self.description, "args": self.args]
            let commandData = try JSONSerialization.data(withJSONObject: command, options: .init(rawValue: 0))
            return commandData
        } catch let error {
            TJLog("error serializing command arguments to json: \(error)")
            return nil
        }
    }

    func playgroundValue() -> PlaygroundValue {
        var argDict: [String: PlaygroundValue] = [:]
        for (k, v) in self.args {
            argDict[k] = PlaygroundValue.string(v)
        }

        return .dictionary([
            "cmd": .string(self.description),
            "args": .dictionary(argDict)])
    }
}

// MARK: - TJBotRequest

enum TJBotRequest {
    case connectToTJBot
    case hardware
    case configuration
    case capabilities
    case analyzeTone(String)
    case converse(String, String)
    case see
    case read
    case speak(String)
    case translate(String, String, String)
    case identifyLanguage(String)
}

extension TJBotRequest: CustomStringConvertible {
    public var description: String {
        switch self {
        case .connectToTJBot:
            return "connectToTJBot"
        case .hardware:
            return "hardware"
        case .configuration:
            return "configuration"
        case .capabilities:
            return "capabilities"
        case .analyzeTone(_):
            return "analyzeTone"
        case .converse(_, _):
            return "converse"
        case .see:
            return "see"
        case .read:
            return "read"
        case .speak(_):
            return "speak"
        case .translate(_, _, _):
            return "translate"
        case .identifyLanguage(_):
            return "identifyLanguage"
        }
    }
}

extension TJBotRequest {
    private var args: [String: String] {
        var args: [String: String] = [:]

        switch self {
        case .analyzeTone(let text):
            args["text"] = text
        case .converse(let workspaceId, let message):
            args["workspaceId"] = workspaceId
            args["message"] = message
        case .speak(let message):
            args["message"] = message
        case .translate(let text, let sourceLanguage, let targetLanguage):
            args["text"] = text
            args["sourceLanguage"] = sourceLanguage
            args["targetLanguage"] = targetLanguage
        case .identifyLanguage(let text):
            args["text"] = text
        default:
            break
        }

        return args
    }

    func serialize() -> Data? {
        do {
            let command: [String : Any] = ["cmd": self.description, "args": self.args]
            let commandData = try JSONSerialization.data(withJSONObject: command, options: .init(rawValue: 0))
            return commandData
        } catch let error {
            TJLog("error serializing command arguments to json: \(error)")
            return nil
        }
    }

    func playgroundValue() -> PlaygroundValue {
        var argDict: [String: PlaygroundValue] = [:]
        for (k, v) in self.args {
            argDict[k] = PlaygroundValue.string(v)
        }

        return .dictionary([
            "cmd": .string(self.description),
            "args": .dictionary(argDict)])
    }
}

// MARK: - TJBotError

public enum TJBotError: Error {
    case tjbotNotConnected
    case requiredCapabilityNotPresent(TJBotCapability)
    case methodNotImplemented
    case unableToDeserializeTJBotResponse
    case tjbotInternalError(String)
}

extension TJBotError: CustomStringConvertible {
    public var description: String {
        switch self {
        case .tjbotNotConnected:
            return "TJBot not connected"
        case .requiredCapabilityNotPresent(let capability):
            return "Required capability not present: \(capability)"
        case .methodNotImplemented:
            return "Method not implemented"
        case .unableToDeserializeTJBotResponse:
            return "Unable to deserialize TJBot response"
        case .tjbotInternalError(let err):
            return "TJBot internal error: \(err)"
        }
    }
}
