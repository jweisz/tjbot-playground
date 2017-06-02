/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

public struct TJBotDefinition: TJBotNaming {
    public var modelName: String
    public var bodyName: String
    public var mouthName: String
    public var armName: String
    public var ledName: String
    public var emotionDisplay: String

    public init(modelName: String = "TJBot",
                bodyName: String = "Body",
                mouthName: String = "Mouth",
                armName: String = "ArmControl",
                ledName: String = "LED",
                emotionDisplay: String = "emotion") {
        self.modelName = modelName
        self.bodyName = bodyName
        self.mouthName = mouthName
        self.armName = armName
        self.ledName = ledName
        self.emotionDisplay = emotionDisplay
    }
}
