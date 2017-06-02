/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import UIKit
import PlaygroundSupport

// MARK: VirtualTJBot

public class VirtualTJBot {
    // keep track of the response we have received from the LiveView
    fileprivate var responseBuffer: PlaygroundValue? = nil
    
    public var assessorDelegate: TaskAssessorDelegate?

    public init() {
        // set ourselves as the PlaygroundRemoteLiveViewProxyDelegate so we receive
        // messages from the proxy
        let page = PlaygroundPage.current
        let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy
        proxy?.delegate = self
    }

    fileprivate func send(command: TJBotCommand) {
        let page = PlaygroundPage.current

        let playgroundValue = command.playgroundValue()
        guard let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy else { return }

        proxy.send(playgroundValue)
    }

    @discardableResult
    fileprivate func send(request: TJBotRequest) -> PlaygroundValue? {
        let page = PlaygroundPage.current
        let playgroundValue = request.playgroundValue()
        guard let proxy = page.liveView as? PlaygroundRemoteLiveViewProxy else { return nil }

        // send the request
        proxy.send(playgroundValue)

        // go back to the run loop until the resposne is received
        TJLog("VirtualTJBot send(): sent the request to the playground proxy, calling CFRunLoopRun()")
        TJLog(" > \(playgroundValue)")
        CFRunLoopRun()
        TJLog("VirtualTJBot send(): returned from CFRunLoopRun()")

        // get the response
        guard let response = self.responseBuffer else {
            TJLog("error: responseBuffer was nil when we didn't expect it to be!")
            return nil
        }

        // clear it out for the next send()
        self.responseBuffer = nil
        return response
    }
}

// MARK: - Sleeps

extension VirtualTJBot: Sleeps {
    public func sleep(duration: TimeInterval) {
        Thread.sleep(forTimeInterval: duration)
    }
}

// MARK: - AnalyzesTone

extension VirtualTJBot: AnalyzesTone {
    public func analyzeTone(text: String) -> ToneResponse {
        guard let responseValue = self.send(request: .analyzeTone(text)) else {
            return ToneResponse(error: .unableToDeserializeTJBotResponse)
        }
        return ToneResponse.from(playgroundValue: responseValue)
    }
}

// MARK: Shines

extension VirtualTJBot: Shines {
    public func shine(color: UIColor) {
        self.send(command: .shine(color.toHexString()))
    }

    public func pulse(color: UIColor, duration: TimeInterval) {
        self.send(command: .pulse(color.toHexString(), duration))
    }
}

// MARK: - Translates

extension VirtualTJBot: Translates {
    public func translate(text: String, sourceLanguage: TJTranslationLanguage, targetLanguage: TJTranslationLanguage) -> String? {
        var translation: String? = nil

        guard let response = self.send(request: .translate(text, sourceLanguage.rawValue, targetLanguage.rawValue)) else {
            return translation
        }

        if case let .string(val) = response {
            if val != "" {
                translation = val
            }
        }

        return translation
    }

    public func identifyLanguage(text: String) -> [LanguageIdentification] {
        guard let response = self.send(request: .identifyLanguage(text)) else {
            return []
        }
        return LanguageIdentification.languages(from: response)
    }
}

// MARK: - Waves

extension VirtualTJBot: Waves {
    public func raiseArm() {
        self.send(command: .raiseArm)
    }

    public func lowerArm() {
        self.send(command: .lowerArm)
    }

    public func wave() {
        self.send(command: .wave)
    }
}


// MARK: - PlaygroundRemoteLiveViewProxyDelegate

extension VirtualTJBot: PlaygroundRemoteLiveViewProxyDelegate {
    public func remoteLiveViewProxy(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy,
                                    received message: PlaygroundValue) {
        TJLog("VirtualTJBot remoteLiveViewProxy: received message: \(message)")

        // check to see if this is an assessment
        if case let .dictionary(dict) = message, case let .string(result)? = dict["assessment"] {
            TJLog("this is assessment stuff")

            assessorDelegate?.assessmentResult(result: result)
        } else {
            self.responseBuffer = message
            CFRunLoopStop(CFRunLoopGetMain())
        }
    }

    public func remoteLiveViewProxyConnectionClosed(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy) {
    }
}

// MARK: - CustomStringConvertible

extension VirtualTJBot: CustomStringConvertible {
    public var description: String {
        return "VirtualTJBot"
    }
}
