/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import UIKit

class SeeDashboardCell: DashboardCell {
    override public func setupCell(model: DashboardCellModel) {
        var messageString: String? = nil
        var image: UIImage? = nil
  
        if let visionResponse = model.visionResponse {
            if let error = visionResponse.error {
                self.errorView.createAssets(message: error.description)
                self.errorView.isHidden = false
            } else {
                messageString = visionResponse.description
                
                //put in placeholder image if there's an image url
                if visionResponse.imageURL != nil {
                    image = UIImage(named: "tjbot_placeholder_image.png")
                }
            }
        }
        
        //display image after it has loaded
        if let img = model.image {
            image = img
        }
  
        self.displayView.createAssets(message: messageString, image: image)
        
        super.setupCell(model: model)
    }
}
