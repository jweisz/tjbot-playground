/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import PlaygroundSupport

public struct Watson {
    public struct UsernamePasswordCredential {
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
    
    public struct APIKeyCredential {
        private let service: String
        
        init(service: String) {
            self.service = service
        }
        
        public var apikey: String {
            get {
                if case let .string(apikey)? = PlaygroundKeyValueStore.current["\(service).apikey"] {
                    return apikey
                }
                return ""
            }
            set {
                PlaygroundKeyValueStore.current["\(service).apikey"] = .string(newValue)
                
                // playground bug -- need to sleep for a second so the KVS write takes effect,
                // otherwise, doing a KVS read too quickly will result in the value not being read
                Thread.sleep(forTimeInterval: 1.0)
            }
        }
    }
    
    public static var toneAnalyzer = UsernamePasswordCredential(service: "toneAnalyzer")
    public static var languageTranslator = APIKeyCredential(service: "languageTranslator")
}
