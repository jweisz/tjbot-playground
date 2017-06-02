/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation

/**
 The Watson Language Translator service provides domain-specific translation utilizing
 Statistical Machine Translation techniques that have been perfected in our research labs
 over the past few decades.
 */
public class LanguageTranslator {
    /// The base URL to use when contacting the service.
    public var serviceURL = "https://gateway.watsonplatform.net/language-translator/api"
    
    /// The default HTTP headers for all requests to the service.
    public var defaultHeaders = [String: String]()
    
    private let domain = "com.ibm.watson.developer-cloud.LanguageTranslatorV2"

    /**
     Create a `LanguageTranslator` object.
     */
    public init() {
    }
    
    // MARK: - Translate

    /**
     Translate text from a source language to a target language.
     
     - parameter text: The text to translate.
     - parameter from: The source language in 2 or 5 letter language code. Use 2 letter codes
            except when clarifying between multiple supported languages.
     - parameter to: The target language in 2 or 5 letter language code. Use 2 letter codes
            except when clarifying between multiple supported languages.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with the translation.
     */
    public func translate(_ text: String, from sourceLanguage: String, to targetLanguage: String,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (LanguageTranslationResponse) -> Void)
    {
        // serialize translate request to JSON
        guard let body = try? JSONSerialization.data(withJSONObject:  ["text": [text], "source": sourceLanguage, "target": targetLanguage], options: .prettyPrinted) else {
            let failureReason = "Translation request could not be serialized to JSON."
            let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
            let error = NSError(domain: domain, code: 0, userInfo: userInfo)
            failure?(error)
            return
        }
        
        let urlString = serviceURL + "/v2/translate"
        let urlComponents = URLComponents(string: urlString)
       // urlComponents?.queryItems = queryParameters
        guard let url = urlComponents?.url else {
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        //user agent
        let os = ProcessInfo.processInfo.operatingSystemVersion
        let operatingSystemVersion = "\(os.majorVersion).\(os.minorVersion).\(os.patchVersion)"
        request.setValue("watson-apis-swift-sdk/0.15.1/iOS/\(operatingSystemVersion)", forHTTPHeaderField: "User-Agent")
        
        //authentication
        let username = Watson.languageTranslator.username
        let password = Watson.languageTranslator.password
        let authData = (username + ":" + password).data(using: .utf8)!
        let authString = authData.base64EncodedString()
        request.setValue("Basic \(authString)", forHTTPHeaderField: "Authorization")
        
        //header parameters
        let headerParameters = defaultHeaders
        for (key, value) in headerParameters {
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: request) { (data, response, error) in
            if let error = error,
                let failure = failure {
                failure(error)
            }
            
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                
                let transResponse = LanguageTranslationResponse(response: json as AnyObject)
                success(transResponse)
            }
        }.resume()
    }

    // MARK: - Identify

    /**
     Identify the language of the given text.
     
     - parameter languageOf: The text whose language shall be identified.
     - parameter failure: A function executed if an error occurs.
     - parameter success: A function executed with all identified languages in the given text.
     */
    public func identify(languageOf text: String, failure: ((Error) -> Void)? = nil, success: @escaping (LanguageIdentificationResponse) -> Void)
    {
        // convert text to NSData with UTF-8 encoding
        guard let body = text.data(using: String.Encoding.utf8) else {
            let failureReason = "Text could not be encoded to NSData with NSUTF8StringEncoding."
            let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
            let error = NSError(domain: domain, code: 0, userInfo: userInfo)
            failure?(error)
            return
        }
        
        let urlString = serviceURL + "/v2/identify"
        let urlComponents = URLComponents(string: urlString)
        // urlComponents?.queryItems = queryParameters
        guard let url = urlComponents?.url else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("text/plain", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        //user agent
        //let os = ProcessInfo.processInfo.operatingSystemVersion
        //let operatingSystemVersion = "\(os.majorVersion).\(os.minorVersion).\(os.patchVersion)"
        //request.setValue("watson-apis-swift-sdk/0.15.1/iOS/\(operatingSystemVersion)", forHTTPHeaderField: "User-Agent")
        
        //authentication
        let username = Watson.languageTranslator.username
        let password = Watson.languageTranslator.password
        let authData = (username + ":" + password).data(using: .utf8)!
        let authString = authData.base64EncodedString()
        request.setValue("Basic \(authString)", forHTTPHeaderField: "Authorization")
        
        //header parameters
        //let headerParameters = defaultHeaders
        //for (key, value) in headerParameters {
        //    request.setValue(value, forHTTPHeaderField: key)
        //}
        
        let session = URLSession(configuration: URLSessionConfiguration.default)
        session.dataTask(with: request) { (data, response, error) in
            if let error = error,
                let failure = failure {
                failure(error)
            }
            
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: .init(rawValue: 0))
                let transResponse = LanguageIdentificationResponse(response: json as AnyObject)
                success(transResponse)
            }
        }.resume()
    }
}
