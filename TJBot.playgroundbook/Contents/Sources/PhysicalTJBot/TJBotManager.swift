/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import CoreBluetooth

// MARK: TJBotEndpoint

struct TJBotEndpoint {
    let name: String?
    let identifier: UUID
    var rssi: Int
}

extension TJBotEndpoint: CustomStringConvertible {
    public var description: String {
        let displayName = name ?? "unknown"
        return "TJBot named \"\(displayName)\" (\(identifier)) (rssi: \(rssi))"
    }
}

struct TJBotPeripheralEndpoint {
    let peripheral: CBPeripheral
    var endpoint: TJBotEndpoint
}

// MARK: - TJBotManager

class TJBotManager: NSObject, CBCentralManagerDelegate {
    private var queue = DispatchQueue(label: "TJBotManager queue")
    private lazy var central: CBCentralManager = CBCentralManager(delegate: self, queue: self.queue)
    
    weak var delegate: TJBotManagerDelegate? = nil
    
    private var discoveredTJBots: [UUID : TJBotPeripheralEndpoint] = [:]
    private var connectingTJBots: [UUID : TJBotEndpoint] = [:]
    
    var nearbyTJBots: [TJBotEndpoint] {
        let tjbots = Array(self.discoveredTJBots.values)
        let endpoints = tjbots.map { $0.endpoint }
        return endpoints
    }
    
    // MARK: CBCentralManager
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        TJLog("CBCentralManager updated state to \(central.state)")
        
        switch central.state {
        case .poweredOff:
            self.stopScanning()
        case .poweredOn:
            self.startScanning()
        case .resetting:
            break
        case .unauthorized, .unknown, .unsupported:
            break
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let endpoint = TJBotEndpoint(name: peripheral.name, identifier: peripheral.identifier, rssi: RSSI.intValue)
        let tjbot = TJBotPeripheralEndpoint(peripheral: peripheral, endpoint: endpoint)
        
        if var peripheralEndpoint = self.discoveredTJBots[peripheral.identifier] {
            // just update RSSI
            peripheralEndpoint.endpoint.rssi = RSSI.intValue
            TJLog("Updated RSSI for \(peripheralEndpoint.endpoint)")
            
        } else {
            TJLog("TJBotManager centralManager: discovered endpoint \(endpoint)")
            
            self.discoveredTJBots[peripheral.identifier] = tjbot
            RunLoop.main.perform {
                self.delegate?.tjbotManager(self, didDiscover: endpoint)
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        TJLog("TJBotManager centralManager: connected to tjbot")
        guard let connectingTJ = connectingTJBots.removeValue(forKey: peripheral.identifier) else {
            fatalError("Connected to a peripheral that we weren't tracking")
        }
        
        let tjPeripheral = TJBotBluetoothPeripheral(central: central, peripheral: peripheral)
        
        tjPeripheral.prepareConnection { error in
            RunLoop.main.perform {
                if let error = error {
                    TJLog("TJBotManager centralManager: received an error from prepareConnection: \(error)")
                    central.cancelPeripheralConnection(peripheral)
                    self.delegate?.tjbotManager(self, didFailToConnect: connectingTJ, error: error)
                } else {                    
                    self.delegate?.tjbotManager(self, didConnect: tjPeripheral)
                }
            }
            CFRunLoopStop(CFRunLoopGetMain())
        }

        CFRunLoopRun()
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        TJLog("TJBotManager centralManager: failed to connect to tjbot: \(error as Optional)")
        guard let connectingTJ = connectingTJBots.removeValue(forKey: peripheral.identifier) else {
            fatalError("Failed to connect to a peripheral that we weren't tracking")
        }
        
        RunLoop.main.perform {
            self.delegate?.tjbotManager(self, didFailToConnect: connectingTJ, error: error)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        TJLog("Disconnecting from peripheral \(peripheral.identifier)")
        connectingTJBots.removeValue(forKey: peripheral.identifier)
    }
    
    // MARK: Instance Methods
    
    func startScanning() {
        // make sure the CBCentralManager is powered on and is not already scanning
        #if os(iOS)
            guard central.state == .poweredOn && !central.isScanning else { return }
        #elseif os(macOS)
            guard central.state == .poweredOn else { return }
        #endif
        
        // begin scanning
        central.scanForPeripherals(withServices: [.tjbotService], options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    
    func stopScanning() {
        // make sure the CBCentralManager is powered on and is scanning
        #if os(iOS)
            guard central.state == .poweredOn && central.isScanning else { return }
        #elseif os(macOS)
            guard central.state == .poweredOn else { return }
        #endif
        
        // stop scanning
        TJLog("Stopping Bluetooth scan")
        central.stopScan()
    }
    
    func connect(to endpoint: TJBotEndpoint) {
        queue.async {
            guard let peripheralEndpoint = self.discoveredTJBots[endpoint.identifier] else {
                fatalError("Attempted to connect to a peripheral that was not discovered or to which a connection was previously established")
            }
            
            guard self.connectingTJBots.updateValue(peripheralEndpoint.endpoint, forKey: peripheralEndpoint.peripheral.identifier) == nil else {
                fatalError("Attempted to connect to a peripheral to which we were already connecting")
            }
            
            TJLog("Connecting to TJBot \(peripheralEndpoint.peripheral.identifier)")
            self.central.connect(peripheralEndpoint.peripheral, options: nil)
        }
    }
}

// MARK: - TJBotManagerDelegate

protocol TJBotManagerDelegate: class {
    func tjbotManager(_ manager: TJBotManager, didDiscover endpoint: TJBotEndpoint)
    func tjbotManager(_ manager: TJBotManager, didConnect tjbot: TJBotBluetoothPeripheral)
    func tjbotManager(_ manager: TJBotManager, didFailToConnect endpoint: TJBotEndpoint, error: Error?)
}

extension TJBotManagerDelegate {
    func tjbotManager(_ manager: TJBotManager, didDiscover endpoint: TJBotEndpoint) {}
    func tjbotManager(_ manager: TJBotManager, didConnect tjbot: TJBotBluetoothPeripheral) {}
    func tjbotManager(_ manager: TJBotManager, didFailToConnect endpoint: TJBotEndpoint, error: Error?) {}
}
