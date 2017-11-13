/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import PlaygroundSupport

protocol JSONRepresentable {
    func asJSONData() -> Data?
    func asJSONObject() -> [String : Any]
}

extension JSONRepresentable {
    func asJSONData() -> Data? {
        do {
            let dict: [String : AnyObject] = self.asJSONObject() as [String : AnyObject]
            let data = try JSONSerialization.data(withJSONObject: dict, options: .init(rawValue: 0))
            return data
        } catch let error {
            TJLog("error encoding JSONRepresentable object as JSON: \(error)")
            return nil
        }
    }
}
