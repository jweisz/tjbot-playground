/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

protocol LightNaming {
    var ambientLightName: String { get }
    var mainLightName: String { get }
    var ledLightName: String { get }
}

protocol TJBotNaming {
    var bodyName: String { get }
    var armName: String { get }
    var ledName: String { get }
}
