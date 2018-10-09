/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import CoreBluetooth
import PlaygroundBluetooth

// MARK: TJBotManager

class TJBotManager: PlaygroundBluetoothCentralManagerDelegate {
    var centralManager: PlaygroundBluetoothCentralManager
    var tjbot: TJBotBluetoothPeripheral? = nil
    
    init() {
        self.centralManager = PlaygroundBluetoothCentralManager(services: [.tjbotService], queue: .global())
        self.centralManager.delegate = self
    }
    
    // MARK: PlaygroundBluetoothCentralManagerDelegate
    
    func centralManagerStateDidChange(_ centralManager: PlaygroundBluetoothCentralManager) {
        TJLog("TJBotManager centralManager updated state to \(centralManager.state)")
    }
    
    func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didDiscover peripheral: CBPeripheral, withAdvertisementData: [String : Any]?, rssi: Double) {
        TJLog("TJBotManager did discover peripheral \(peripheral)")
    }
    
    func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, willConnectTo peripheral: CBPeripheral) {
        TJLog("TJBotManager will connect to tjbot \(peripheral)")
    }
    
    func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didConnectTo peripheral: CBPeripheral) {
        TJLog("TJBotManager did connect to tjbot \(peripheral)")
        
        let tjbot = TJBotBluetoothPeripheral(centralManager: self.centralManager, peripheral: peripheral)
        
        tjbot.prepareConnection { error in
            RunLoop.main.perform {
                if let _ = error {
                    self.tjbot = nil
                } else {
                    self.tjbot = tjbot
                }
            }
            CFRunLoopStop(CFRunLoopGetMain())
        }
        
        CFRunLoopRun()
    }

    func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didFailToConnectTo peripheral: CBPeripheral, error: Error?) {
        if let error = error {
            TJLog("TJBotManager failed to connect to tjbot: \(error)")
        }
        
        self.tjbot = nil
    }
    
    func centralManager(_ centralManager: PlaygroundBluetoothCentralManager, didDisconnectFrom peripheral: CBPeripheral, error: Error?) {
        TJLog("TJBotManager disconnecting from tjbot \(peripheral.identifier)")
        self.tjbot = nil
    }
}

