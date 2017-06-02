/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import UIKit

class ShineDashboardCell: DashboardCell {
    override public func setupCell(model: DashboardCellModel) {
        if let ledColor = model.ledColor {
            self.displayView.bgColor = ledColor
        }
        
        super.setupCell(model: model)
    }
}
