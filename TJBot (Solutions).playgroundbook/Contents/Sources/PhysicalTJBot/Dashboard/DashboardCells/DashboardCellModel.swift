/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import UIKit

enum DashboardCellType {
    case speak
    case wave
    case listen
    case see
    case read
    case tone
    case translate
    case identify
    case shine
    case pulse
    case raiseArm
    case lowerArm
}

class DashboardCellModel {
    var type: DashboardCellType
    var message: String?
    var image: UIImage?
    var visionResponse: VisionResponse?
    var toneResponse: ToneResponse?
    var translationResponse: LanguageTranslationResponse?
    var identificationResponse: LanguageIdentificationResponse?
    var ledColor: UIColor?
    
    init(type: DashboardCellType) {        
        self.type = type
    }
    
    init(type: DashboardCellType, message: String) {
        self.type = type
        self.message = message
    }
    
    init(visionResponse: VisionResponse) {
        self.type = .see
        self.visionResponse = visionResponse
    }
    
    init(toneResponse: ToneResponse) {
        self.type = .tone
        self.toneResponse = toneResponse
    }
    
    init(translationResponse: LanguageTranslationResponse) {
        self.type = .translate
        self.translationResponse = translationResponse
    }
    
    init(identificationResponse: LanguageIdentificationResponse) {
        self.type = .identify
        self.identificationResponse = identificationResponse
    }
    
    init(languages: [LanguageIdentification]) {
        self.type = .identify
        var response = LanguageIdentificationResponse()
        response.languages = languages
        self.identificationResponse = response
    }
    
    init(type: DashboardCellType, color: UIColor) {
        self.type = type
        self.ledColor = color
    }
    
    var iconPath: String {
        switch type {
        case .speak:
            return "speak_icon.png"
        case .wave, .raiseArm, .lowerArm:
            return "wave_icon.png"
        case .listen:
            return "listen_icon.png"
        case .see, .read:
            return "see_icon.png"
        case .tone:
            return "tone_icon.png"
        case .translate:
            return "translate_icon.png"
        case .identify:
            return "translate_icon.png"
        case .shine:
            return "shine_icon.png"
        case .pulse:
            return "shine_icon.png"
        }
    }
    
    var typeName: String {
        switch type {
        case .speak:
            return "Speak"
        case .wave:
            return "Wave"
        case .listen:
            return "Listen"
        case .see:
            return "See"
        case .read:
            return "Read"
        case .tone:
            return "Tone"
        case .translate:
            return "Translate"
        case .identify:
            return "Identify"
        case .shine:
            return "Shine"
        case .pulse:
            return "Pulse"
        case .raiseArm:
            return "Raise Arm"
        case .lowerArm:
            return "Lower Arm"
        }
    }
    
    var cellType: String {
        switch type {
        case .speak:
            return "SpeakDashboardCell"
        case .pulse:
            return "PulseDashboardCell"
        case .wave:
            return "WaveDashboardCell"
        case .listen:
            return "ListenDashboardCell"
        case .shine:
            return "ShineDashboardCell"
        case .see:
            return "SeeDashboardCell"
        case .read:
            return "ReadDashboardCell"
        case .tone:
            return "ToneDashboardCell"
        case .translate:
            return "TranslateDashboardCell"
        case .identify:
            return "IdentifyDashboardCell"
        case .raiseArm:
            return "RaiseArmDashboardCell"
        case .lowerArm:
            return "LowerArmDashboardCell"
        }
    }
}
