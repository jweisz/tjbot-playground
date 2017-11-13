/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import PlaygroundSupport


// MARK: RebusTheBeeCommand

public enum RebusTheBeeCommand {
    case beeAppear
    case beeRestOnTJ
    case beeRestOnTJArm
    case beeSpeak(String)
}

extension RebusTheBeeCommand: CustomStringConvertible {
    public var description: String {
        switch self {
        case .beeAppear:
            return "beeAppear"
        case .beeRestOnTJ:
            return "beeRestOnTJ"
        case .beeRestOnTJArm:
            return "beeRestOnTJArm"
        case .beeSpeak(_):
            return "beeSpeak"
        }
    }
}

extension RebusTheBeeCommand {
    private var args: [String: String] {
        var args: [String: String] = [:]

        switch self {
        case .beeSpeak(let message):
            args["message"] = String(message)
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

// MARK: - RebusTheBee

public class RebusTheBee {
    public init() {
    }

    public func send(command: RebusTheBeeCommand) {
        let page = PlaygroundPage.current

        let playgroundValue = command.playgroundValue()
        guard let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy else { return }

        proxy.send(playgroundValue)
    }
}

extension RebusTheBee: Speaks {
    public func speak(_ message: String) {
        self.send(command: .beeSpeak(message))
    }
}
