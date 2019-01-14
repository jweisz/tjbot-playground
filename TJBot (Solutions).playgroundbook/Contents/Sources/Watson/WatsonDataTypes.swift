/*
 Copyright (C) 2017 IBM. All Rights Reserved.
 See LICENSE.txt for this book's licensing information.
 */

import Foundation
import PlaygroundSupport

// MARK: Tone Analyzer

public struct EmotionTones {
    public var anger: Double = 0.0
    public var fear: Double = 0.0
    public var joy: Double = 0.0
    public var sadness: Double = 0.0
}

public struct LanguageTones {
    public var analytical: Double = 0.0
    public var confident: Double = 0.0
    public var tentative: Double = 0.0
}

public struct ToneResponse: PlaygroundSerializable {
    public var emotion = EmotionTones()
    public var language = LanguageTones()
    public var error: TJBotError? = nil
    
    public init(response: AnyObject) {
        guard let dict = response as? Dictionary<String, AnyObject> else { return }
        
        if let error = dict["error"] as? String {
            self.error = TJBotError.tjbotInternalError(error)
            return
        }
    
        guard let documentTone = dict["document_tone"] else {
            self.error = TJBotError.unableToDeserializeTJBotResponse
            return
        }
        
        guard let tones = documentTone["tones"] as? [AnyObject] else {
            self.error = TJBotError.unableToDeserializeTJBotResponse
            return
        }
        
        for tone in tones {
            guard let toneId = tone["tone_id"] as? String else { continue }
            guard let score = tone["score"] as? Double else { continue }
            
            switch toneId {
            case "anger":
                self.emotion.anger = score
            case "fear":
                self.emotion.fear = score
            case "joy":
                self.emotion.joy = score
            case "sadness":
                self.emotion.sadness = score
            case "analytical":
                self.language.analytical = score
            case "confident":
                self.language.confident = score
            case "tentative":
                self.language.tentative = score
            default:
                break
            }
        }
    }
    
    init(error: TJBotError) {
        self.error = error
    }
}

extension ToneResponse: JSONRepresentable {
    func asJSONObject() -> [String : Any] {
        if let error = self.error {
            return ["error": error.description]
        } else {
            return [
                "document_tone": [
                    "tones": [
                        ["tone_id": "anger", "score": self.emotion.anger],
                        ["tone_id": "fear", "score": self.emotion.fear],
                        ["tone_id": "joy", "score": self.emotion.joy],
                        ["tone_id": "sadness", "score": self.emotion.sadness],
                        ["tone_id": "analytical", "score": self.language.analytical],
                        ["tone_id": "confident", "score": self.language.confident],
                        ["tone_id": "tentative", "score": self.language.tentative]
                    ]
                ]
            ]
        }
    }
}

// MARK: - Conversation

public struct ConversationResponse: PlaygroundSerializable {
    public var text: String? = nil
    public var error: TJBotError? = nil
    
    init(response: AnyObject) {
        guard let dict = response as? Dictionary<String, AnyObject> else { return }
        
        if let error = dict["error"] as? String {
            self.error = TJBotError.tjbotInternalError(error)
            return
        }
        
        guard let object = dict["object"] as? Dictionary<String, AnyObject> else {
            self.error = TJBotError.unableToDeserializeTJBotResponse
            return
        }
        
        guard let output = object["output"] else {
            self.error = TJBotError.unableToDeserializeTJBotResponse
            return
        }
        
        if let text = output["text"] as? [String] {
            guard let first = text.first else {
                self.error = TJBotError.unableToDeserializeTJBotResponse
                return
            }
            self.text = first
            
        } else if let text = output["text"] as? String {
            self.text = text
            
        } else {
            self.error = TJBotError.unableToDeserializeTJBotResponse
        }
    }

    init(error: TJBotError) {
        self.error = error
    }
}

extension ConversationResponse: JSONRepresentable {
    func asJSONObject() -> [String : Any] {
        if let error = self.error {
            return ["error": error.description]
        } else {
            return [
                "object": [
                    "output": [
                        "text": self.text ?? ""
                    ]
                ]
            ]
        }
    }
}

// MARK: - Visual Recognition

public struct VisualObjectIdentification {
    public var name: String = ""
    public var confidence: Double = 0.0
    
    init(name: String, confidence: Double) {
        self.name = name
        self.confidence = confidence
    }
}

extension VisualObjectIdentification: JSONRepresentable {
    func asJSONObject() -> [String : Any] {
        return [
            "class": self.name,
            "score": self.confidence
        ]
    }
}

public func ==(lhs: VisualObjectIdentification, rhs: VisualObjectIdentification) -> Bool {
    return lhs.name == rhs.name
}

extension Sequence where Iterator.Element == VisualObjectIdentification {
    public var highestConfidenceObject: VisualObjectIdentification {
        var highest = VisualObjectIdentification(name: "", confidence: 0.0)
        
        for identification in self {
            if identification.confidence > highest.confidence {
                highest = identification
            }
        }
        
        return highest
    }
}

public struct VisionResponse: PlaygroundSerializable {
    public var objects: [VisualObjectIdentification] = []
    public var imageURL: String? = nil
    public var error: TJBotError? = nil
    
    init(response: AnyObject) {
        guard let dict = response as? Dictionary<String, AnyObject> else { return }        
        if let error = dict["error"] as? String {
            self.error = TJBotError.tjbotInternalError(error)
            return
        }
        
        //handle response for 'see'
        if let objects = dict["objects"] as? [AnyObject], objects.count > 0 {
            for object in objects {
                guard let name = object["class"] as? String else { break }
                guard let confidence = object["score"] as? Double else { break }
                let identification = VisualObjectIdentification(name: name, confidence: confidence)
                self.objects.append(identification)
            }
        }
        
        //handle response for 'read'
        if let objects = dict["objects"] as? [String: AnyObject],
            let readImages = objects["images"] as? [AnyObject],
            let firstImage = readImages.first,
            let words = firstImage["words"] as? [AnyObject] {
            
            for word in words {
                guard let name = word["word"] as? String else { break }
                guard let confidence = word["score"] as? Double else { break }
                let identification = VisualObjectIdentification(name: name, confidence: confidence)
                self.objects.append(identification)
            }
        }
        
        if let imageURL = dict["imageURL"] as? String {
            self.imageURL = imageURL
        }
    }
    
    init(error: TJBotError) {
        self.error = error
    }
}

extension VisionResponse: CustomStringConvertible {
    public var description: String {
        if objects.count == 0 {
            return ""
        }
        //sort vision responses by greatest confidence and get string for display
        var string: String = ""
        let objectsSorted = Array(objects).sorted {$0.confidence > $1.confidence}
        for object in objectsSorted {
            let percent = Int(object.confidence * 100)
            string += "\(object.name): \(percent)%\n"
        }
        return string
    }
}

extension VisionResponse: JSONRepresentable {
    func asJSONObject() -> [String : Any] {
        if let error = self.error {
            return ["error": error.description]
        } else {
            let jsonObjects = self.objects.map { $0.asJSONObject() }
            return [
                "objects": jsonObjects,
                "imageURL": self.imageURL ?? ""
            ]
        }
    }
}

extension VisionResponse {
    func fetchImageData(_ completion: @escaping ((Data?) -> Void)) {
        guard let imageURL = self.imageURL else { return }
        guard let url = URL(string: imageURL) else { return }
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.requestCachePolicy = .reloadIgnoringLocalCacheData
        sessionConfig.urlCache = nil
        let session = URLSession(configuration: sessionConfig)
        let dataTask = session.dataTask(with: url) { (data, response, error) in
            completion(data)
        }
        dataTask.resume()
    }
}

// MARK: - Language Translation

public enum TJTranslationLanguage: String {
    case unknown = "unknown"
    case afrikaans = "af"
    case arabic = "ar"
    case azerbaijani = "az"
    case bashkir = "ba"
    case belarusian = "be"
    case bulgarian = "bg"
    case bengali = "bn"
    case bosnian = "bs"
    case czech = "cs"
    case chuvash = "cv"
    case danish = "da"
    case german = "de"
    case greek = "el"
    case english = "en"
    case esperanto = "eo"
    case spanish = "es"
    case estonian = "et"
    case basque = "eu"
    case persian = "fa"
    case finnish = "fi"
    case french = "fr"
    case gujarati = "gu"
    case hebrew = "he"
    case hindi = "hi"
    case haitian = "ht"
    case hungarian = "hu"
    case armenian = "hy"
    case indonesian = "id"
    case icelandic = "is"
    case italian = "it"
    case japanese = "ja"
    case georgian = "ka"
    case kazakh = "kk"
    case centralKhmer = "km"
    case korean = "ko"
    case kurdish = "ku"
    case kirghiz = "ky"
    case lithuanian = "lt"
    case latvian = "lv"
    case malayalam = "ml"
    case mongolian = "mn"
    case norwegianBokmal = "nb"
    case dutch = "nl"
    case norwegianNynorsk = "nn"
    case panjabi = "pa"
    case polish = "pl"
    case pushto = "ps"
    case portuguese = "pt"
    case romanian = "ro"
    case russian = "ru"
    case slovakian = "sk"
    case somali = "so"
    case albanian = "sq"
    case swedish = "sv"
    case tamil = "ta"
    case telugu = "te"
    case turkish = "tr"
    case ukrainian = "uk"
    case urdu = "ur"
    case vietnamese = "vi"
    case chinese = "zh"
    case traditionalChinese = "zh-TW"
}

extension TJTranslationLanguage {
    var languageName: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .afrikaans:
            return "Afrikaans"
        case .arabic:
            return "Arabic"
        case .azerbaijani:
            return "Azerbaijani"
        case .bashkir:
            return "Bashkir"
        case .belarusian:
            return "Belarusian"
        case .bulgarian:
            return "Bulgarian"
        case .bengali:
            return "Bengali"
        case .bosnian:
            return "Bosnian"
        case .czech:
            return "Czech"
        case .chuvash:
            return "Chuvash"
        case .danish:
            return "Danish"
        case .german:
            return "German"
        case .greek:
            return "Greek"
        case .english:
            return "English"
        case .esperanto:
            return "Esperanto"
        case .spanish:
            return "Spanish"
        case .estonian:
            return "Estonian"
        case .basque:
            return "Basque"
        case .persian:
            return "Persian"
        case .finnish:
            return "Finnish"
        case .french:
            return "French"
        case .gujarati:
            return "Gujarati"
        case .hebrew:
            return "Hebrew"
        case .hindi:
            return "Hindi"
        case .haitian:
            return "Haitian"
        case .hungarian:
            return "Hungarian"
        case .armenian:
            return "Armenian"
        case .indonesian:
            return "Indonesian"
        case .icelandic:
            return "Icelandic"
        case .italian:
            return "Italian"
        case .japanese:
            return "Japanese"
        case .georgian:
            return "Georgian"
        case .kazakh:
            return "Kazakh"
        case .centralKhmer:
            return "Central Khmer"
        case .korean:
            return "Korean"
        case .kurdish:
            return "Kurdish"
        case .kirghiz:
            return "Kirghiz"
        case .lithuanian:
            return "Lithuanian"
        case .latvian:
            return "Latvian"
        case .malayalam:
            return "Malayalam"
        case .mongolian:
            return "Mongolian"
        case .norwegianBokmal:
            return "Norwegian Bokmal"
        case .dutch:
            return "Dutch"
        case .norwegianNynorsk:
            return "Norwegian Nynorsk"
        case .panjabi:
            return "Panjabi"
        case .polish:
            return "Polish"
        case .pushto:
            return "Pushto"
        case .portuguese:         
            return "Portuguese"
        case .romanian:           
            return "Romanian"
        case .russian:            
            return "Russian"
        case .slovakian:          
            return "Slovakian"
        case .somali:             
            return "Somali"
        case .albanian:           
            return "Albanian"
        case .swedish:            
            return "Swedish"
        case .tamil:              
            return "Tamil"
        case .telugu:             
            return "Telugu"
        case .turkish:            
            return "Turkish"
        case .ukrainian:          
            return "Ukrainian"
        case .urdu:               
            return "Urdu"
        case .vietnamese:         
            return "Vietnamese"
        case .chinese:            
            return "Chinese"
        case .traditionalChinese: 
            return "Traditional Chinese"

        }
    }
}

public struct LanguageTranslationResponse: PlaygroundSerializable {
    public var translation: String? = nil
    public var wordCount: Int = 0
    public var characterCount: Int = 0
    public var error: TJBotError? = nil
    
    public init(response: AnyObject) {
        guard let dict = response as? Dictionary<String, AnyObject> else { return }
        
        if let error = dict["error"] as? String {
            self.error = TJBotError.tjbotInternalError(error)
            return
        }
        
        guard let translations = dict["translations"] as? [AnyObject] else {
            self.error = TJBotError.unableToDeserializeTJBotResponse
            return
        }
        
        for translationDict in translations {
            guard let translation = translationDict["translation"] as? String else {
                self.error = TJBotError.unableToDeserializeTJBotResponse
                return
            }
            
            // just take the first translation found
            self.translation = translation
            break
        }
        
        if let wordCount = dict["word_count"] as? Int {
            self.wordCount = wordCount
        }
        
        if let characterCount = dict["character_count"] as? Int {
            self.characterCount = characterCount
        }
    }
    
    init(error: TJBotError) {
        self.error = error
    }
}

extension LanguageTranslationResponse: JSONRepresentable {
    func asJSONObject() -> [String : Any] {
        if let error = self.error {
            return ["error": error.description]
        } else {
            return [
                "translation": self.translation!,
                "wordCount": self.wordCount,
                "characterCount": self.characterCount
            ]
        }
    }
}

public struct LanguageIdentification {
    public var language: TJTranslationLanguage = .unknown
    public var confidence: Double = 1.0
    
    init(language: TJTranslationLanguage, confidence: Double) {
        self.language = language
        self.confidence = confidence
    }
    
    init(response: AnyObject) {
        guard let dict = response as? Dictionary<String, AnyObject> else { return }
        if let languageName = dict["language"] as? String {
            if let language = TJTranslationLanguage(rawValue: languageName) {
                self.language = language
            }
        }
        if let confidence = dict["confidence"] as? Double {
            self.confidence = confidence
        }
    }
}

extension LanguageIdentification: JSONRepresentable {
    func asJSONObject() -> [String : Any] {
        return [
            "language": self.language.rawValue,
            "confidence": self.confidence
        ]
    }
}

extension LanguageIdentification {
    static func languages(from playgroundValue: PlaygroundValue) -> [LanguageIdentification] {
        var languages: [LanguageIdentification] = []
        
        if case let .array(items) = playgroundValue {
            for item in items {
                if case let .data(data) = item {
                    do {
                        let obj = try JSONSerialization.jsonObject(with: data, options: .init(rawValue: 0)) as AnyObject
                        let identification = LanguageIdentification(response: obj)
                        languages.append(identification)
                    } catch {
                    }
                }
            }
        }
        
        return languages
    }
}

extension Sequence where Iterator.Element == LanguageIdentification {
    public var highestConfidenceLanguage: TJTranslationLanguage {
        var highest = LanguageIdentification(language: .unknown, confidence: 0.0)
        
        for identification in self {
            if identification.confidence > highest.confidence {
                highest = identification
            }
        }
        
        return highest.language
    }
}

public struct LanguageIdentificationResponse: PlaygroundSerializable {
    public var languages: [LanguageIdentification] = []
    public var error: TJBotError? = nil
    
    public init() {}
    
    public init(response: AnyObject) {
        guard let dict = response as? Dictionary<String, AnyObject> else { return }
        
        if let error = dict["error"] as? String {
            self.error = TJBotError.tjbotInternalError(error)
            return
        }
        
        guard let languages = dict["languages"] as? [AnyObject] else {
            self.error = TJBotError.unableToDeserializeTJBotResponse
            return
        }
        
        for candidate in languages {
            guard let languageName = candidate["language"] as? String else {
                self.error = TJBotError.unableToDeserializeTJBotResponse
                return
            }
            
            guard let confidence = candidate["confidence"] as? Double else {
                self.error = TJBotError.unableToDeserializeTJBotResponse
                return
            }
            
            // convert languageName to TJTranslationLanguage
            if let language = TJTranslationLanguage(rawValue: languageName) {
                let identification = LanguageIdentification(language: language, confidence: confidence)
                self.languages.append(identification)
            } else {
                let identification = LanguageIdentification(language: .unknown, confidence: confidence)
                self.languages.append(identification)
            }

        }
    }
    
    init(error: TJBotError) {
        self.error = error
    }
}

extension LanguageIdentificationResponse: JSONRepresentable {
    func asJSONObject() -> [String : Any] {
        if let error = self.error {
            return ["error": error.description]
        } else {
            let jsonObjects = self.languages.map { $0.asJSONObject() }
            return [
                "languages": jsonObjects
            ]
        }
    }
}
