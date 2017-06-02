/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import CoreBluetooth

class TJBotScanner {
    let scanDuration: TimeInterval
    var timer: Timer? = nil
    
    var isConnecting: Bool = false
    var connectedTJBot: TJBotBluetoothPeripheral? = nil
    var soughtTJBotName: String? = nil
    
    var manager: TJBotManager = TJBotManager()
    
    init(scanDuration: TimeInterval) {
        self.scanDuration = scanDuration
        self.manager.delegate = self
    }
}

extension TJBotScanner {
    func stopScanning() {
        TJLog("TJBotScanner stopScanning(): ending tjbot scan")
        self.manager.stopScanning()
        self.connectedTJBot = nil
    }
}

extension TJBotScanner: TJBotManagerDelegate {
    func tjbotManager(_ manager: TJBotManager, didDiscover endpoint: TJBotEndpoint) {
        // is this the tjbot we are looking for?
        if let soughtTJBotName = self.soughtTJBotName, let endpointName = endpoint.name {
            if endpointName.lowercased() == soughtTJBotName.lowercased() {
                TJLog("TJBotScanner found the TJBot we are looking for, named \(soughtTJBotName)")
                
                // stop scanning
                manager.stopScanning()
                
                // connect to the bot
                self.isConnecting = true
                manager.connect(to: endpoint)
            }
        }
    }
    
    func tjbotManager(_ manager: TJBotManager, didConnect tjbot: TJBotBluetoothPeripheral) {
        TJLog("TJBotScanner did connect to a TJBot!")
        self.connectedTJBot = tjbot
        self.isConnecting = false
        CFRunLoopStop(CFRunLoopGetMain())
    }
    
    func tjbotManager(_ manager: TJBotManager, didFailToConnect endpoint: TJBotEndpoint, error: Error?) {
        if let error = error {
            TJLog("TJBotScanner failed to connect to a TJBot: \(error)")
        }
        self.connectedTJBot = nil
        self.isConnecting = false
        CFRunLoopStop(CFRunLoopGetMain())
    }
    
    @objc func timerFired(_ timer: Timer?) {
        TJLog("TJBotScanner's timer fired, halting scan. soughtTJBotName: \(soughtTJBotName as Optional)")
        self.timer = nil
        
        // are we looking for a specific tjbot?
        if let _ = self.soughtTJBotName {
            // if we are connecting to it, do nothing. if we haven't initiated a connectiion to
            // it, then it wasn't discovered and we should just stop the run loop
            if !self.isConnecting {
                self.connectedTJBot = nil
                CFRunLoopStop(CFRunLoopGetMain())
            }
        } else {
            // if we are looking for the closest TJBot, then connect to it
            // sort the nearby tjbots by RSSI
            let nearby = self.manager.nearbyTJBots.sorted { $0.rssi > $1.rssi && $0.rssi != 127 }
            
            // pick the closest one
            guard let closest = nearby.first else {
                TJLog("TJBotScanner did not find a TJBot nearby")
                CFRunLoopStop(CFRunLoopGetMain())
                return
            }
            
            // and connect to it
            TJLog("TJBotScanner connecting to \(closest)")
            self.isConnecting = true
            manager.connect(to: closest)
        }
    }
}

extension TJBotScanner {
    func nearest() -> TJBotBluetoothPeripheral? {
        // not looking for any specific tjbot
        self.soughtTJBotName = nil
        
        // start scanning
        self.manager.startScanning()
        self.timer = Timer.scheduledTimer(timeInterval: self.scanDuration, target: self, selector: #selector(TJBotScanner.timerFired(_:)), userInfo: nil, repeats: false)
        
        // wait until the timer fires by going back to the runloop
        CFRunLoopRun()
        
        // stop scanning
        self.manager.stopScanning()
        self.timer?.invalidate()
        self.timer = nil
        
        // return the bot we connected to
        return self.connectedTJBot
    }
    
    func nearby() -> [TJBotEndpoint] {
        // this is the droid we are looking for
        self.soughtTJBotName = nil
        
        // start scanning
        self.manager.startScanning()
        self.timer = Timer.scheduledTimer(timeInterval: self.scanDuration, target: self, selector: #selector(TJBotScanner.timerFired(_:)), userInfo: nil, repeats: false)
        
        // wait until the timer fires by going back to the runloop
        CFRunLoopRun()
        
        // stop scanning
        self.manager.stopScanning()
        self.timer?.invalidate()
        self.timer = nil
        
        // return the bot if we found it
        return self.manager.nearbyTJBots
    }
    
    func tjbot(named name: String) -> TJBotBluetoothPeripheral? {
        // this is the droid we are looking for
        self.soughtTJBotName = name

        // start scanning
        self.manager.startScanning()
        self.timer = Timer.scheduledTimer(timeInterval: self.scanDuration, target: self, selector: #selector(TJBotScanner.timerFired(_:)), userInfo: nil, repeats: false)

        // wait until the timer fires by going back to the runloop
        CFRunLoopRun()

        // stop scanning
        self.manager.stopScanning()

        self.timer?.invalidate()
        self.timer = nil
        
        // return the bot we connected to
        return self.connectedTJBot

    }
}

extension TJBotScanner {
    static var defaultTimeout: TimeInterval = 5
    
    class func named(_ name: String, timeout: TimeInterval = TJBotScanner.defaultTimeout) -> TJBotBluetoothPeripheral? {
        let scanner = TJBotScanner(scanDuration: timeout)
        return scanner.tjbot(named: name)
    }
    
    class func nearest(timeout: TimeInterval = TJBotScanner.defaultTimeout) -> TJBotBluetoothPeripheral? {
        let scanner = TJBotScanner(scanDuration: timeout)
        return scanner.nearest()
    }
    
    class func nearby(timeout: TimeInterval = TJBotScanner.defaultTimeout) -> [TJBotEndpoint] {
        let scanner = TJBotScanner(scanDuration: timeout)
        return scanner.nearby()
    }
}
