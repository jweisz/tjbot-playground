/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import UIKit
import PlaygroundSupport

import CoreBluetooth

// MARK: PhysicalTJBotViewController

public class PhysicalTJBotViewController: TJBotViewController, CarriesTJBotState {
    fileprivate var dataSource: DashboardDataSource = DashboardDataSource()
    fileprivate var tableView: UITableView?
    
    fileprivate var tjScanner: TJBotScanner?
    fileprivate var tjPeripheral: TJBotBluetoothPeripheral?
    
    var header: DashboardHeader?
    
    public var hardware: Set<TJBotHardware> {
        TJLog("PhysicalTJBot hardware requested")
        guard let tj = self.tjPeripheral else { return [] }
        guard let hardware = tj.hardware else { return [] }
        return hardware
    }
    
    public var configuration: TJBotConfiguration {
        TJLog("PhysicalTJBot configuration requested")
        guard let tj = self.tjPeripheral else {
            TJLog("PhysicalTJBotViewController configuration: self.tjPeripheral is nil, returning default configuration")
            return TJBotConfiguration()
        }
        guard let configuration = tj.configuration else {
            TJLog("PhysicalTJBotViewController configuration: self.tjPeripheral.configuration is nil, returning default configuration")
            return TJBotConfiguration()
        }
        TJLog("PhysicalTJBotViewController configuration: we have a real configuration, returning it")
        TJLog(" > \(configuration)")
        return configuration
    }
    
    public var capabilities: Set<TJBotCapability> {
        TJLog("PhysicalTJBot capabilities requested")
        guard let tj = self.tjPeripheral else { return [] }
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
    }
    
    override public func liveViewMessageConnectionClosed() {
        TJLog("liveViewMessageConnectionClosed()")
        
        // stop the bluetooth scan just in case it's still running
        self.tjScanner?.stopScanning()
        self.tjScanner = nil
        
        // disconnect from tjbot if we are connected
        guard let tj = self.tjPeripheral else { return }
        tj.disconnect()
        if let header = header {
            header.updateConnectionStatus(status: .notConnected)
        }
    }
}

// MARK: - UIViewController

extension PhysicalTJBotViewController: UITableViewDataSource, UITableViewDelegate {
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleRightMargin, UIViewAutoresizing.flexibleLeftMargin]
        createTableView()
        createBotHeader()
        NotificationCenter.default.addObserver(self, selector: #selector(PhysicalTJBotViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(PhysicalTJBotViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    }
    
    func keyboardWillShow(notification : Notification) {
        if let keyboardRect = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue  {
            if let tableview = tableView {
                tableview.contentInset = UIEdgeInsetsMake(265.0, 0, keyboardRect.height, 0)
            }
        }
    }
    
    func keyboardWillHide(notification: Notification) {
        if let tableview = tableView {
            tableview.contentInset = UIEdgeInsetsMake(265.0, 0, 0, 0)
        }
    }
    
    func createTableView() {
        view.backgroundColor = UIColor(hexString: "#EAEAEA")
        let tableview = UITableView(frame: .zero)
        tableview.rowHeight = UITableViewAutomaticDimension
        tableview.estimatedRowHeight = 82.0
        view.translatesAutoresizingMaskIntoConstraints = false
        tableview.translatesAutoresizingMaskIntoConstraints = false
        tableview.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableview.separatorStyle = .none
        tableview.register(DashboardCell.self, forCellReuseIdentifier: "DashboardCell")
        tableview.register(ListenDashboardCell.self, forCellReuseIdentifier: "ListenDashboardCell")
        tableview.register(PulseDashboardCell.self, forCellReuseIdentifier: "PulseDashboardCell")
        tableview.register(SeeDashboardCell.self, forCellReuseIdentifier: "SeeDashboardCell")
        tableview.register(ReadDashboardCell.self, forCellReuseIdentifier: "ReadDashboardCell")
        tableview.register(ToneDashboardCell.self, forCellReuseIdentifier: "ToneDashboardCell")
        tableview.register(TranslateDashboardCell.self, forCellReuseIdentifier: "TranslateDashboardCell")
        tableview.register(IdentifyDashboardCell.self, forCellReuseIdentifier: "IdentifyDashboardCell")
        tableview.register(WaveDashboardCell.self, forCellReuseIdentifier: "WaveDashboardCell")
        tableview.register(ShineDashboardCell.self, forCellReuseIdentifier: "ShineDashboardCell")
        tableview.register(RaiseArmDashboardCell.self, forCellReuseIdentifier: "RaiseArmDashboardCell")
        tableview.register(LowerArmDashboardCell.self, forCellReuseIdentifier: "LowerArmDashboardCell")
        tableview.register(SpeakDashboardCell.self, forCellReuseIdentifier: "SpeakDashboardCell")
        tableview.dataSource = self
        tableview.delegate = self
        view.addSubview(tableview)
        tableview.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0).isActive = true
        tableview.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0).isActive = true
        tableview.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0).isActive = true
        tableview.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0.0).isActive = true
        view.updateConstraintsIfNeeded()
        tableview.contentInset = UIEdgeInsetsMake(265.0, 0, 0, 0)
        tableview.contentOffset = CGPoint(x: 0, y: -265)
        tableView = tableview
        
    }
    
    func createBotHeader() {
        self.header = DashboardHeader(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 256))
        guard let header = self.header else {
            return
        }
        header.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(header)
        header.createAssets()
        header.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0.0).isActive = true
        header.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0.0).isActive = true
        header.topAnchor.constraint(equalTo: view.topAnchor, constant: 0.0).isActive = true
        header.heightAnchor.constraint(equalToConstant: 256.0).isActive = true
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: dataSource.cellType(at: indexPath), for: indexPath as IndexPath) as? DashboardCell else { return UITableViewCell() }
        
        if let model = dataSource.item(at: indexPath) {
            cell.setupCell(model: model)
        }
        return cell
    }
    
    func insertDashboardStatus(model: DashboardCellModel) {
        dataSource.add(model: model)
        if let tableview = tableView {
            tableview.beginUpdates()
            let indexes = [IndexPath(row: DashboardDataSource.defaultRowAdd, section: 0)]
            tableview.insertRows(at: indexes, with: UITableViewRowAnimation.top)
            tableview.endUpdates()
        }        
    }
    
    func clearDashboard() {
        let totalCount = dataSource.count
        let sectionIndexes = dataSource.indexPaths
        dataSource.clear()
        if totalCount > 0 {
            if let tableview = tableView {
                tableview.beginUpdates()
                tableview.deleteRows(at: sectionIndexes, with: .fade)
                tableview.endUpdates()
            }
        }
        
    }
}

// MARK: - RemotelyConnects

extension PhysicalTJBotViewController: RemotelyConnects {
    func connectToTJBot(scanDuration: TimeInterval) -> Bool {
        if let header = self.header {
            header.updateConnectionStatus(status: .searching)
        }
        clearDashboard()
        // figure out which tjbot we're supposed to connect to
        let tjbotName = PhysicalTJBot.tjbotName
        let scanner = TJBotScanner(scanDuration: scanDuration)
        self.tjScanner = scanner
        
        // empty tjbotName means connect to the nearest TJBot
        if tjbotName == "" {
            TJLog("PhysicalTJBotViewController connectToTJBot: scanning for nearest tjbot")
            header?.updateConnected(name: "       ")
            self.tjPeripheral = scanner.nearest()
        } else {
            TJLog("PhysicalTJBotViewController connectToTJBot: scanning for tjbot named: \(tjbotName)")
            header?.updateConnected(name: tjbotName)
            self.tjPeripheral = scanner.tjbot(named: tjbotName)
        }
        
        if let _ = self.tjPeripheral {
            TJLog("PhysicalTJBotViewController connectToTJBot: found the tjbot")
        } else {
            TJLog("PhysicalTJBotViewController connectToTJBot: did not find the tjbot")
        }
        
        if let header = self.header {
            if self.tjPeripheral != nil {
               header.updateConnectionStatus(status: .connected)
            } else {
                header.updateConnectionStatus(status: .notConnected)
            }
            guard let peripheral = tjPeripheral, let config = peripheral.configuration else {
                header.updateConnected(name: "       ")
                return self.tjPeripheral != nil
            }
            header.updateConnected(name: config.name)

        }
       
        // return true if we connected, false otherwise
        return self.tjPeripheral != nil
    }
}

// MARK: - Sleeps

extension PhysicalTJBotViewController: Sleeps {
    public func sleep(duration: TimeInterval) {
        guard let tj = self.tjPeripheral else { return }
        tj.send(command: .sleep(duration))
    }
}

// MARK: - Analyzes Tone

extension PhysicalTJBotViewController: AnalyzesTone {
    public func analyzeTone(text: String) -> ToneResponse {
        guard let tj = self.tjPeripheral else {
            return ToneResponse(error: .tjbotNotConnected)
        }
        
        let cellModel = DashboardCellModel(type: .tone)
        self.insertDashboardStatus(model: cellModel)
        
        guard let response = tj.send(request: .analyzeTone(text)) else {
            return ToneResponse(error: .unableToDeserializeTJBotResponse)
        }
        
        let toneResponse = ToneResponse(response: response)
        dataSource.items[0].toneResponse = toneResponse
        
        if let tableView = self.tableView {
            tableView.reloadData()
        }
        
        return ToneResponse(response: response)
    }
}

// MARK: - Converses

extension PhysicalTJBotViewController: Converses {
    public func converse(workspaceId: String, message: String) -> ConversationResponse {
        guard let tj = self.tjPeripheral else {
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
        guard let tj = self.tjPeripheral else { return }
        TJLog("PhysicalTJBotViewController listen()")
        
        // set the callback & start listening
        tj.listenCallback = {
            response in
            var cellModel = DashboardCellModel(type: .listen)
            cellModel.message = response
            self.insertDashboardStatus(model: cellModel)
            completion(response)
        }
        
        tj.send(command: .listen)
    }
}

// MARK: - Sees

extension PhysicalTJBotViewController: Sees {
    public func see() -> VisionResponse {
        guard let tj = self.tjPeripheral else {
            return VisionResponse(error: .tjbotNotConnected)
        }
        
        let cellModel = DashboardCellModel(type: .see)
        self.insertDashboardStatus(model: cellModel)
        
        guard let response = tj.send(request: .see) else {
            return VisionResponse(error: .unableToDeserializeTJBotResponse)
        }
        
        let visionResponse = VisionResponse(response: response)
        cellModel.visionResponse = visionResponse
        
        if let tableView = self.tableView {
            tableView.reloadData()
        }
        
        visionResponse.fetchImageData { (data) in
            
            if let imageData = data {
                if let image = UIImage(data: imageData) {
                    cellModel.image = image
                    DispatchQueue.main.async {
                        if let tableView = self.tableView{
                            tableView.reloadData()
                        }
                    }
                }
            }
        }
        
        return VisionResponse(response: response)
    }
    
    public func read() -> VisionResponse {
        guard let tj = self.tjPeripheral else {
            return VisionResponse(error: .tjbotNotConnected)
        }
        
        let cellModel = DashboardCellModel(type: .read)
        self.insertDashboardStatus(model: cellModel)
        
        guard let response = tj.send(request: .read) else {
            return VisionResponse(error: .unableToDeserializeTJBotResponse)
        }
        
        let visionResponse = VisionResponse(response: response)
        dataSource.items[0].visionResponse = visionResponse
        
        if let tableView = self.tableView {
            tableView.reloadData()
        }
        
        visionResponse.fetchImageData { (data) in
            if let imageData = data {
                if let image = UIImage(data: imageData) {
                    self.dataSource.items[0].image = image
                    DispatchQueue.main.async {
                        if let tableView = self.tableView{
                            tableView.reloadData()
                        }
                    }
                }
            }
        }
        
        return VisionResponse(response: response)
    }
}

// MARK: - Shines

extension PhysicalTJBotViewController: Shines {
    public func shine(color: UIColor) {
        guard let tj = self.tjPeripheral else { return }
        tj.send(command: .shine(color.toHexString()))
        var model = DashboardCellModel(type: .shine)
        model.ledColor = color
        insertDashboardStatus(model: model)
    }
    
    public func pulse(color: UIColor, duration: TimeInterval) {
        guard let tj = self.tjPeripheral else { return }
        tj.send(command: .pulse(color.toHexString(), duration))
        var model = DashboardCellModel(type: .shine)
        model.ledColor = color
        insertDashboardStatus(model: model)
    }
}

// MARK: - Speaks

extension PhysicalTJBotViewController: Speaks {
    public func speak(_ message: String) {
        guard let tj = self.tjPeripheral else { return }
        let _ = tj.send(request: .speak(message))
        insertDashboardStatus(model: DashboardCellModel(type: .speak, message: message))
    }
}

// MARK: - Translates

extension PhysicalTJBotViewController: Translates {
    public func translate(text: String, sourceLanguage: TJTranslationLanguage, targetLanguage: TJTranslationLanguage) -> String? {
        guard let tj = self.tjPeripheral else { return nil }
        guard let response = tj.send(request: .translate(text, sourceLanguage.rawValue, targetLanguage.rawValue)) else {
            return nil
        }
        
        let cellModel = DashboardCellModel(type: .translate)
        self.insertDashboardStatus(model: cellModel)
        
        let translationResponse = LanguageTranslationResponse(response: response)
        dataSource.items[0].translationResponse = translationResponse
        
        if let tableView = self.tableView {
            tableView.reloadData()
        }
        
        return translationResponse.translation
    }
    
    public func identifyLanguage(text: String) -> [LanguageIdentification] {
        let defaultIdentification = [LanguageIdentification(language: .unknown, confidence: 1.0)]
        guard let tj = self.tjPeripheral else { return defaultIdentification }
        guard let response = tj.send(request: .identifyLanguage(text)) else {
            return defaultIdentification
        }
        
        let cellModel = DashboardCellModel(type: .identify)
        self.insertDashboardStatus(model: cellModel)
        
        let identificationResponse = LanguageIdentificationResponse(response: response)
        dataSource.items[0].identificationResponse = identificationResponse
        
        if let tableView = self.tableView {
            tableView.reloadData()
        }

        return identificationResponse.languages
    }
}

// MARK: - Waves

extension PhysicalTJBotViewController: Waves {
    public func raiseArm() {
        guard let tj = self.tjPeripheral else { return }
        tj.send(command: .raiseArm)
        insertDashboardStatus(model: DashboardCellModel(type: .raiseArm))
    }
    
    public func lowerArm() {
        guard let tj = self.tjPeripheral else { return }
        tj.send(command: .lowerArm)
        insertDashboardStatus(model: DashboardCellModel(type: .lowerArm))
    }
    
    public func wave() {
        guard let tj = self.tjPeripheral else { return }
        tj.send(command: .wave)
        insertDashboardStatus(model: DashboardCellModel(type: .wave))
    }
}

// MARK: - Stayin' Alive

extension PhysicalTJBotViewController {
    func stayAlive() {
        TJLog("TJBot staying alive")
        RunLoop.main.run()
        TJLog("TJBot terminated?")
    }
}
