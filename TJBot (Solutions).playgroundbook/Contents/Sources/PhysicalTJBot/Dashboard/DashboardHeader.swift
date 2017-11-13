/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import UIKit

class DashboardHeader: UIVisualEffectView {
    enum ConnectionStatus {
        case sleeping
        case running
        
        public var image: UIImage {
            switch self {
            case .sleeping:
                return UIImage(named: "tjbot-sleeping") ?? UIImage()
            case .running:
                return UIImage(named: "tjbot-running") ?? UIImage()
            }
        }
    }
    
    fileprivate var imageView: UIImageView?
    fileprivate var status: ConnectionStatus = .sleeping
    
    public var connectionStatus: ConnectionStatus {
        get {
            return self.status
        }
        
        set {
            self.status = newValue
            guard let imageView = self.imageView else { return }
            imageView.image = newValue.image
        }
    }
    
    init() {
        let blurStyle = UIBlurEffect(style: .light)
        super.init(effect: blurStyle)
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 300, height: 200))
        imageView.contentMode = .scaleAspectFit
        self.contentView.addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 8).isActive = true
        imageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 8).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 300).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true

        self.imageView = imageView
        self.connectionStatus = .sleeping
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
