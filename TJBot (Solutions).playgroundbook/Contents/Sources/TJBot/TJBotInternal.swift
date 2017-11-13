/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import PlaygroundSupport

protocol Dances {
    func botDance()
}

protocol Emotes {
    func displayBotEmotion(_ emotion: String)
}

public enum TJBotInternalCommand {
    case botDance
    case displayBotEmotion(String)
}

extension TJBotInternalCommand: CustomStringConvertible {
    public var description: String {
        switch self {
        case .botDance:
            return "dance"
        case .displayBotEmotion(_):
            return "displayEmotion"
        }
    }
}

extension TJBotInternalCommand {
    private var args: [String: String] {
        var args: [String: String] = [:]

        switch self {
        case .displayBotEmotion(let emotion):
            args["emotion"] = String(emotion)
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

class TJBotInternal {
    init() {
    }

    func send(command: TJBotInternalCommand) {
        let page = PlaygroundPage.current

        let playgroundValue = command.playgroundValue()
        guard let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy else { return }

        proxy.send(playgroundValue)
    }
}

// MARK: - Dances

extension TJBotInternal: Dances {
    public func botDance() {
        self.send(command: .botDance)
    }
}

// MARK: - Emotes

extension TJBotInternal: Emotes {
    public func displayBotEmotion(_ emotion: String) {
        self.send(command: .displayBotEmotion(emotion))
    }
}
