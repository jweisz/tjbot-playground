//#-hidden-code
/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import PlaygroundSupport
import UIKit

PlaygroundPage.current.assessmentStatus = .pass(message: nil)
//#-end-hidden-code
/*:
 * Callout(🤖 TJBot Hardware):
 In order to complete this exercise, please ensure your TJBot has an LED, a speaker, and a servo.
 
 Did you know TJBot likes to play games? It just so happens that he loves to play Rock Paper Scissors!
 
 **Goal**: Program your TJBot to play a game of Rock Paper Scissors!
 
 * Callout(The Rules of Rock Paper Scissors):
 Rock Paper Scissors is an easy game to play. There are two players, you and TJBot. On the count of three, both players choose a move – Rock, Paper, or Scissors – and reveal it to each other. The winner is based on the following rules: Rock breaks Scissors, Paper covers Rock, and Scissors cuts Paper. Simple!
 
 In this exercise, TJBot should perform the following actions:
 1. Announce that a new game of Rock Paper Scissors is about to begin.
 2. Describe the rules of Rock Paper Scissors.
 3. Count down from three while waving his arm on each count.
 4. Announce your move. For example, TJBot may say, "You chose scissors."
 5. Lower his arm and announce his move. For example, TJBot may say, "I chose rock."
 6. Determine the winner. If you win, TJBot should congratulate you! If TJBot wins, he should perform a victory dance. In the case of a tie, TJBot should ask to play again.
 
 * Callout(💡 Tip):
 We have written some code to help you get started. `Move` is an enumeration that defines all the valid Rock Paper Scissors moves. The `randomMove()` method returns a random `Move`. The `gameResult(tjbot:beats:)` method determines whether TJBot's move beats your move. For this exercise, you will specify your own move in the variable `myMove`.
 
 */
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(identifier, hide, page, proxy)
//#-code-completion(identifier, show, tj, ., shine(color:), pulse(color:duration:), raiseArm(), lowerArm(), wave(), sleep(duration:), speak(_:), arc4random_uniform(_:), UInt32, Int)
//#-code-completion(literal, show, color)
let tj = PhysicalTJBot()

//#-copy-source(id1)
//#-editable-code
enum Move: String {
    case rock
    case paper
    case scissors
}

enum GameResult: String {
    case win
    case tie
    case lose
}

func randomMove() -> Move {
    let randomNumber = Int(arc4random_uniform(UInt32(3)))
    switch randomNumber {
    case 0:
        return .rock
    case 1:
        return .paper
    case 2:
        return .scissors
    default:
        return .rock
    }
}

func gameResult(tjbot move: Move, beats other: Move) -> GameResult {
    switch move {
    case .rock:
        switch other {
        case .rock: return .tie
        case .paper: return .lose
        case .scissors: return .win
        }
    case .paper:
        switch other {
        case .rock: return .win
        case .paper: return .tie
        case .scissors: return .lose
        }
    case .scissors:
        switch other {
        case .rock: return .lose
        case .paper: return .win
        case .scissors: return .tie
        }
    }
}

let intro = "Hello! Let's play a game of rock paper scissors. The rules are as follows. Rock breaks scissors, scissors cuts paper, and paper covers rock. Ready? Let's go."

let tjbotMove: Move = randomMove()
let myMove: Move = .rock

//#-end-editable-code
//#-end-copy-source

//: [Next page: Rock, Paper, TJBot! (Part II)](@next)
