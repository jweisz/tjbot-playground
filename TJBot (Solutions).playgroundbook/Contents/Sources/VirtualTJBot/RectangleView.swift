/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import PlaygroundSupport
import UIKit

class RectangleView: UIView {
    let rectangle: UIView = UIView(frame: CGRect(x: 200, y: 300, width: 300, height: 300))

    public override init(frame: CGRect) {
        super.init(frame: frame)
        rectangle.backgroundColor = .white
        let label: UILabel = UILabel(frame: CGRect(x: 0, y: 100, width: 300, height: 60))
        label.textAlignment = .center
        label.textColor = .black
        label.text = "This is TJ B0t"
        self.addSubview(rectangle)
        rectangle.addSubview(label)
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    func shine(color: String) {
        let uiColor = UIColor(hexString: color)
        rectangle.backgroundColor = uiColor
    }
}

extension RectangleView: PlaygroundLiveViewMessageHandler {
    public func receive(_ message: PlaygroundValue) {
        if case let .string(text) = message {
            shine(color: text)
        }
    }
}
