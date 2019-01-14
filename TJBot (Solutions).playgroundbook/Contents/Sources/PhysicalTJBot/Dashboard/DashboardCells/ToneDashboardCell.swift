/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import UIKit

class ToneDashboardCell: DashboardTextCell {
    override public func setupCell(model: DashboardCellModel) {        
        var messageString: String? = nil
        
        if let toneResponse = model.toneResponse {
            if let error = toneResponse.error {
                self.errorView.createAssets(message: error.description)
                self.errorView.isHidden = false
            } else {
                
                let emotions = toneResponse.emotion
                let languages = toneResponse.language
                
                messageString = "Anger: \(getPercentage(emotions.anger))\n" +
                                "Fear: \(getPercentage(emotions.fear))\n" +
                                "Joy: \(getPercentage(emotions.joy))\n" +
                                "Sadness: \(getPercentage(emotions.sadness))\n" +
                                "Analytical: \(getPercentage(languages.analytical))\n" +
                                "Confident: \(getPercentage(languages.confident))\n" +
                                "Tentative: \(getPercentage(languages.tentative))\n"
            }
        }
        
        self.displayView.createAssets(message: messageString, image: nil)
        
        super.setupCell(model: model)
    }
}
