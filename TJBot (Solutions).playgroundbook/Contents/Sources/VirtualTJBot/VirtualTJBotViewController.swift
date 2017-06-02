/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import UIKit
import SceneKit
import QuartzCore
import Foundation
import PlaygroundSupport

public enum Position: String {
    case up
    case middle
    case down
    case wave
}

enum Speed: Double {
    case fast = 0.2
    case normal = 0.5
    case slow = 1.0
}

public class VirtualTJBotViewController: TJBotViewController {
    var lastScale: Float = 1.0
    let game = GameHelper.sharedInstance
    var musicPlayer: SCNAudioPlayer?

    var actionQueue = VirtualTJBotActionsQueue()

    var virtualScene: VirtualScene!
    var sceneView: SCNView!
    var camera: SCNNode!
    var cameraPivot: SCNNode!
    var mainScene: SCNScene!

    // Animated nodes
    var tjBotModel: SCNNode!
    var tjBotBody: SCNNode!
    var tjBotMouth: SCNNode!
    var tjBotArm: SCNNode!
    var tjBotLed: SCNNode!
    var rebus: Bee!
    var textBubble: TextBubble!
    var danceController: DanceController!
    var emotionController: EmotionController!

    // Lights
    var mainLight: SCNNode!
    var ambientLight: SCNNode!
    var ledLight: SCNNode!
    var ledSpot: SCNNode!

    // Others
    var botDefinition: TJBotDefinition
    var lightDefinition: LightDefinition

    public override func viewDidLoad() {
        super.viewDidLoad()

        // Init view
        sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height))

        // Set view principal parameters
        sceneView.allowsCameraControl = false
        sceneView.translatesAutoresizingMaskIntoConstraints = true
        sceneView.layer.masksToBounds = true
        sceneView.contentMode = .center

        initScene()

        // Show sceneView
        view.addSubview(sceneView)

        setupSound()
        registerGestures()
    }

    public init(virtualScene: VirtualScene) {
        self.virtualScene = virtualScene
        mainScene = virtualScene.scene
        self.botDefinition = virtualScene.botDefinition
        self.lightDefinition = virtualScene.lightDefinition
        
        super.init(nibName: nil, bundle: nil)
    }

    required public init(coder aDecoder: NSCoder) {
        fatalError("This method has not been implemented.")
    }

    func initScene() {
        sceneView.scene = mainScene

        // Setup all scene elements
        setupCamera()
        setupBot()
        setupBee()
        setupLights()
        setupDance()
        setupEmotionDisplay()

        // Create an actionQueue
        actionQueue.delegate = self
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Center the sceneView
        sceneView.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    }

    func setupCamera() {
        // Assign camera
        cameraPivot = mainScene!.rootNode.childNode(withName:"CameraPivot", recursively: true)!
        camera = cameraPivot.childNode(withName:"camera", recursively: true)!
    }
    
    func setupLights() {
        // default lighting
        sceneView.autoenablesDefaultLighting = false

        // Assign Lights
        mainLight = mainScene!.rootNode.childNode(withName: lightDefinition.mainLightName, recursively: true)!
        ledLight = tjBotModel.childNode(withName: lightDefinition.ledLightName, recursively: true)!
        ledSpot = tjBotModel.childNode(withName: lightDefinition.ledSpotName, recursively: true)!
        ambientLight = mainScene!.rootNode.childNode(withName: lightDefinition.ambientLightName, recursively: true)!
    }

    func setupBot() {
        // Assign robot elements
        tjBotModel = mainScene!.rootNode.childNode(withName: botDefinition.modelName, recursively: true)!
        tjBotBody = tjBotModel.childNode(withName: botDefinition.bodyName, recursively: true)!
        tjBotMouth = tjBotModel.childNode(withName: botDefinition.mouthName, recursively: true)!
        tjBotArm = tjBotModel.childNode(withName: botDefinition.armName, recursively: true)!
        tjBotLed = tjBotModel.childNode(withName: botDefinition.ledName, recursively: true)!
    }

    func setupBee() {
        // Bee in sceneView
        let beeControlPoints = mainScene!.rootNode.childNode(withName: "BeeControlPoints", recursively: true)!
        let _ = beeControlPoints.childNode(withName: "StartPoint", recursively: true)!
        let flyingPositions = beeControlPoints.childNode(withName: "FlyingPoints", recursively: false)?.childNodes

        let beeBody = mainScene!.rootNode.childNode(withName: "Bee reference", recursively: true)!
        rebus = Bee(node: beeBody, startPosition: initialPositionNode(beePosition: virtualScene.beeStartPosition), flyingPositions: flyingPositions)

        // Assign the textbubble
        let bubbleControl = beeBody.childNode(withName: "BubbleControl", recursively: true)!
        textBubble = TextBubble(controlNode: bubbleControl)
        textBubble.delegate = self
    }

    func initialPositionNode(beePosition: BeeStartPosition) -> SCNNode {
        let positionNode: SCNNode
        switch beePosition {
        case .botHead:
            positionNode = tjBotModel.childNode(withName: "BeeHeadTarget", recursively: true)!
        case .botArm:
            positionNode = tjBotModel.childNode(withName: "BeeTarget", recursively: true)!
        case .outOfScreen:
            let beeControlPoints = mainScene!.rootNode.childNode(withName: "BeeControlPoints", recursively: true)!
            positionNode = beeControlPoints.childNode(withName: "StartPoint", recursively: true)!
        }
        return positionNode
    }

    func setupSound() {
        // Music for the scene
        if let musicFile = virtualScene.musicFile {
            if let music = SCNAudioSource(fileNamed: musicFile) {
                music.volume = 0.15
                music.loops = true
                music.shouldStream = false
                music.isPositional = false
                
                let musicPlayer = SCNAudioPlayer(source: music)
                mainScene?.rootNode.addAudioPlayer(musicPlayer)
                
                
            }
           
        }

        // Audio effects
        game.loadSound(name: "wave", fileNamed: "art.scnassets/Audio/WaveSound.aif")
    }

    func setupDance() {
        // Add nodes to the scene for music & light control while dancing
        let musicNode = SCNNode()
        let lightNode = SCNNode()
        mainScene.rootNode.addChildNode(musicNode)
        mainScene.rootNode.addChildNode(lightNode)

        danceController = DanceController(armNode: tjBotArm,
                                          bodyNode: tjBotBody,
                                          mouthNode: tjBotMouth,
                                          lightNode: lightNode,
                                          musicNode: musicNode)
        danceController.delegate = self
    }

    func setupEmotionDisplay() {
        // Create an instance for emotion Display controller
        let displayNode = tjBotModel.childNode(withName: botDefinition.emotionDisplay, recursively: true)!
        emotionController = EmotionController(displayNode: displayNode)
    }
}

// MARK: - Waves

extension VirtualTJBotViewController: Waves {
    func raiseArm() {
        // Add movement to the action queue
        actionQueue.addAction(node: tjBotArm, action: moveArm(.middle), waitingMode: .wait)
    }

    func lowerArm() {
        // Add movement to the action queue
        actionQueue.addAction(node: tjBotArm, action: moveArm(.down), waitingMode: .wait)
    }

    func wave() {
        // Define movement sequence & duration
        let animation = waveSequence()

        // Add movement sound to the action queue
        actionQueue.addFunction(function: .QC_PlaySound, parameter: "wave" as AnyObject?)

        // Add movement sequece to the action queue
        actionQueue.addAction(node: tjBotArm, action: animation, waitingMode: .wait)
    }

    fileprivate func waveSequence(movementDuration: Double = 0.2) -> SCNAction {
        // Define movement sequence
        let _: SCNAction = moveArm(.up, duration: movementDuration)
        let turndownArm: SCNAction = moveArm(.down, duration: movementDuration)
        let turnMidArm: SCNAction = moveArm(.middle, duration: movementDuration)

        return SCNAction.sequence([turnMidArm, turndownArm, turnMidArm])
    }

    fileprivate func moveArm(_ direction: Position, duration: Double = 0.5) -> SCNAction {
        var angle: CGFloat
        switch direction {
        case .up:
            angle = (CGFloat)(-0.99 * Double.pi)
        case .down:
            angle = 0.0
        case .middle:
            angle = (CGFloat)(-0.5 * Double.pi)
        default:
            angle = 0.0
        }

        let animation: SCNAction = SCNAction.rotateTo(x: angle, y: 0, z: 0, duration: duration, usesShortestUnitArc: true)
        animation.timingMode = .linear

        return animation
    }
}

// MARK: - Shines

extension VirtualTJBotViewController: Shines {
    public func shine(color: UIColor) {
        if ledLight.isHidden {
            changeMoodMusic(light: true)
        }
        if color.isDark() {
            changeMoodMusic(light: false)
        }
        // Add led color change to the action queue
        actionQueue.addFunction(function: .QC_ChangeSceneColor, parameter: color)
        actionQueue.addAction(node: ledLight, action: SCNAction.wait(duration:0.25), waitingMode: .wait)
    }

    func pulse(color: UIColor, duration: Double) {
        // Change light color
        actionQueue.addFunction(function: .QC_ChangeSceneColor, parameter: color)

        // Light pulse animation
        let pulse = pulseSequence(duration: duration)
        actionQueue.addAction(node: ledLight, action: pulse, waitingMode: .noWait)
        actionQueue.addAction(node: ambientLight, action: pulse, waitingMode: .wait)
    }
    
    fileprivate func changeLedColor(_ color: UIColor) {
        // Check if the led was turned on
        if ledLight.isHidden {
            ledLight.isHidden = false
            ledSpot.isHidden = false
            turnOnTheLights(actived: true)
        } else if color == UIColor.black {
            ledLight.isHidden = true
            ledSpot.isHidden = true
            turnOnTheLights(actived: false)
        }

        // Change the color of the led
        tjBotLed.geometry?.firstMaterial?.diffuse.contents = color
        tjBotLed.geometry?.firstMaterial?.selfIllumination.contents = color
        tjBotLed.geometry?.firstMaterial?.emission.contents = color

        // Change the light's color
        ambientLight.light?.color = color
        ledLight.light?.color = color
        ledSpot.light?.color = color
        //Change the music only if it used to be dark
    }

    fileprivate func turnOnTheLights(actived: Bool) {
        // Modify all lights in the scene
        let illumination: SceneIllumination!
        if actived {
            illumination = SceneIllumination(mode: .standard)
        } else {
            illumination = SceneIllumination(mode: .low)
        }
        virtualScene.illuminationMode(illumination)
    }
    
    internal func changeMoodMusic(light: Bool) {
        mainScene.rootNode.removeAllAudioPlayers()
        var fileName: String = "art.scnassets/Audio/larghetto_bg_music_4.mp3"
        if light {
            fileName = "art.scnassets/Audio/no_6_bg_loop.mp3"
        }
        
        if let music = SCNAudioSource(fileNamed: fileName) {
            music.volume = 0.2
            music.loops = true
            music.shouldStream = false
            music.isPositional = false
            
            let otherMusicPlayer = SCNAudioPlayer(source: music)
            mainScene.rootNode.addAudioPlayer(otherMusicPlayer)
            musicPlayer = otherMusicPlayer
        }

    }

    fileprivate func pulseSequence(duration: Double, delay: Double = 0) -> SCNAction {
        // Define an action with the defined pulse sequence
        let off = SCNAction.hide()
        let on = SCNAction.unhide()
        let onTime: SCNAction = SCNAction.wait(duration: duration)
        let offTime: SCNAction = SCNAction.wait(duration: delay)
        let pulseSequence = SCNAction.sequence([on, onTime, off, offTime])
        return pulseSequence
    }
}

// MARK: - Analyzes Tone

extension VirtualTJBotViewController: AnalyzesTone {
    func analyzeTone(text: String) -> ToneResponse {
        let toneAnalyzer = ToneAnalyzer()
        var toneResponse: ToneResponse? = nil

        toneAnalyzer.getTone(
            ofText: text,
            tones: nil,
            sentences: nil,
            failure: { (error) -> Void in
                TJLog("Tone Response failure: \(error)")
                toneResponse = ToneResponse(error: .tjbotInternalError("\(error)"))
                CFRunLoopStop(CFRunLoopGetMain())
            },
            success: { (response) in
                TJLog("Tone Response success: \(response)")
                toneResponse = response
                CFRunLoopStop(CFRunLoopGetMain())
            }
        )

        // wait for response
        TJLog("VirtualTJBotViewController analyzeTone: waiting for ToneResponse, calling CFRunLoopRun()")
        CFRunLoopRun()
        TJLog("VirtualTJBotViewController analyzeTone: response received")

        guard let response = toneResponse else {
            return ToneResponse(error: .tjbotInternalError("Failed to retrieve data from Tone Analyzer service"))
        }

        return response
    }
}

// MARK: - Translates

extension VirtualTJBotViewController: Translates {
    func translate(text: String, sourceLanguage: TJTranslationLanguage, targetLanguage: TJTranslationLanguage) -> String? {
        let langTranslator = LanguageTranslator()
        var response: LanguageTranslationResponse? = nil
        
        langTranslator.translate(
            text,
            from: sourceLanguage.rawValue,
            to: targetLanguage.rawValue,
            failure: { (error) -> Void in
                TJLog("Language Translation failure: \(error)")
                response = LanguageTranslationResponse(error: .tjbotInternalError("\(error)"))
                CFRunLoopStop(CFRunLoopGetMain())
            },
            success: { (langResponse) in
                TJLog("Language Translation success: \(response as Optional)")
                response = langResponse
                CFRunLoopStop(CFRunLoopGetMain())
            }
        )
        
        // wait for response
        TJLog("VirtualTJBotViewController translate: waiting for response, calling CFRunLoopRun()")
        CFRunLoopRun()
        TJLog("VirtualTJBotViewController translate: response received")

        guard let langResponse = response else {
            return nil
        }

        return langResponse.translation
    }
    
    func identifyLanguage(text: String) -> [LanguageIdentification] {
        let defaultIdentification = [LanguageIdentification(language: .unknown, confidence: 1.0)]
        let langTranslator = LanguageTranslator()
        var response: LanguageIdentificationResponse? = nil
        
        langTranslator.identify(
            languageOf: text,
            failure: { (error) -> Void in
                TJLog("Language Translation failure: \(error)")
                response = LanguageIdentificationResponse(error: .tjbotInternalError("\(error)"))
                CFRunLoopStop(CFRunLoopGetMain())
            },
            success: { (identResponse) in
                TJLog("Language Translation success: \(response as Optional)")
                response = identResponse
                CFRunLoopStop(CFRunLoopGetMain())
            }
        )

        // wait for response
        TJLog("VirtualTJBotViewController identifyLanguage: waiting for LanguageResponse, calling CFRunLoopRun()")
        CFRunLoopRun()
        TJLog("VirtualTJBotViewController identifyLanguage: response received")

        guard let identResponse = response else {
            return defaultIdentification
        }

        return identResponse.languages
    }
}

// MARK: - Gestures

extension VirtualTJBotViewController {
    func registerGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(panGesture)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector (handlePinchGesture(_:)))
        view.addGestureRecognizer(pinchGesture)
    }

    func handlePanGesture(_ panGesture: UIPanGestureRecognizer) {
        // get translation
        let translation = panGesture.translation(in: view)
        let point: CGPoint = CGPoint(x: 0, y: 0)
        panGesture.setTranslation(point, in: view)

        switch panGesture.state {
        case .changed:
            cameraPivot.eulerAngles.y -= Float(translation.x) / 100.0
            cameraPivot.eulerAngles.z += Float(translation.y) / 100.0

            cameraPivot.eulerAngles.y = max(-0.7, min(cameraPivot.eulerAngles.y, 0.7))
            cameraPivot.eulerAngles.z = max(0, min(cameraPivot.eulerAngles.z, 0.6))
            cameraPivot.eulerAngles.x = cameraPivot.eulerAngles.y * cameraPivot.eulerAngles.z
        default:
            break
        }
    }

    func handlePinchGesture(_ pinchGesture: UIPinchGestureRecognizer) {
        switch pinchGesture.state {
        case .began:
            lastScale = 1.0

        case .changed, .ended:
            var scale = (Float(pinchGesture.scale) - lastScale)
            if scale > 1 {
                scale /= 50.0
            }
            scale = 1 - scale
            camera.position.x *= scale
            camera.position.x = max(500, min(1000, camera.position.x))
            lastScale = Float(pinchGesture.scale)
        default:
            break
        }
    }
}

// MARK: - Dances

extension VirtualTJBotViewController: Dances {
    func botDance() {
        danceController.startDance()
        changeToDanceMusic()
    }

    fileprivate func armDanceSequence() {
        lowerArm()
        pulse(color: UIColor.red, duration: 1)
        raiseArm()
        pulse(color: UIColor.blue, duration: 1)
        wave()
    }

    fileprivate func changeToDanceMusic() {
        // Add change music function to action queue
        actionQueue.addFunction(function: .QC_ChangeMusic,
            parameter: "art.scnassets/Audio/Danger Storm.mp3" as AnyObject?)
    }

    fileprivate func returnToPageMusic() {
        // Remove player with new music & add page original player
        mainScene.rootNode.removeAllAudioPlayers()
        if musicPlayer != nil {
            mainScene.rootNode.addAudioPlayer(musicPlayer!)
        }
    }
}

// MARK: - Buzzes

extension VirtualTJBotViewController: Buzzes {
    public func beeAppear() {
        rebus.moveToRandom()
    }

    public func beeRestOnTJ() {
        // Get the position of the TJBot hand
        if let target = tjBotModel.childNode(withName: "BeeHeadTarget", recursively: true) {

            // Convert target local position to World position
            let positionInSelf = target.convertPosition(SCNVector3Make(0, 0, 0), to: nil)

            // Move Rebus to the TJBot hand
            rebus.restOn(destination: positionInSelf)
        }
    }

    public func beeRestOnTJArm() {
        // Get the position of the TJBot hand
        if let target = tjBotModel.childNode(withName: "BeeTarget", recursively: true) {

            // Convert target local position to World position
            let positionInSelf = target.convertPosition(SCNVector3Make(0, 0, 0), to: nil)

            // Move Rebus to the TJBot hand
            rebus.restOn(destination: positionInSelf)
        }
    }
    
    public func beeSpeakCommand(_ message: String) {
        // Move the bee near the bot
        TJLog("VirtualTJBotViewController calling beeRestOnTJ()")
        self.beeRestOnTJ()
        TJLog("VirtualTJBotViewController beeRestOnTJ() called")
        
        // Show the bubble
        TJLog("VirtualTJBotViewController calling textBubble.showText(\(message))")
        textBubble.showText(message)
        TJLog("VirtualTJBotViewController showText() called")
    }

    public func beeSpeak(_ message: String) {
       //here is where we add the function action to the queue
        TJLog("BEE SPEAK INITIAL CALL")
        actionQueue.addFunction(function: .QC_BeeSpeak, parameter: message as AnyObject)
        //basically forcing the TJBot to wait
        let waitTime: Double = textBubble.predictBubbleTime(text: message)
        actionQueue.addAction(node: ledLight, action: SCNAction.wait(duration: waitTime), waitingMode: .wait)
    }
}

// MARK: - BuzzesDelegate

extension VirtualTJBotViewController: BuzzesDelegate {
    func beeMessageShown() {
        rebus.moveToRandom()
    }
}

// MARK: - Emotes

extension VirtualTJBotViewController: Emotes {
    func displayBotEmotion(_ emotion: String) {
        switch emotion {
        case BotEmotion.anger.rawValue:
            emotionController.showEmotion(.anger)
            changeLedColor(UIColor.red)
        case BotEmotion.disgust.rawValue:
            emotionController.showEmotion(.disgust)
            changeLedColor(UIColor.init(red: 0, green: 0.7, blue: 0, alpha: 0))
        case BotEmotion.fear.rawValue:
            emotionController.showEmotion(.fear)
            changeLedColor(UIColor.magenta)
        case BotEmotion.joy.rawValue:
            emotionController.showEmotion(.joy)
            changeLedColor(UIColor.init(red: 0.85, green: 0.65, blue: 0.05, alpha: 0))
        case BotEmotion.sadness.rawValue:
            emotionController.showEmotion(.sadness)
            changeLedColor(UIColor.blue)
        default:
            return
        }
    }
}

// MARK: - Sleeps

extension VirtualTJBotViewController: Sleeps {
    func sleep(duration: TimeInterval) {
        actionQueue.addAction(node: ledLight, action: SCNAction.wait(duration:duration), waitingMode: .wait)
    }
}

// MARK: - DanceControllerDelegate

extension VirtualTJBotViewController: DanceControllerDelegate {
    // For Dance all movements are out of CommandQueue

    // Arm commands
    func danceMoveArm(_ position: Position, duration: Double) -> SCNAction {
        let animation = moveArm(position, duration: duration)
        return animation
    }

    func danceWave() {
        let animation = waveSequence()
        game.playSound(node: tjBotModel, name: "wave")
        tjBotArm.runAction(animation)
    }

    func slowWave(_ duration: Double = 1.0) -> SCNAction {
        let animation = waveSequence(movementDuration: duration)
        return animation
    }

    // Light commands
    func danceLightColor(_ color: UIColor) {
        changeLedColor(color)
    }

    // Music commands
    func removeDanceMusic() {
        returnToPageMusic()
    }
}

// MARK: - Queues

extension VirtualTJBotViewController: Queues {
    func runActionQueue() -> Bool {
        if actionQueue.containsItems {
            return actionQueue.runActionQueue()
        }
        return false
    }
}

// MARK: - QueueDelegate

extension VirtualTJBotViewController: VirtualTJBotActionsQueueDelegate {
    func changeSceneColor(color: UIColor) {
        changeLedColor(color)
    }

    func playSound(name: String) {
        game.playSound(node: tjBotModel, name: name)
    }

    func changeMusic(fileNamed: String) {
        if musicPlayer != nil {
            mainScene.rootNode.removeAudioPlayer(musicPlayer!)
        }

        let music = SCNAudioSource(fileNamed: fileNamed)
        music!.volume = 0.2
        music!.loops = false
        music!.shouldStream = true
        music!.isPositional = false

        let danceMusicPlayer = SCNAudioPlayer(source: music!)
        mainScene.rootNode.addAudioPlayer(danceMusicPlayer)
    }
    
    func beeWillSpeak(message: String) {
        beeSpeakCommand(message)
    }

    func actionQueueDidFinish() {
        TJLog("VirtualTJBotViewController actionQueueDidFinish()")
        isActionRunning = false
        evaluate()
    }
}
