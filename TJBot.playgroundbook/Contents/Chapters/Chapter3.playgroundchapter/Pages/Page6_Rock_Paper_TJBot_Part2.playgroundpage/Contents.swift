//#-hidden-code
/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import PlaygroundSupport
import UIKit

PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.assessmentStatus = .pass(message: nil)
//#-end-hidden-code
/*:
 * Callout(🤖 TJBot Hardware):
 In order to complete this exercise, please ensure your TJBot has an LED, a speaker, a servo, and a microphone.
 
 Let's spice things up a bit! In the previous exercise, you played Rock Paper Scissors with TJBot by writing your move directly in code. In this exercise, you'll make your move by speaking it to TJBot. Don't worry, he won't cheat!
 
 **Goal**: Enhance your game using `tj.listen()` to have TJBot hear your move. Speak "rock," "paper," or "scissors" to TJBot to tell him your move.
 
 In this exercise, TJBot should perform the following actions:
 1. Announce that a new game of Rock Paper Scissors is about to begin.
 2. Describe the rules of Rock Paper Scissors.
 3. Ask for your move. For example, TJBot may say, "What is your move?"
 
 * Callout(💡 Tip):
 If TJBot doesn't understand your move, he should announce that he didn't understand and re-prompt you for your move.
 
 4. When TJBot hears your move, he should stop pulsing. He should then wave his arm and announce your move. For example, TJBot may say, "Okay, I got your move. You chose scissors."
 5. Lower his arm and announce his move. For example, TJBot may say, "I chose rock."
 6. Determine the winner. If you win, TJBot should congratulate you! If TJBot wins, he should perform a victory dance. In the case of a tie, TJBot should ask to play again.
 7. When the game has concluded, call the `endGame()` method to end the game. This method will tell TJBot to stop listening to the microphone and end the execution of the Playground.
 
 */
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(identifier, hide, page, proxy)
//#-code-completion(identifier, show, tj, ., shine(color:), pulse(color:duration:), raiseArm(), lowerArm(), wave(), sleep(duration:), speak(_:), see(), read(), components(separatedBy:), contains(_:), arc4random_uniform(_:), UInt32, Int)
//#-code-completion(literal, show, color)
let tj = PhysicalTJBot()

//#-hidden-code
func endGame() {
    PlaygroundPage.current.finishExecution()
}
//#-end-hidden-code
//#-editable-code
//#-copy-destination("Page5_Rock_Paper_TJBot_Part_1", id1)
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

//#-end-copy-destination
//#-end-editable-code

//: [Next page: Conversing with TJBot](@next)
