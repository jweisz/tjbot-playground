/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import UIKit
import PlaygroundSupport

enum AssessmentType: String {
    case command
    case color
    case translation
}

extension AssessmentType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .command:
            return "command"
        case .color:
            return "color"
        case .translation:
            return "translation"
        }
    }
}

struct Answer {
    var key: AssessmentType
    var color: UIColor?
    var command: String?
    var translation: String?
    
    init(key: AssessmentType, color: UIColor?) {
        self.key = key
        self.color = color
    }

    init(key: AssessmentType, command: String?) {
        self.key = key
        self.command = command
    }
    
    init(key: AssessmentType, translation: String?) {
        self.key = key
        self.translation = translation
    }
}

class AssessmentCache {
    static var assessmentStore: [String: [Answer]] = [String: [Answer]]()
    var pageName: String
    
    var pageNameKey: String {
        return AssessmentCache.append(to: pageName)
    }
    
    var commands: [Answer] {
        let keyPath = AssessmentCache.append(to: pageName)
        guard let commandArray = AssessmentCache.assessmentStore[keyPath] else {
            return [Answer]()
        }
        return commandArray
    }
    
    func save(_ answer: Answer) {
        var commandArray = commands
        commandArray.append(answer)
        let keyPath = AssessmentCache.append(to: pageName)
        AssessmentCache.assessmentStore[keyPath] = commandArray
    }
    
    func clear() {
        let keyPath = AssessmentCache.append(to: pageName)
        TJLog("assessmentStore \(AssessmentCache.assessmentStore)")
        AssessmentCache.assessmentStore[keyPath] = nil
        TJLog("Should be clear \(AssessmentCache.assessmentStore)")
    }
    
    func convert(_ answer: Answer) -> PlaygroundValue? {
        switch answer.key {
        case .command:
            guard let commandString = answer.command else { return nil }
            return .string(commandString)
        case .color :
            if let color = answer.color {
                let colorData: Data = NSKeyedArchiver.archivedData(withRootObject: color)
                return .data(colorData)
            }
        case .translation :
            if let transString = answer.translation {
                return .string(transString)
            }
        }
        return nil
    }

    init(pageName: String) {
        self.pageName = pageName
    }
    
    class func append(to pageName: String) -> String {
        return pageName + "_assess"
    }
}
