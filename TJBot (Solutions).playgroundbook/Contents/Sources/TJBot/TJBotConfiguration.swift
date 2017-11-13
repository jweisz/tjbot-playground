/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import PlaygroundSupport

public struct TJBotConfiguration: PlaygroundSerializable {
    public var name: String = ""
    
    init() {
    }
    
    init(response: AnyObject) {
        guard let dict = response as? Dictionary<String, AnyObject> else { return }
        
        if let name = dict["name"] as? String {
            self.name = name
        }
    }
    
    init(error: TJBotError) {
    }
}

extension TJBotConfiguration: JSONRepresentable {
    func asJSONObject() -> [String : Any] {
        return [
            "name": self.name
        ]
    }
}
