/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import PlaygroundSupport

public struct Watson {
    public struct Credential {
        private let service: String
        
        init(service: String) {
            self.service = service
        }
        
        public var username: String {
            get {
                if case let .string(username)? = PlaygroundKeyValueStore.current["\(service).username"] {
                    return username
                }
                return ""
            }
            set {
                PlaygroundKeyValueStore.current["\(service).username"] = .string(newValue)
                
                // playground bug -- need to sleep for a second so the KVS write takes effect,
                // otherwise, doing a KVS read too quickly will result in the value not being read
                Thread.sleep(forTimeInterval: 1.0)
            }
        }
        public var password: String {
            get {
                if case let .string(password)? = PlaygroundKeyValueStore.current["\(service).password"] {
                    return password
                }
                return ""
            }
            set {
                PlaygroundKeyValueStore.current["\(service).password"] = .string(newValue)
                
                // playground bug -- need to sleep for a second so the KVS write takes effect,
                // otherwise, doing a KVS read too quickly will result in the value not being read
                Thread.sleep(forTimeInterval: 1.0)
            }
        }
    }
    
    public static var toneAnalyzer = Credential(service: "toneAnalyzer")
    public static var languageTranslator = Credential(service: "languageTranslator")
}
