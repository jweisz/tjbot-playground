/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import PlaygroundSupport

public typealias AssessmentSuccess = String
public typealias AssessmentHints = [String]

public enum AssessmentResult: String {
    case passed = "passed"
    case failed = "failed"
}

extension AssessmentResult: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "Result (rawValue: \(rawValue))"
    }
}

/// Register an assessment to be used to evaluate the user's response to the task
public func registerAssessment(_ tjBot: TJBotViewController, pageName: String, assessment: @escaping ([String]?, [AnyObject]?) -> AssessmentResult) {
    let assessor = TaskAssessor(pageName: pageName, evaluate: assessment)
    tjBot.taskAssessor = assessor
}
