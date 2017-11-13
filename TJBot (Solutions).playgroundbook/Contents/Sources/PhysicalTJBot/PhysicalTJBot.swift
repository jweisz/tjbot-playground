/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import UIKit
import PlaygroundSupport

import CoreBluetooth

// MARK: PhysicalTJBot

public class PhysicalTJBot: CarriesTJBotState {
    public var hardware: Set<TJBotHardware> {
        TJLog("PhysicalTJBot hardware requested")
        var hardware: Set<TJBotHardware> = []
        guard let response = self.send(request: .hardware) else { return hardware }
        
        if case let .array(elements) = response {
            for item in elements {
                if case let .string(val) = item {
                    if let hardwareVal = TJBotHardware(rawValue: val) {
                        hardware.insert(hardwareVal)
                    }
                }
            }
        }
        
        return hardware
    }
    
    public var configuration: TJBotConfiguration {
        TJLog("PhysicalTJBot configuration requested")
        guard let response = self.send(request: .configuration) else {
            TJLog("PhysicalTJBot configuration: didn't get back a valid response so returning an empty configuration")
            return TJBotConfiguration()
        }
        TJLog("PhysicalTJBot configuration: returning configuration from playground value:")
        TJLogResponse(response)
        return TJBotConfiguration.from(playgroundValue: response)
    }
    
    public var capabilities: Set<TJBotCapability> {
        TJLog("PhysicalTJBot capabilities requested")
        var capabilities: Set<TJBotCapability> = []
        guard let response = self.send(request: .capabilities) else { return capabilities }
        
        if case let .array(elements) = response {
            for item in elements {
                if case let .string(val) = item {
                    if let capabilityVal = TJBotCapability(rawValue: val) {
                        capabilities.insert(capabilityVal)
                    }
                }
            }
        }
        
        return capabilities
    }
    
    // keep track of the response we have received from the LiveView
    fileprivate var responseBuffer: PlaygroundValue? = nil
    
    // keep track of the callback method for listen()
    fileprivate var listenCompletion: ((String) -> Void)?
    
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
        TJLog("PhysicalTJBot send(): sent the request to the playground proxy, calling CFRunLoopRun()")
        TJLog(" > \(playgroundValue)")
        CFRunLoopRun()
        TJLog("PhysicalTJBot send(): returned from CFRunLoopRun()")
        
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

extension PhysicalTJBot: Sleeps {
    public func sleep(duration: TimeInterval) {
        // tell tj to take a nap
        TJLog("PhysicalTJBot sleep() called")
        self.send(command: .sleep(duration))
        
        // sleep ourselves, too
        Thread.sleep(forTimeInterval: duration)
    }
}

// MARK: - AnalyzesTone

extension PhysicalTJBot: AnalyzesTone {
    public func analyzeTone(text: String) -> ToneResponse {
        TJLog("PhysicalTJBot analyzeTone() called")
        guard let responseValue = self.send(request: .analyzeTone(text)) else {
            return ToneResponse(error: .unableToDeserializeTJBotResponse)
        }
        return ToneResponse.from(playgroundValue: responseValue)
    }
}

// MARK: - Converses

extension PhysicalTJBot: Converses {
    public func converse(workspaceId: String, message: String) -> ConversationResponse {
        TJLog("PhysicalTJBot converse() called")
        guard let responseValue = self.send(request: .converse(workspaceId, message)) else {
            return ConversationResponse(error: .unableToDeserializeTJBotResponse)
        }
        return ConversationResponse.from(playgroundValue: responseValue)
    }
}

// MARK: - Listens

extension PhysicalTJBot: Listens {
    public func listen(_ completion: @escaping ((String) -> Void)) {
        TJLog("PhysicalTJBot listen() called")
        self.listenCompletion = completion
        self.send(command: .listen)
    }
}

// MARK: - Sees

extension PhysicalTJBot: Sees {
    public func see() -> VisionResponse {
        TJLog("PhysicalTJBot see() called")        
        guard let responseValue = self.send(request: .see) else {
            return VisionResponse(error: .unableToDeserializeTJBotResponse)
        }
        return VisionResponse.from(playgroundValue: responseValue)
    }
    
    public func read() -> VisionResponse {
        TJLog("PhysicalTJBot read() called")
        guard let responseValue = self.send(request: .read) else {
            return VisionResponse(error: .unableToDeserializeTJBotResponse)
        }
        return VisionResponse.from(playgroundValue: responseValue)
    }
}

// MARK: - Shines

extension PhysicalTJBot: Shines {
    public func shine(color: UIColor) {
        TJLog("PhysicalTJBot shine() called")
        self.send(command: .shine(color.toHexString()))
    }
    
    public func pulse(color: UIColor, duration: TimeInterval) {
        TJLog("PhysicalTJBot pulse() called")
        self.send(command: .pulse(color.toHexString(), duration))
    }
}

// MARK: - Speaks

extension PhysicalTJBot: Speaks {
    public func speak(_ message: String) {
        TJLog("PhysicalTJBot speak() called")
        let _ = self.send(request: .speak(message))
    }
}

// MARK: - Translates

extension PhysicalTJBot: Translates {
    public func translate(text: String, sourceLanguage: TJTranslationLanguage, targetLanguage: TJTranslationLanguage) -> String? {
        TJLog("PhysicalTJBot translate() called")
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
        TJLog("PhysicalTJBot identifyLanguage() called")
        guard let response = self.send(request: .identifyLanguage(text)) else {
            return []
        }
        
        return LanguageIdentification.languages(from: response)
    }
}

// MARK: - Waves

extension PhysicalTJBot: Waves {
    public func raiseArm() {
        TJLog("PhysicalTJBot raiseArm() called")
        self.send(command: .raiseArm)
    }
    
    public func lowerArm() {
        TJLog("PhysicalTJBot lowerArm() called")
        self.send(command: .lowerArm)
    }
    
    public func wave() {
        TJLog("PhysicalTJBot wave() called")
        self.send(command: .wave)
    }
}

// MARK: - PlaygroundRemoteLiveViewProxyDelegate

extension PhysicalTJBot: PlaygroundRemoteLiveViewProxyDelegate {
    public func remoteLiveViewProxy(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy, received message: PlaygroundValue) {
        TJLog("PhysicalTJBot remoteLiveViewProxy: received message from Playground proxy: \(message)")
        if case let .dictionary(dict) = message, case let .string(message)? = dict["listenText"] {
            // need to do this on the main thread, otherwise bad things happen :)
            DispatchQueue.main.async {                
                self.listenCompletion?(message)
            }
        } else {
            TJLog("PhysicalTJBot remoteLiveViewProxy: storing response in buffer and calling CFRunLoopStop(CFRunLoopGetMain())")
            TJLogResponse(message)
            
            self.responseBuffer = message
            CFRunLoopStop(CFRunLoopGetMain())
        }
    }
    
    public func remoteLiveViewProxyConnectionClosed(_ remoteLiveViewProxy: PlaygroundRemoteLiveViewProxy) {
        TJLog("warning: remove live view proxy closed the connection")
    }
}

// MARK: - CustomStringConvertible

extension PhysicalTJBot: CustomStringConvertible {
    public var description: String {
        return "TJBot \(self.configuration.name)"
    }
}
