/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import UIKit

class TranslateDashboardCell: DashboardTextCell {
    override public func setupCell(model: DashboardCellModel) {
        
        var messageString: String? = nil
        
        if let translationResponse = model.translationResponse {
            
            if let error = translationResponse.error {
                self.errorView.createAssets(message: error.description)
                self.errorView.isHidden = false
            } else {
                
                messageString = translationResponse.translation
            }
        }
        
        self.displayView.createAssets(message: messageString, image: nil)
        
        super.setupCell(model: model)
        
    }
}
