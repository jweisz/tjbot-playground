/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import CoreBluetooth

// MARK: TJBotBluetoothPeripheral

class TJBotBluetoothPeripheral: NSObject, CBPeripheralDelegate {
    private let cbCentralManager: CBCentralManager
    private let cbPeripheral: CBPeripheral
    
    // callbacks when certain events happen
    private var preparationCallback: ((Error?) -> Void)?
    
    // for receiving tjbot's configuration & capabilities
    var hardwareCharacteristic: CBCharacteristic? // read
    var configurationCharacteristic: CBCharacteristic? // read
    var capabilityCharacteristic: CBCharacteristic? // read
    
    // for sending commands w/no response
    var commandCharacteristic: CBCharacteristic? // write
    
    // for sending requests w/ responses returned
    var requestCharacteristic: CBCharacteristic? // write
    var responseCharacteristic: CBCharacteristic? // notify
    var responseCharacteristicIsSubscribed = false
    
    // for receiving streaming data from listen()
    var listenCharacteristic: CBCharacteristic? // notify
    var listenCharacteristicIsSubscribed = false
    var listenCallback: ((String) -> Void)?
    
    // keep track of data we have read from each characteristic
    private var readBuffers: [CBUUID: Data] = [
        .responseCharacteristic: Data()]
    
    // keep track of the response we have deserialized from responseCharacteristic while
    // send() is executing
    private var responseBuffer: TJBotBluetoothResponse? = nil
    private var responseLock = DispatchSemaphore(value: 0)
    
    // cache the configuration and capabilities
    var hardware: Set<TJBotHardware>?
    var configuration: TJBotConfiguration?
    var capabilities: Set<TJBotCapability>?
    
    init(central: CBCentralManager, peripheral: CBPeripheral) {
        assert(peripheral.state == .connected)
        self.cbCentralManager = central
        self.cbPeripheral = peripheral
        
        super.init()
        
        self.cbPeripheral.delegate = self
    }
    
    // MARK: Instance Methods
    
    /// Disconnect from the peripheral
    func disconnect() {
        TJLog("TJBotBluetoothPeripheral disconnect(): disconnecting from bluetooth")
        self.cbCentralManager.cancelPeripheralConnection(self.cbPeripheral)
    }
    
    /// Sends a command to TJBot. Does not wait for a response to be received before returning.
    func send(command: TJBotCommand) {
        guard let commandCharacteristic = self.commandCharacteristic else { return }
        guard let payload = command.serialize() else { return }
        
        TJLog("TJBotBluetoothPeripheral send command \(command)")
        self.send(payload: payload, to: commandCharacteristic)
    }
    
    /// Sends a request to TJBot. Waits for a response to be received before returning.
    func send(request: TJBotRequest) -> AnyObject? {
        guard let requestCharacteristic = self.requestCharacteristic else { return nil }
        guard let payload = request.serialize() else { return nil }
        
        // send the payload
        self.send(payload: payload, to: requestCharacteristic)
        
        // wait until the response data are received
        self.responseLock.wait()
        
        // get the response
        guard let responseObject = self.responseBuffer?.responseObject else {
            TJLog("error: responseBuffer was nil when we didn't expect it to be!")
            return nil
        }
        
        // clear it out for the next send()
        self.responseBuffer = nil
        
        return responseObject
    }
    
    private func send(payload: Data, to characteristic: CBCharacteristic) {
        // subtract 1 from the mtu to account for the null byte
        let mtu = self.cbPeripheral.maximumWriteValueLength(for: .withResponse) - 1
        
        // figure out how many writes we need
        let writeCount = Int(ceil(Double(payload.count) / Double(mtu)))
        
        TJLog("Sending \(payload) to characteristic \(characteristic.uuid) in \(writeCount) packets")
        if let description = String(data: payload, encoding: .utf8) {
            TJLog(" > \(description)")
        }
        
        for i in 0..<writeCount {
            let offset = i * mtu
            let bytesRemaining = payload.count - offset
            let packetEnd = bytesRemaining > mtu ? offset + mtu : offset + bytesRemaining
            let packet = payload.subdata(in: offset..<packetEnd)
            self.cbPeripheral.writeValue(packet, for: characteristic, type: .withResponse)
            TJLog(" > wrote \(packet)")
        }
        
        // write the null byte to terminate the packet
        let nullByte = Data(bytes: [0x0])
        self.cbPeripheral.writeValue(nullByte, for: characteristic, type: .withResponse)
        
        TJLog(" > done sending payload")
    }
    
    func prepareConnection(callback: @escaping (Error?) -> Void) {
        assert(preparationCallback == nil)
        preparationCallback = callback
        TJLog("TJBotBluetoothPeripheral prepareConnection()")
        self.cbPeripheral.discoverServices([.configurationService, .commandService])
    }
    
    private func received(packet: Data, for characteristic: CBCharacteristic) {
        TJLog("TJBotBluetoothPeripheral received() characteristic.uuid \(characteristic.uuid)")
        let response = TJBotBluetoothResponse(responseData: packet)
        
        switch characteristic.uuid {
        case CBUUID.hardwareCharacteristic:
            // store the hardware list
            guard let hardwareList = response.responseObject as? [String] else { return }
            self.hardware = self.parseHardware(from: hardwareList)
            self.finishPreparationIfAllDataLoaded()
        case CBUUID.capabilityCharacteristic:
            // store the capability list
            guard let capabilityList = response.responseObject as? [String] else { return }
            self.capabilities = self.parseCapabilities(from: capabilityList)
            self.finishPreparationIfAllDataLoaded()
        case CBUUID.configurationCharacteristic:
            // store the configuration
            guard let configuration = response.responseObject as? [String : AnyObject] else { return }
            self.configuration = self.parseConfiguration(from: configuration)
            self.finishPreparationIfAllDataLoaded()
        case CBUUID.responseCharacteristic:
            // store the response
            self.responseBuffer = response
            
            // signal send() that we received the response
            responseLock.signal()
        case CBUUID.listenCharacteristic:
            // deserialize
            TJLog("TJBotBluetoothPeripheral received data on listenCharacteristic")
            guard let text = String(data: packet, encoding: .utf8) else { return }
            TJLog("TJBotBluetoothPeripheral listenCharacteristic received text \(text)")
            
            // call the callback that is expecting listen() data. need to do this on the main
            // thread so any subsequent calls into tjbot happen from the main thread, not
            // the TJBotManager queue. otherwise, we may end up blocking when waiting for data
            // because of our use of DispatchSemaphores -- calling wait() will block the thread,
            // so if it's done from the TJBotManager queue, it will block and prevent 
            // didUpdateValueFor: from being invoked.
            DispatchQueue.main.async {
                self.listenCallback?(text)
            }
        default:
            break
        }
    }
    
    private func parseHardware(from hardware: [String]) -> Set<TJBotHardware> {
        var hardwareSet: Set<TJBotHardware> = []
        
        for hardwareStr in hardware {
            guard let hardware = TJBotHardware(rawValue: hardwareStr) else { continue }
            hardwareSet.insert(hardware)
        }
        
        return hardwareSet
    }
    
    private func parseConfiguration(from configuration: [String : AnyObject]) -> TJBotConfiguration {
        TJLog("TJBotBluetoothPeripheral parseConfiguration: attempt to create configuration from")
        TJLog(" > \(configuration)")
        let config = TJBotConfiguration(response: configuration as AnyObject)
        return config
    }
    
    private func parseCapabilities(from capabilities: [String]) -> Set<TJBotCapability> {
        var capabilitySet: Set<TJBotCapability> = []
        
        for capabilityStr in capabilities {
            guard let capability = TJBotCapability(rawValue: capabilityStr) else { continue }
            capabilitySet.insert(capability)
        }
        
        return capabilitySet
    }
    
    private func finishPreparationIfAllDataLoaded() {
        // all of these characteristics must have been discovered
        guard let _ = self.hardwareCharacteristic else { return }
        guard let _ = self.configurationCharacteristic else { return }
        guard let _ = self.capabilityCharacteristic else { return }
        guard let _ = self.commandCharacteristic else { return }
        guard let _ = self.requestCharacteristic else { return }
        guard let _ = self.responseCharacteristic else { return }
        
        // all of this data must have been loaded
        guard let _ = self.hardware else { return }
        guard let _ = self.capabilities else { return }
        guard let _ = self.configuration else { return }
        
        // these characteristics must have been subscribed to
        if !self.responseCharacteristicIsSubscribed {
            return
        }
        if !self.listenCharacteristicIsSubscribed {
            return
        }
        
        // preparation is finished, notify the caller
        self.preparationCallback?(nil)
        self.preparationCallback = nil
    }
    
    // MARK: CBPeripheralDelegate

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            preparationCallback?(error as Error)
            preparationCallback = nil
            return
        }
        
        guard let services = peripheral.services else { return }
        
        for service in services {
            TJLog("Discovered a service: \(service.uuid)")
            
            switch service.uuid {
            case CBUUID.configurationService:
                peripheral.discoverCharacteristics([.hardwareCharacteristic, .configurationCharacteristic, .capabilityCharacteristic], for: service)
            case CBUUID.commandService:
                peripheral.discoverCharacteristics([.commandCharacteristic, .requestCharacteristic, .responseCharacteristic, .listenCharacteristic], for: service)
            default:
                continue
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            preparationCallback?(error as Error)
            preparationCallback = nil
            return
        }
        
        guard let characteristics = service.characteristics else {
            return
        }
        
        for characteristic in characteristics {
            TJLog("Discovered a characteristic: \(characteristic.uuid)")
            
            switch characteristic.uuid {
            case CBUUID.hardwareCharacteristic:
                self.hardwareCharacteristic = characteristic
                self.cbPeripheral.readValue(for: characteristic)
            case CBUUID.configurationCharacteristic:
                self.configurationCharacteristic = characteristic
                self.cbPeripheral.readValue(for: characteristic)
            case CBUUID.capabilityCharacteristic:
                self.capabilityCharacteristic = characteristic
                self.cbPeripheral.readValue(for: characteristic)
            case CBUUID.commandCharacteristic:
                self.commandCharacteristic = characteristic
            case CBUUID.requestCharacteristic:
                self.requestCharacteristic = characteristic
            case CBUUID.responseCharacteristic:
                self.responseCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            case CBUUID.listenCharacteristic:
                TJLog("discovered listen characteristic")
                self.listenCharacteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
            default:
                continue
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            preparationCallback?(error)
            preparationCallback = nil
            return
        }
        
        if characteristic.isNotifying {
            TJLog("Subscribed to characteristic \(characteristic.uuid)")
            
            switch characteristic.uuid {
            case CBUUID.responseCharacteristic:
                self.responseCharacteristicIsSubscribed = true
                self.finishPreparationIfAllDataLoaded()
            case CBUUID.listenCharacteristic:
                self.listenCharacteristicIsSubscribed = true
                self.finishPreparationIfAllDataLoaded()
            default:
                break
            }
        } else {
            TJLog("Unsubscribed from characteristic \(characteristic.uuid), re-subscribing")
            
            switch characteristic.uuid {
            case CBUUID.responseCharacteristic:
                self.responseCharacteristicIsSubscribed = false
            case CBUUID.listenCharacteristic:
                self.listenCharacteristicIsSubscribed = false
            default:
                break
            }
            
            // re-subscribe
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            preparationCallback?(error as Error)
            preparationCallback = nil
            return
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            preparationCallback?(error as Error)
            preparationCallback = nil
            return
        }
        
        // return if there's no data
        guard let value = characteristic.value else { return }
        
        TJLog("Received \(value) on characteristic \(characteristic.uuid)")
        
        guard var buffer = self.readBuffers[characteristic.uuid] else {
            if let str = String(data: value, encoding: .utf8) {
                TJLog("TJBotBluetoothPeripheral peripheral > \(str)")
            }
            TJLog("TJBotBluetoothPeripheral call received 1")
            // if there's no read buffer, it means this is for a characteristic that doesn't need
            // large writes, so just read the entire thing and process it
            self.received(packet: value, for: characteristic)
            return
        }
        
        
        // append data & write it back to self.readBuffers
        buffer.append(value)
        self.readBuffers[characteristic.uuid] = buffer
        
        // process packets at the null-byte boundaries
        while let nullIndex = buffer.index(of: 0x0) {
            
            let packetData = buffer.subdata(in: 0..<nullIndex)
            if let str = String(data: packetData, encoding: .utf8) {
                TJLog("TJBotBluetoothPeripheral peripheral >>> \(str)")

            }
            TJLog("TJBotBluetoothPeripheral call received 2")
            self.received(packet: packetData, for: characteristic)
            buffer.removeSubrange(0..<nullIndex.advanced(by: 1))
            self.readBuffers[characteristic.uuid] = buffer
        }
        
    }
}

// MARK: - TJBotBluetoothResponse

private struct TJBotBluetoothResponse {
    var responseData: Data
    var responseObject: AnyObject? {
        do {
            let data = try JSONSerialization.jsonObject(with: self.responseData, options: .init(rawValue: 0)) as AnyObject
            return data
        } catch let error {
            TJLog("error deserializing json data: \(error)")
            return nil
        }
    }
}
