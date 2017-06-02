/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import UIKit
import Foundation
import PlaygroundSupport


struct TaskResults {
    var commands: [String]
    var actions: [AnyObject]
}

class TaskAssessor {
    var evaluate: ([String]?, [AnyObject]?) -> AssessmentResult
    var cache: AssessmentCache?
    
    init(pageName: String, evaluate: @escaping ([String]?, [AnyObject]?) -> AssessmentResult) {
        self.evaluate = evaluate
        self.cache = AssessmentCache(pageName: pageName)
    }
    
    func assessmentStatus() -> AssessmentResult {        
        defer {
            cache?.clear()
        }
        guard let commands = cache?.commands, let finalAnswers = convert(answers: commands) else {
           return .failed
        }
        return evaluate(finalAnswers.commands, finalAnswers.actions)
    }
    
    func save(answer: Answer) {
        if let cache = cache {
            cache.save(answer)
        }
    }
    
    func convert(answers: [Answer]) -> TaskResults? {
        var commands = [String]()
        var actions = [AnyObject]()
        for answer in answers {
            if let command = answer.command {
                commands.append(command)
            }
            if let data = answer.color {
                actions.append(data)
            }
        }
        return TaskResults(commands: commands, actions: actions)
    }
}

public class TaskAssessorDelegate {
    var success: AssessmentSuccess?
    var failureHints: AssessmentHints?
    var successBeeCommand: RebusTheBeeCommand?
    var successTJBotInternalCommand: TJBotInternalCommand?
    var pageName: String?
    
    public init(success: AssessmentSuccess, hints: AssessmentHints?, successBeeCommand: RebusTheBeeCommand?, successTJBotInternalCommand: TJBotInternalCommand?, pageName: String? = nil) {
        self.success = success
        self.failureHints = hints
        self.successBeeCommand = successBeeCommand
        self.successTJBotInternalCommand = successTJBotInternalCommand
        //only populate this is you need to skip ending execution on failure
        self.pageName = pageName

        PlaygroundPage.current.needsIndefiniteExecution = true
    }
    
    // MARK: Assessment Checking
    func assessmentResult(result: String) {
        TJLog("assessment RESULTS \(result)")

        guard let aResult = AssessmentResult(rawValue: result) else { return }
        switch aResult {
        case .passed:
            if let success = success {
                PlaygroundPage.current.assessmentStatus = .pass(message: success)
            } else {
                PlaygroundPage.current.assessmentStatus = .pass(message: "Default Success Message here")
            }

            if let rebusCommand = successBeeCommand {
                let rebus = RebusTheBee()
                rebus.send(command: rebusCommand)
            }
            if let botCommand = successTJBotInternalCommand {
                let bot = TJBotInternal()
                bot.send(command: botCommand)
            }
            PlaygroundPage.current.finishExecution()

        case .failed:
            if let failureHints = failureHints {
                 PlaygroundPage.current.assessmentStatus = .fail(hints: failureHints, solution: nil)
            }
            //if it finds the pageName assigned check to see if we should ignore
            guard let _ = pageName else {
                PlaygroundPage.current.finishExecution()
            }
            
           
        }
    }
}
