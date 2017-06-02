/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import UIKit

class IdentifyDashboardCell: DashboardTextCell {
    override public func setupCell(model: DashboardCellModel) {
        var messageString: String? = nil
        
        if let identificationResponse = model.identificationResponse {
            if let error = identificationResponse.error {
                self.errorView.createAssets(message: error.description)
                self.errorView.isHidden = false
            } else {
                var result = ""
                for languageIdentification in identificationResponse.languages {
                    result += "\(languageIdentification.language): \(getPercentage(languageIdentification.confidence))\n"
                }
                messageString = result
            }
        }
        
        self.displayView.createAssets(message: messageString, image: nil)
        
        super.setupCell(model: model)
    }
}
