/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import CoreBluetooth

#if os(iOS)
    extension CBManagerState: CustomStringConvertible {
        public var description: String {
            switch self {
            case .poweredOff:
                return "poweredOff"
            case .poweredOn:
                return "poweredOn"
            case .resetting:
                return "resetting"
            case .unauthorized:
                return "unauthorized"
            case .unknown:
                return "unknown"
            case .unsupported:
                return "unsupported"
            }
        }
    }
#endif

#if os(macOS)
    extension CBCentralManagerState: CustomStringConvertible {
        public var description: String {
            switch self {
            case .poweredOff:
                return "poweredOff"
            case .poweredOn:
                return "poweredOn"
            case .resetting:
                return "resetting"
            case .unauthorized:
                return "unauthorized"
            case .unknown:
                return "unknown"
            case .unsupported:
                return "unsupported"
            }
        }
    }
#endif
