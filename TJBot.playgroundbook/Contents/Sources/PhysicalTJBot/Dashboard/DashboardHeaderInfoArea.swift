/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import UIKit

class DashboardHeaderInfoArea: UIView {
    var botNameLabel: UILabel?
    var connectedLabel: UILabel?
    var bluetoothImage: UIImageView?
    
    func createAssets() {
        if let btImage = UIImage(named: "bluetooth_logo.png") {
            let imageView = UIImageView(image: btImage)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.frame = CGRect(x: 13, y: 12, width: 10, height: 20)
            imageView.contentMode = .scaleAspectFill
            addSubview(imageView)
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 12).isActive = true
            imageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 13.0).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 10).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
            bluetoothImage = imageView
            
            let label = UILabel(frame: CGRect(x: 30, y: 8, width: 120, height: 21))
            label.translatesAutoresizingMaskIntoConstraints = false
            if PhysicalTJBot.tjbotName.isEmpty {
                label.text = "          "
            } else {
                label.text = PhysicalTJBot.tjbotName
            }
            label.font = label.font.withSize(15)
            label.textColor = UIColor(hexString: "#464646")
            addSubview(label)
            label.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 10).isActive = true
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
            label.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 10).isActive = true
            botNameLabel = label
            
            let conLabel = UILabel(frame: CGRect(x: 30, y: 24, width: 120, height: 21))
            conLabel.translatesAutoresizingMaskIntoConstraints = false
            conLabel.text = "Not Connected"
            conLabel.font = conLabel.font.withSize(11)
            conLabel.textColor = UIColor(hexString: "#464646")
            addSubview(conLabel)
            conLabel.leftAnchor.constraint(equalTo: imageView.rightAnchor, constant: 10).isActive = true
            conLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 24).isActive = true
            conLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: 10).isActive = true
            connectedLabel = conLabel
        }
    }
    
    func createInfoArea() {
        createAssets()
    }
}
