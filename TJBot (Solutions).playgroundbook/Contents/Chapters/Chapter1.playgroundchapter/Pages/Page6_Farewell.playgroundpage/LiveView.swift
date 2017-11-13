/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import PlaygroundSupport
import Foundation

let tjBotViewController: TJBotViewController = prepareScene()

if let sceneController = tjBotViewController as? VirtualTJBotViewController {
    sceneController.beeAppear()
}
