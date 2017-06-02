/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import SceneKit

// MARK: Delegation Protocol

protocol BuzzesDelegate: class {
    func beeMessageShown()
}

final class TextBubble {

    weak var delegate: BuzzesDelegate?

    // Bubble queue
    var bubbleInProgress = false
    var bubblesQueue: [String] = []

    // Bubble
    let maxBubbleLines = 8
    let bubble: SCNNode
    var textNodes: [SCNNode] = []
    var linesBuffer: [SCNText] = []

    init (controlNode: SCNNode) {
        self.bubble = controlNode
        prepareTextNodes(rootNode: controlNode)
    }

    public func showText (_ text: String) {
        if bubbleInProgress {
            bubblesQueue.append(text)
        } else {
            bubbleInProgress = true
            moveTextToBubble(text)
        }
    }

    public func predictBubbleTime(text: String) -> Double {
        var count = 0

        let maxLength: Float = 132.0
        var currentLine: SCNText
        var stringBuffer = ""
        var lastString = ""

        // Fill an array with all words in the string
        let words = text.characters.split { $0 == " " }.map(String.init)

        // Compose lines of text with the width of the bubble (maxLength)
        for word in words {
            stringBuffer = lastString
            if stringBuffer.characters.count > 0 {
                stringBuffer += " "
            }

            // Add next word to the SCNText
            stringBuffer += word
            currentLine = textLine(stringBuffer)

            // Check if text fits in the bubble
            if currentLine.boundingBox.max.x < maxLength {
                lastString = stringBuffer
            } else {
                // If only 1 word then write
                if lastString.characters.count == 0 {
                    count += 1
                    lastString = ""
                } else {
                    count += 1
                    lastString = word
                }
            }
        }

        // If there are words not assigned, create a line with them
        if lastString.characters.count > 0 {
            count += 1
        }
        var numberOfBubbles = count / maxBubbleLines
        if count % maxBubbleLines > 0 {
            numberOfBubbles += 1
        }
        let totalWaitTime = Double(numberOfBubbles * 5) + 2.0
        return totalWaitTime

    }

    func moveTextToBubble(_ text: String) {

        fillLinesBuffer(with: text)

        // Look for number of 'pages' needed and remaining lines
        let numberOfBubbles = linesBuffer.count / maxBubbleLines
        let finalLines = linesBuffer.count % maxBubbleLines

        // Launch the text after the bee rest on the hand
        bubble.runAction(SCNAction.wait(duration: 2),
                         completionHandler: {_ in self.presentText(maxPages: numberOfBubbles, finalLines: finalLines)})

    }

    func prepareTextNodes (rootNode: SCNNode) {
        // Add each line of 3DText to the textNodes array
        let rootText = "line"
        var textLine: SCNNode
        for index in 1...maxBubbleLines {
            textLine = rootNode.childNode(withName: rootText + String(index), recursively: true)!
            textNodes.append(textLine)
        }
    }

    func textLine(_ string: String) -> SCNText {
        // Convert a string in a 3D Geometry
        let string = SCNText(string: string, extrusionDepth: 1)
        string.font = UIFont.systemFont(ofSize: 18.0, weight: UIFontWeightLight)
        string.firstMaterial!.multiply.contents = UIColor.black
        return string
    }

    func hideText(_ hide: Bool) {
        bubble.isHidden = hide
        if hide {
            clearText()
            linesBuffer = []
        }
    }

    func fillLinesBuffer (with text: String) {
        let maxLength: Float = 132.0
        var currentLine: SCNText
        var stringBuffer = ""
        var lastString = ""

        // Fill an array with all words in the string
        let words = text.characters.split { $0 == " " }.map(String.init)

        // Compose lines of text with the width of the bubble (maxLength)
        for word in words {
            stringBuffer = lastString
            if stringBuffer.characters.count > 0 {
                stringBuffer += " "
            }

            // Add next word to the SCNText
            stringBuffer += word
            currentLine = textLine(stringBuffer)
            currentLine.font = UIFont.systemFont(ofSize: 18.0, weight: UIFontWeightLight)

            // Check if text fits in the bubble
            if currentLine.boundingBox.max.x < maxLength {
                lastString = stringBuffer
            } else {
                // If only 1 word then write
                if lastString.characters.count == 0 {
                    linesBuffer.append(currentLine)
                    lastString = ""
                } else {
                    linesBuffer.append(textLine(lastString))
                    lastString = word
                }
            }
        }

        // If there are words not assigned, create a line with them
        if lastString.characters.count > 0 {
            linesBuffer.append(textLine(lastString))
        }
    }

    func presentText(maxPages: Int, finalLines: Int) {

        // Wait 2 seconds for bee rest near the bot, then show the TextBubble
        var waitingTime: Double = 0
        bubble.runAction(SCNAction.wait(duration: waitingTime),
                         completionHandler: {_ in self.hideText(false)
        })

        waitingTime += 0.5

        // Show a new bubble 'Page' every 5 seconds
        for index in 0..<maxPages {
            let sIndex = index * maxBubbleLines
            bubble.runAction(SCNAction.wait(duration: waitingTime),
                             completionHandler: {_ in self.showTextLines(fromIndex: sIndex, to: sIndex + self.maxBubbleLines - 1)
            })

            waitingTime += 5
        }

        // Wait 5 seconds and show the remaining lines
        if finalLines > 0 {
            let inicio = maxPages * self.maxBubbleLines
            bubble.runAction(SCNAction.wait(duration: waitingTime),
                             completionHandler: {_ in self.showTextLines(fromIndex: inicio, to: inicio + finalLines - 1)
            })
            waitingTime += 5
        }

        // Wait and hide the bubble
        bubble.runAction(SCNAction.wait(duration: waitingTime),
                         completionHandler: {_ in self.processNextInQueue()})
    }

    func showTextLines(fromIndex firstIndex: Int, to lastIndex: Int) {
        var index = firstIndex
        // Fill every node with text geometry. Lines without text are filled with a space
        for lineNumber in 0..<maxBubbleLines {
            if lineNumber <= lastIndex - firstIndex {
                textNodes[lineNumber].geometry = linesBuffer[index]
                index += 1
            } else {
                textNodes[lineNumber].geometry = textLine(" ")
            }
        }
    }

    func clearText() {
        // Fill all lines with a space to clear the text
        for node in textNodes {
            node.geometry = textLine(" ")
        }
    }

    func processNextInQueue() {
        hideText(true)
        if bubblesQueue.count == 0 {
            delegate?.beeMessageShown()
            bubbleInProgress = false
            return
        }
        let nextText = bubblesQueue.first!
        bubblesQueue.remove(at: 0)
        moveTextToBubble(nextText)
    }
}
