/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import UIKit

class DashboardErrorView: UIView {
    var messageLabel: UILabel?
    var imageView: UIImageView?
    var addedMask: Bool = false
    
    func createAssets(message: String?) {
        self.backgroundColor = UIColor(hexString: "#FF7256")
        if let message = message {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 21))
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = message
            label.font = label.font.withSize(13)
            label.textColor = .white
            addSubview(label)
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
            label.heightAnchor.constraint(equalToConstant: 21).isActive = true
            messageLabel = label
        }
    }
}
