/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import UIKit

class DashboardTextCell: DashboardCell {
    override public func setupCell(model: DashboardCellModel) {
        super.setupCell(model: model)
        displayView.createAssets(message: model.message, image: nil)
    }
    
    func getPercentage(_ decimal: Double) -> String {
        let percent = Int(decimal * 100)
        return "\(percent)%"
    }
}
