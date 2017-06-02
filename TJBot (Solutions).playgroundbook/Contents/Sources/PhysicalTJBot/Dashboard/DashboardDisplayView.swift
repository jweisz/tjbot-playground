/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import UIKit

class DashboardDisplayView: UIView {
    var messageLabel: UILabel?
    var imageView: UIImageView?
    var addedMask: Bool = false
    var bgColor = UIColor(hexString: "#EAEAEA")
    
    func createAssets(message: String?, image: UIImage?) {
        self.backgroundColor = self.bgColor
        
        if let image = image {
            self.imageView?.removeFromSuperview()
            self.imageView?.image = nil
            self.imageView = nil
            
            let imageView = UIImageView()
            imageView.backgroundColor = UIColor(hexString: "#979797")
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.clipsToBounds = true
            imageView.heightAnchor.constraint(equalToConstant: 214).isActive = true
            imageView.contentMode = .scaleAspectFit
            imageView.image = image
            TJLog("DashboardDisplayView set image")
            self.addSubview(imageView)
            
            self.imageView = imageView
        }
        
        if let message = message {
            
            self.messageLabel?.removeFromSuperview()
            self.messageLabel = nil
            
            let label = UILabel(frame: CGRect(x: 0, y: 10, width: self.frame.size.width, height: 21))
            label.numberOfLines = 0
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = message
            label.font = label.font.withSize(13)
            label.textColor = UIColor(hexString: "#464646")
            addSubview(label)
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 10).isActive = true
            label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
            label.heightAnchor.constraint(greaterThanOrEqualToConstant: 56.0).isActive = true
            messageLabel = label
        }
    }
}
