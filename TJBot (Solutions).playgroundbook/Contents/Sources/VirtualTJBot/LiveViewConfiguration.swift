/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import PlaygroundSupport
import SceneKit

// MARK: Scene Presentation

public func setUpLiveViewWith(_ scene: VirtualScene) -> TJBotViewController {
    // Assign the liveView.
    let sceneController = VirtualTJBotViewController(virtualScene: scene)
    PlaygroundPage.current.liveView = sceneController
    return sceneController
}

public class VirtualScene: NSObject {
    var scene: SCNScene!
    var botDefinition: TJBotDefinition!
    var lightDefinition: LightDefinition!

    var camera: SCNNode!

    // Robot parts
    var tjBotModel: SCNNode!
    var tjBotArm: SCNNode!
    var tjBotLed: SCNNode!

    // Lights
    var mainLight: SCNNode!
    var ambientLight: SCNNode!
    var ledLight: SCNNode!
    var ledSpot: SCNNode!
    var beeStartPosition: BeeStartPosition!

    // Music
    var musicFile: String?

    public init(named sceneName: String,
                botDefinition: TJBotDefinition = TJBotDefinition(),
                lightDefinition: LightDefinition = LightDefinition(),
                beeStartPosition: BeeStartPosition = .outOfScreen) {

        super.init()
        self.botDefinition = botDefinition
        self.lightDefinition = lightDefinition
        self.beeStartPosition = beeStartPosition
        setupScene(sceneName)
    }

    func setupScene(_ sceneName: String) {
        scene = SCNScene(named: sceneName)

        // Assign Camera
        camera = scene!.rootNode.childNode(withName:"camera", recursively: true)!

        // Assign TJBot elements
        tjBotModel = scene!.rootNode.childNode(withName: botDefinition.bodyName, recursively: true)!
        tjBotArm = tjBotModel.childNode(withName: botDefinition.armName, recursively: true)!
        tjBotLed = tjBotModel.childNode(withName: botDefinition.ledName, recursively: true)!

        // Assign Lights
        mainLight = scene!.rootNode.childNode(withName: lightDefinition.mainLightName, recursively: true)!
        ledLight = tjBotModel.childNode(withName: lightDefinition.ledLightName, recursively: true)!
        ledSpot = tjBotModel.childNode(withName: lightDefinition.ledSpotName, recursively: true)!
        ambientLight = scene!.rootNode.childNode(withName: lightDefinition.ambientLightName, recursively: true)!
    }

    // MARK: Camera Functions
    public func cameraPosition(x: Float, y: Float, z: Float) {
        // Move camera to defined position
        camera.position = SCNVector3(x: x, y: y, z: z)
    }

    // MARK: Bot Functions
    // Define Arm Initial Position
    public func botArmPosition(position: Position) {
        var angle: Float
        switch position {
        case .up:
            angle = -1.0 * Float.pi
        case .down:
            angle = 0.0
        case .middle:
            angle = -0.5 * Float.pi
        default:
            angle = 0.0
        }

        if tjBotArm != nil {
            tjBotArm.eulerAngles = SCNVector3(x: angle, y: 0, z: 0)
        }
    }

    // MARK: Light Functions
    public func illuminationMode(_ illumination: SceneIllumination) {
        // Led light
        ledLight.isHidden = !illumination.ledStatus
        ledSpot.isHidden = !illumination.ledStatus
        
        let color: UIColor = illumination.ledColor
        ledLight.light?.color = color
        tjBotLed.geometry?.firstMaterial?.diffuse.contents = color
        tjBotLed.geometry?.firstMaterial?.selfIllumination.contents = color
        tjBotLed.geometry?.firstMaterial?.emission.contents = color
        ledLight.light?.color = color
        ledSpot.light?.color = color

        // Ambient light
        ambientLight.isHidden = !illumination.ambientLightStatus
        ambientLight.light?.intensity = illumination.ambientLightIntensity
        ambientLight.light?.color = color

        // Main light
        mainLight.light?.intensity = illumination.mainLightIntensity
        mainLight.light?.spotInnerAngle = illumination.mainLightInnerAngle
        mainLight.light?.spotOuterAngle = illumination.mainLightOuterAngle
    }

    public func sceneMusic(fileNamed: String?) {
        self.musicFile = fileNamed
    }
}
