/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation

/**
 The IBM Watson Tone Analyzer service uses linguistic analysis to detect emotional tones,
 social propensities, and writing styles in written communication. Then it offers suggestions
 to help the writer improve their intended language tones.
 **/
public class ToneAnalyzer {
    /// The base URL to use when contacting the service.
    public var serviceURL = "https://gateway.watsonplatform.net/tone-analyzer/api"
    
    /// The default HTTP headers for all requests to the service.
    public var defaultHeaders = [String: String]()
    
    private let version: String = "2016-05-19"
    private let domain = "com.ibm.watson.developer-cloud.ToneAnalyzerV3"
    
    /**
     Create a `ToneAnalyzer` object.
     */
    public init() {
    }
    
    /**
     Analyze the tone of the given text.
     
     The message is analyzed for several tones—social, emotional, and writing. For each tone,
     various traits are derived (e.g. conscientiousness, agreeableness, and openness).
     
     - parameter ofText: The text to analyze.
     - parameter tones: Filter the results by a specific tone. Valid values for `tones` are
     `emotion`, `writing`, or `social`.
     - parameter sentences: Should sentence-level tone analysis by performed?
     - parameter failure: A function invoked if an error occurs.
     - parameter success: A function invoked with the tone analysis.
     */
    func getTone(
        ofText text: String,
        tones: [String]? = nil,
        sentences: Bool? = nil,
        failure: ((Error) -> Void)? = nil,
        success: @escaping (ToneResponse) -> Void)
    {
        
        // construct body
        guard let body = try? JSONSerialization.data(withJSONObject: ["text": text], options: .prettyPrinted) else {
            let failureReason = "Classification text could not be serialized to JSON."
            let userInfo = [NSLocalizedFailureReasonErrorKey: failureReason]
            let error = NSError(domain: domain, code: 0, userInfo: userInfo)
            failure?(error)
            return
        }
        
        // construct query parameters
        var queryParameters = [URLQueryItem]()
        queryParameters.append(URLQueryItem(name: "version", value: version))
        if let tones = tones {
            let tonesList = tones.joined(separator: ",")
            queryParameters.append(URLQueryItem(name: "tones", value: tonesList))
        }
        if let sentences = sentences {
            queryParameters.append(URLQueryItem(name: "sentences", value: "\(sentences)"))
        }

        
        let urlString = serviceURL + "/v3/tone"
        var urlComponents = URLComponents(string: urlString)
        urlComponents?.queryItems = queryParameters
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
        let username = Watson.toneAnalyzer.username
        let password = Watson.toneAnalyzer.password
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
                
                let toneResponse = ToneResponse(response: json as AnyObject)
                success(toneResponse)
            }
            
        }.resume()
    }
}
