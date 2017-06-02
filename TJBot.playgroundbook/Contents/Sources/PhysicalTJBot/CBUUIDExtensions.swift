/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import CoreBluetooth

extension CBUUID {
    // TJBot service
    @nonobjc static let tjbotService                = CBUUID(string: "799d5f0d-0000-0000-a6a2-da053e2a640a")
    
    // Configuration service
    @nonobjc static let configurationService        = CBUUID(string: "799d5f0d-0001-0000-a6a2-da053e2a640a")
    @nonobjc static let configurationCharacteristic = CBUUID(string: "799d5f0d-0001-0001-a6a2-da053e2a640a")
    @nonobjc static let hardwareCharacteristic      = CBUUID(string: "799d5f0d-0001-0002-a6a2-da053e2a640a")
    @nonobjc static let capabilityCharacteristic    = CBUUID(string: "799d5f0d-0001-0003-a6a2-da053e2a640a")
    
    // Command service
    @nonobjc static let commandService              = CBUUID(string: "799d5f0d-0002-0000-a6a2-da053e2a640a")
    @nonobjc static let commandCharacteristic       = CBUUID(string: "799d5f0d-0002-0001-a6a2-da053e2a640a")
    @nonobjc static let requestCharacteristic       = CBUUID(string: "799d5f0d-0002-0002-a6a2-da053e2a640a")
    @nonobjc static let responseCharacteristic      = CBUUID(string: "799d5f0d-0002-0003-a6a2-da053e2a640a")
    @nonobjc static let listenCharacteristic        = CBUUID(string: "799d5f0d-0002-0004-a6a2-da053e2a640a")
}
