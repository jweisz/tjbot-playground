/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import UIKit

public enum IlluminationMode: String {
    case low
    case standard
}

public struct SceneIllumination {
    public var mode: IlluminationMode
    public var ledStatus: Bool
    public var ledColor: UIColor!
    public var ambientLightStatus: Bool
    public var ambientLightIntensity: CGFloat
    public var mainLightIntensity: CGFloat
    public var mainLightInnerAngle: CGFloat
    public var mainLightOuterAngle: CGFloat

    public init(mode: IlluminationMode) {
        self.mode = mode

        switch mode {
        case .low:
            self.ledStatus = false
            self.ledColor = .darkGray

            self.ambientLightStatus = false
            self.ambientLightIntensity = 1000

            self.mainLightIntensity = 100000
            self.mainLightInnerAngle = 0
            self.mainLightOuterAngle = 45

        case .standard:
            self.ledStatus = true
            self.ledColor = .white

            self.ambientLightStatus = true
            self.ambientLightIntensity = 1000

            self.mainLightIntensity = 100000
            self.mainLightInnerAngle = 90
            self.mainLightOuterAngle = 120
        }
    }
}

public struct LightDefinition: LightNaming {
    public var ambientLightName: String
    public var mainLightName: String
    public var ledLightName: String
    public var ledSpotName: String

    public init(ambientLightName: String = "ambientLight",
                mainLightName: String = "mainLight",
                ledLightName: String = "ledLight",
                ledSpotName: String = "ledSpot") {
        self.ambientLightName = ambientLightName
        self.mainLightName = mainLightName
        self.ledLightName = ledLightName
        self.ledSpotName = ledSpotName
    }
}
