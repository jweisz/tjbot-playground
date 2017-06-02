/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import UIKit

class DashboardHeader: UIView {
    enum ConnectionStatus: CustomStringConvertible {
        case searching
        case notConnected
        case connected
        
        public var description: String {
            switch self {
            case .searching:
                return "Searching"
            case .notConnected:
                return "Not Connected"
            case .connected:
                return "Connected"
            }
        }
    }
    
    //tag is 51
    var botNameLabel: UILabel?
    //tag is 52
    //var connectedLabel: UILabel?
    var botImage: UIImageView?
    var infoArea: DashboardHeaderInfoArea?
    var headerView: UIView?
    
    func createAssets() {
        createBlurBG()
        createBotImage()
        createInfoArea()
    }
    
    func createBlurBG() {
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        visualEffectView.frame = bounds
        addSubview(visualEffectView)
        visualEffectView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 1.0).isActive = true
        visualEffectView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 1.0).isActive = true
        //visualEffectView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 0.0).isActive = true
        //     visualEffectView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 0.0).isActive = true
    }
    
    
    func createBotImage() {
        if let bot = UIImage(named: "tjbot_header_icon.png") {
            let imageView = UIImageView(image: bot)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.frame = CGRect(x: ((self.frame.size.width-141)/2), y: 24.0, width: 141, height: 153)
            addSubview(imageView)
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 24.0).isActive = true
            imageView.widthAnchor.constraint(equalToConstant: 141).isActive = true
            imageView.heightAnchor.constraint(equalToConstant: 153).isActive = true
            botImage = imageView
        }
        
    }
    
    func createInfoArea() {
        let info = DashboardHeaderInfoArea(frame: .zero)
        info.translatesAutoresizingMaskIntoConstraints = false
        addSubview(info)
        info.createInfoArea()
       
        if let bot = botImage {
            info.topAnchor.constraint(equalTo: bot.bottomAnchor, constant: 10.0).isActive = true
            info.leadingAnchor.constraint(equalTo: bot.leadingAnchor, constant: 2.0).isActive = true
            info.trailingAnchor.constraint(equalTo: bot.trailingAnchor, constant: 2.0).isActive = true
            info.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
        }
        infoArea = info
    }
    
    func updateConnected(name botName: String) {
        if let label = infoArea?.botNameLabel {
            label.text = botName
        }
    }
    
    func updateConnectionStatus(status: ConnectionStatus) {
        if let label = self.infoArea?.connectedLabel {
            label.text = status.description
        }
    }
}
