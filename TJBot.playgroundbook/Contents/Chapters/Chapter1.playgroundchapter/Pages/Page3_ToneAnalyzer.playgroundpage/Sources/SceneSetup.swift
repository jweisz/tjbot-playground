/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import SceneKit

public func prepareScene() -> TJBotViewController {
    let scene = VirtualScene(named: "art.scnassets/WorkbenchScene.scn", beeStartPosition: .botHead)
    
    // Define initial arm position
    scene.botArmPosition(position: .middle)
    
    // Define initial camera position
    scene.cameraPosition(x: 1000, y: 300, z: 0)
    
    // Define scene illumination
    let illumination = SceneIllumination(mode: .standard)
    scene.illuminationMode(illumination)
    
    // Add music to the  scene
    scene.sceneMusic(fileNamed: "art.scnassets/Audio/no_6_bg_loop.mp3")
    
    // Init & Show Scene
    return setUpLiveViewWith(scene)
}
