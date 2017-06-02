/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import UIKit

class DashboardIconView: UIView {
    var iconImage: UIImageView?
    var typeLabel: UILabel?
    var addedMask: Bool = false
    var addedIcon: Bool = false
    
    func createAssets(iconName: String, labelName: String) {
        self.backgroundColor = UIColor(hexString: "#464646")
        if !addedIcon {
            if let image = UIImage(named: iconName) {
                let imageView = UIImageView(image: image)
                imageView.translatesAutoresizingMaskIntoConstraints = false
                imageView.frame = CGRect(x: 14, y: 8, width: 45, height: 45)
                addSubview(imageView)
                imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
                imageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 14.0).isActive = true
                imageView.widthAnchor.constraint(equalToConstant: 45).isActive = true
                imageView.heightAnchor.constraint(equalToConstant: 45).isActive = true
                iconImage = imageView
                
                let label = UILabel(frame: CGRect(x: 0, y: 53, width: self.frame.size.width, height: 21))
                label.translatesAutoresizingMaskIntoConstraints = false
                label.text = labelName
                label.textAlignment = .center
                label.font = label.font.withSize(13)
                label.textColor = .white
                addSubview(label)
                label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 0).isActive = true
                label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0).isActive = true
                label.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0).isActive = true
                label.heightAnchor.constraint(equalToConstant: 21).isActive = true
                typeLabel = label
            }
            addedIcon = true
        }
    }
}
