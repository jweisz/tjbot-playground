/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import PlaygroundSupport
import Foundation

let tjBotViewController: TJBotViewController = prepareScene()
registerAssessment(tjBotViewController, pageName: pageName, assessment: evaluate)

if let sceneController = tjBotViewController as? VirtualTJBotViewController {
    sceneController.beeRestOnTJ()
}
