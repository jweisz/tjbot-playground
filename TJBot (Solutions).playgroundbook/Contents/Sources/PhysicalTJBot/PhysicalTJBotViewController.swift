/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import UIKit
import PlaygroundSupport
import CoreBluetooth
import PlaygroundBluetooth

// MARK: PhysicalTJBotViewController

public class PhysicalTJBotViewController: TJBotViewController, CarriesTJBotState {
    private var tableView: UITableView?
    private var dataSource: DashboardDataSource = DashboardDataSource()
    private var header: DashboardHeader? = nil
    
    private var connectionView: PlaygroundBluetoothConnectionView? = nil
    private var tjbotManager: TJBotManager = TJBotManager()
    private var tjbot: TJBotBluetoothPeripheral? {
        return self.tjbotManager.tjbot
    }
    
    public var hardware: Set<TJBotHardware> {
        TJLog("PhysicalTJBot hardware requested")
        guard let tj = self.tjbot else { return [] }
        guard let hardware = tj.hardware else { return [] }
        return hardware
    }
    
    public var configuration: TJBotConfiguration {
        TJLog("PhysicalTJBot configuration requested")
        guard let tj = self.tjbot else {
            TJLog("PhysicalTJBotViewController configuration: self.tjbot is nil, returning default configuration")
            return TJBotConfiguration()
        }
        guard let configuration = tj.configuration else {
            TJLog("PhysicalTJBotViewController configuration: self.tjbot.configuration is nil, returning default configuration")
            return TJBotConfiguration()
        }
        TJLog("PhysicalTJBotViewController configuration: we have a real configuration, returning it")
        TJLog(" > \(configuration)")
        return configuration
    }
    
    public var capabilities: Set<TJBotCapability> {
        TJLog("PhysicalTJBot capabilities requested")
        guard let tj = self.tjbot else { return [] }
        guard let capabilities = tj.capabilities else { return [] }
        return capabilities
    }
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init(coder aDecoder: NSCoder) {
        fatalError("This method has not been implemented.")
    }
    
    deinit {
        // sleep for 1 second to make sure all BLE writes have completed
        Thread.sleep(forTimeInterval: 1.0)
    }
    
    override public func liveViewMessageConnectionOpened() {
        TJLog("liveViewMessageConnectionOpened()")
        if let header = self.header {
            header.connectionStatus = .running
        }
        
        // clear the dashboard
        self.clearDashboard()
    }
    
    override public func liveViewMessageConnectionClosed() {
        TJLog("liveViewMessageConnectionClosed()")
        if let header = self.header {
            header.connectionStatus = .sleeping
        }
        
        // stop listening if we are listening, because we only want to listen
        // while the playground is active
        guard let tj = self.tjbot else { return }
        tj.send(command: .stopListening)
    }
}

// MARK: - UITableView

extension PhysicalTJBotViewController: UITableViewDataSource, UITableViewDelegate {
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        TJLog("creating table view")
        self.createTableView()
        TJLog("creating dashboard header")
        self.createDashboardHeader()
        TJLog("creating bluetooth connection view")
        self.createBluetoothConnectionView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(PhysicalTJBotViewController.keyboardWillShow(notification:)), name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PhysicalTJBotViewController.keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification : Notification) {
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard let tableView = self.tableView else { return }
        tableView.contentInset = UIEdgeInsets(top: 212.0, left: 0, bottom: keyboardRect.height, right: 0)
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        guard let tableView = tableView else { return }
        tableView.contentInset = UIEdgeInsets(top: 212.0, left: 0, bottom: 0, right: 0)
    }
    
    func createTableView() {
        let tableView = UITableView(frame: .zero)
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.contentInset = UIEdgeInsets(top: 212.0, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -212)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 82.0
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.translatesAutoresizingMaskIntoConstraints = false
        
        tableView.register(DashboardCell.self, forCellReuseIdentifier: "DashboardCell")
        tableView.register(ListenDashboardCell.self, forCellReuseIdentifier: "ListenDashboardCell")
        tableView.register(PulseDashboardCell.self, forCellReuseIdentifier: "PulseDashboardCell")
        tableView.register(SeeDashboardCell.self, forCellReuseIdentifier: "SeeDashboardCell")
        tableView.register(ReadDashboardCell.self, forCellReuseIdentifier: "ReadDashboardCell")
        tableView.register(ToneDashboardCell.self, forCellReuseIdentifier: "ToneDashboardCell")
        tableView.register(TranslateDashboardCell.self, forCellReuseIdentifier: "TranslateDashboardCell")
        tableView.register(IdentifyDashboardCell.self, forCellReuseIdentifier: "IdentifyDashboardCell")
        tableView.register(WaveDashboardCell.self, forCellReuseIdentifier: "WaveDashboardCell")
        tableView.register(ShineDashboardCell.self, forCellReuseIdentifier: "ShineDashboardCell")
        tableView.register(RaiseArmDashboardCell.self, forCellReuseIdentifier: "RaiseArmDashboardCell")
        tableView.register(LowerArmDashboardCell.self, forCellReuseIdentifier: "LowerArmDashboardCell")
        tableView.register(SpeakDashboardCell.self, forCellReuseIdentifier: "SpeakDashboardCell")
        
        self.view.backgroundColor = UIColor(hexString: "#EAEAEA")
        self.view.autoresizingMask = [UIView.AutoresizingMask.flexibleWidth, UIView.AutoresizingMask.flexibleRightMargin, UIView.AutoresizingMask.flexibleLeftMargin]
        self.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(tableView)
        
        // must add the tableView as a subview of view before setting layout constraints
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0).isActive = true
        tableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0).isActive = true
        self.view.updateConstraintsIfNeeded()
        
        self.tableView = tableView
    }
    
    func createDashboardHeader() {
        let header = DashboardHeader()
        header.translatesAutoresizingMaskIntoConstraints = false
        
        self.view.addSubview(header)
        
        header.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0).isActive = true
        header.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0).isActive = true
        header.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0).isActive = true
        header.heightAnchor.constraint(equalToConstant: 200.0).isActive = true

        self.header = header
    }
    
    func createBluetoothConnectionView() {
        let connectionView = PlaygroundBluetoothConnectionView(centralManager: self.tjbotManager.centralManager)
        connectionView.delegate = self
        connectionView.dataSource = self
        
        self.view.addSubview(connectionView)
        connectionView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -12.0).isActive = true
        connectionView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 12.0).isActive = true
        
        // connect to the last connected tjbot
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(1000)) {
            let _ = self.tjbotManager.centralManager.connectToLastConnectedPeripheral()
        }
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataSource.count
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: dataSource.cellType(at: indexPath), for: indexPath as IndexPath) as? DashboardCell else { return UITableViewCell() }
        
        if let model = self.dataSource.item(at: indexPath) {
            cell.setupCell(model: model)
        }
        
        return cell
    }
    
    func insertDashboardStatus(model: DashboardCellModel) {
        guard let tableView = self.tableView else { return }
        self.dataSource.add(model: model)
        tableView.beginUpdates()
        let indexes = [IndexPath(row: DashboardDataSource.defaultRowAdd, section: 0)]
        tableView.insertRows(at: indexes, with: UITableView.RowAnimation.top)
        tableView.endUpdates()
    }
    
    func clearDashboard() {
        guard let tableView = self.tableView else { return }
        let totalCount = dataSource.count
        let sectionIndexes = dataSource.indexPaths
        self.dataSource.clear()
        if totalCount > 0 {
            tableView.beginUpdates()
            tableView.deleteRows(at: sectionIndexes, with: .fade)
            tableView.endUpdates()
        }
    }
}

// MARK: - PlaygroundBluetoothConnectionViewDelegate

extension PhysicalTJBotViewController: PlaygroundBluetoothConnectionViewDelegate {
    public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, shouldDisplayDiscovered peripheral: CBPeripheral, withAdvertisementData advertisementData: [String : Any]?, rssi: Double) -> Bool {
        return true
    }
    
    public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, shouldConnectTo peripheral: CBPeripheral, withAdvertisementData advertisementData: [String : Any]?) -> Bool {
        return true
    }
    
    public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, willDisconnectFrom peripheral: CBPeripheral) {
        TJLog("Disconnecting from tjbot: \(peripheral)")
        if let header = self.header {
            header.connectionStatus = .sleeping
        }
    }
    
    public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, titleFor state: PlaygroundBluetoothConnectionView.State) -> String {
        // Provide a localized title for the given state of the connection view.
        switch state {
        case .noConnection:
            return NSLocalizedString("Connect TJBot", comment:"")
        case .connecting:
            return NSLocalizedString("Connecting TJBot", comment:"")
        case .searchingForPeripherals:
            return NSLocalizedString("Searching for TJBot", comment:"")
        case .selectingPeripherals:
            return NSLocalizedString("Select TJBot", comment:"")
        case .connectedPeripheralFirmwareOutOfDate:
            return NSLocalizedString("Connect to a Different TJBot", comment:"")
        }
    }
    
    public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, firmwareUpdateInstructionsFor peripheral: CBPeripheral) -> String {
        // Provide firmware update instructions.
        return "No firmware updates are required for TJBot."
    }
}

// MARK: - PlaygroundBluetoothConnectionViewDataSource

extension PhysicalTJBotViewController: PlaygroundBluetoothConnectionViewDataSource {
    public func connectionView(_ connectionView: PlaygroundBluetoothConnectionView, itemForPeripheral peripheral: CBPeripheral, withAdvertisementData advertisementData: [String : Any]?) -> PlaygroundBluetoothConnectionView.Item {
        // Provide display information associated with a peripheral item.
        let name = peripheral.name ?? NSLocalizedString("Unknown Device", comment:"")
        let icon = UIImage(named: "tjbot_head") ?? UIImage()
        let issueIcon = icon
        let item = PlaygroundBluetoothConnectionView.Item(name: name, icon: icon, issueIcon: issueIcon, firmwareStatus: nil, batteryLevel: nil)
        return item
    }
}

// MARK: - Sleeps

extension PhysicalTJBotViewController: Sleeps {
    public func sleep(duration: TimeInterval) {
        guard let tj = self.tjbot else { return }
        tj.send(command: .sleep(duration))
    }
}

// MARK: - Analyzes Tone

extension PhysicalTJBotViewController: AnalyzesTone {
    public func analyzeTone(text: String) -> ToneResponse {
        guard let tj = self.tjbot else {
            let toneResponse = ToneResponse(error: .tjbotNotConnected)
            self.insertDashboardStatus(model: DashboardCellModel(toneResponse: toneResponse))
            return toneResponse
        }
        
        guard let response = tj.send(request: .analyzeTone(text)) else {
            let toneResponse = ToneResponse(error: .tjbotNotConnected)
            self.insertDashboardStatus(model: DashboardCellModel(toneResponse: toneResponse))
            return toneResponse
        }
        
        let toneResponse = ToneResponse(response: response)
        self.insertDashboardStatus(model: DashboardCellModel(toneResponse: toneResponse))
        return toneResponse
    }
}

// MARK: - Converses

extension PhysicalTJBotViewController: Converses {
    public func converse(workspaceId: String, message: String) -> ConversationResponse {
        // we don't add a dashboard cell for Conversation responses because there is a high likelihood
        // that they will also be spoken, so we want to avoid putting them in the dashboard twice
        guard let tj = self.tjbot else {
            return ConversationResponse(error: .tjbotNotConnected)
        }
        
        guard let response = tj.send(request: .converse(workspaceId, message)) else {
            return ConversationResponse(error: .unableToDeserializeTJBotResponse)
        }
        
        return ConversationResponse(response: response)
    }
}

// MARK: - Listens

extension PhysicalTJBotViewController: Listens {
    public func listen(_ completion: @escaping ((String) -> Void)) {
        guard let tj = self.tjbot else { return }
        TJLog("PhysicalTJBotViewController listen()")
        
        // set the callback & start listening
        tj.listenCallback = {
            response in
            self.insertDashboardStatus(model: DashboardCellModel(type: .listen, message: response))
            completion(response)
        }
        
        tj.send(command: .listen)
    }
}

// MARK: - Sees

extension PhysicalTJBotViewController: Sees {
    public func see() -> VisionResponse {
        guard let tj = self.tjbot else {
            let visionResponse = VisionResponse(error: .tjbotNotConnected)
            self.insertDashboardStatus(model: DashboardCellModel(visionResponse: visionResponse))
            return visionResponse
        }
        
        guard let response = tj.send(request: .see) else {
            let visionResponse = VisionResponse(error: .unableToDeserializeTJBotResponse)
            self.insertDashboardStatus(model: DashboardCellModel(visionResponse: visionResponse))
            return visionResponse
        }
        
        let visionResponse = VisionResponse(response: response)
        let model = DashboardCellModel(visionResponse: visionResponse)
        self.insertDashboardStatus(model: model)
        
        visionResponse.fetchImageData { (data) in
            if let imageData = data {
                if let image = UIImage(data: imageData) {
                    model.image = image
                    
                    // reload the table to show the image after it has loaded
                    DispatchQueue.main.async {
                        if let tableView = self.tableView {
                            tableView.reloadData()
                        }
                    }
                }
            }
        }
        
        return visionResponse
    }
    
    public func read() -> VisionResponse {
        guard let tj = self.tjbot else {
            let visionResponse = VisionResponse(error: .tjbotNotConnected)
            self.insertDashboardStatus(model: DashboardCellModel(visionResponse: visionResponse))
            return visionResponse
        }
        
        guard let response = tj.send(request: .read) else {
            let visionResponse = VisionResponse(error: .unableToDeserializeTJBotResponse)
            self.insertDashboardStatus(model: DashboardCellModel(visionResponse: visionResponse))
            return visionResponse
        }
        
        let visionResponse = VisionResponse(response: response)
        let model = DashboardCellModel(visionResponse: visionResponse)
        self.insertDashboardStatus(model: model)
        
        visionResponse.fetchImageData { (data) in
            if let imageData = data {
                if let image = UIImage(data: imageData) {
                    model.image = image
                    
                    // reload the table to show the image after it has loaded
                    DispatchQueue.main.async {
                        if let tableView = self.tableView {
                            tableView.reloadData()
                        }
                    }
                }
            }
        }
        
        return visionResponse
    }
}

// MARK: - Shines

extension PhysicalTJBotViewController: Shines {
    public func shine(color: UIColor) {
        guard let tj = self.tjbot else { return }
        self.insertDashboardStatus(model: DashboardCellModel(type: .shine, color: color))
        tj.send(command: .shine(color.toHexString()))
    }
    
    public func pulse(color: UIColor, duration: TimeInterval) {
        guard let tj = self.tjbot else { return }
        self.insertDashboardStatus(model: DashboardCellModel(type: .pulse, color: color))
        tj.send(command: .pulse(color.toHexString(), duration))
    }
}

// MARK: - Speaks

extension PhysicalTJBotViewController: Speaks {
    public func speak(_ message: String) {
        guard let tj = self.tjbot else { return }
        self.insertDashboardStatus(model: DashboardCellModel(type: .speak, message: message))
        let _ = tj.send(request: .speak(message))
    }
}

// MARK: - Translates

extension PhysicalTJBotViewController: Translates {
    public func translate(text: String, sourceLanguage: TJTranslationLanguage, targetLanguage: TJTranslationLanguage) -> String? {
        guard let tj = self.tjbot else {
            let translationResponse = LanguageTranslationResponse(error: .tjbotNotConnected)
            self.insertDashboardStatus(model: DashboardCellModel(translationResponse: translationResponse))
            return nil
        }
        
        guard let response = tj.send(request: .translate(text, sourceLanguage.rawValue, targetLanguage.rawValue)) else {
            let translationResponse = LanguageTranslationResponse(error: .unableToDeserializeTJBotResponse)
            self.insertDashboardStatus(model: DashboardCellModel(translationResponse: translationResponse))
            return nil
        }
        
        let translationResponse = LanguageTranslationResponse(response: response)
        self.insertDashboardStatus(model: DashboardCellModel(translationResponse: translationResponse))
        return translationResponse.translation
    }
    
    public func identifyLanguage(text: String) -> [LanguageIdentification] {
        let defaultIdentification = [LanguageIdentification(language: .unknown, confidence: 1.0)]
        guard let tj = self.tjbot else {
            self.insertDashboardStatus(model: DashboardCellModel(languages: defaultIdentification))
            return defaultIdentification
            
        }
        guard let response = tj.send(request: .identifyLanguage(text)) else {
            self.insertDashboardStatus(model: DashboardCellModel(languages: defaultIdentification))
            return defaultIdentification
        }
        
        let identificationResponse = LanguageIdentificationResponse(response: response)
        self.insertDashboardStatus(model: DashboardCellModel(identificationResponse: identificationResponse))
        return identificationResponse.languages
    }
}

// MARK: - Waves

extension PhysicalTJBotViewController: Waves {
    public func raiseArm() {
        guard let tj = self.tjbot else { return }
        self.insertDashboardStatus(model: DashboardCellModel(type: .raiseArm))
        tj.send(command: .raiseArm)
    }
    
    public func lowerArm() {
        guard let tj = self.tjbot else { return }
        self.insertDashboardStatus(model: DashboardCellModel(type: .lowerArm))
        tj.send(command: .lowerArm)
    }
    
    public func wave() {
        guard let tj = self.tjbot else { return }
        self.insertDashboardStatus(model: DashboardCellModel(type: .wave))
        tj.send(command: .wave)
    }
}
