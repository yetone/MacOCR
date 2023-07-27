//
//  main.swift
//  OCR
//
//  Created by Marcus Schappi on 17/5/21, 11:36 am
//

import Foundation
import CoreImage
import Cocoa
import Vision


var joiner = " "

func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
    let context = CIContext(options: nil)
    if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
        return cgImage
    }
    return nil
}

func recognizeTextHandler(request: VNRequest, error: Error?) {
    guard let observations =
            request.results as? [VNRecognizedTextObservation] else {
        return
    }
    let recognizedStrings = observations.compactMap { observation in
        // Return the string of the top VNRecognizedText instance.
        return observation.topCandidates(1).first?.string
    }
    
    // Process the recognized strings.
    let joined = recognizedStrings.joined(separator: joiner)
    print(joined)
    
    let pasteboard = NSPasteboard.general
    pasteboard.declareTypes([.string], owner: nil)
    pasteboard.setString(joined, forType: .string)
    
}

func detectText(fileName : URL, lang : String) -> [CIFeature]? {
    if let ciImage = CIImage(contentsOf: fileName){
        guard let img = convertCIImageToCGImage(inputImage: ciImage) else { return nil}
      
        let requestHandler = VNImageRequestHandler(cgImage: img)

        let request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        request.recognitionLevel = .accurate
        if (lang == "auto"){
            request.recognitionLanguages = ["zh-Hans", "zh-Hant", "en-US", "ja-JP", "ko-KR", "fr-FR", "es-ES", "ru-RU", "de-DE", "it-IT", "tr-TR", "pt-PT", "vi-VN", "id-ID", "th-TH", "ms-MY", "ar-SA", "hi-IN" ]
        }else{
            request.recognitionLanguages = [lang]
        }
        request.usesLanguageCorrection = true

        do {
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
}
    return nil
}

if CommandLine.argc < 2 {
    print("Please provide an image path.")
} else {
    let inputURL = URL(fileURLWithPath: CommandLine.arguments[1])
    let language = CommandLine.arguments[2]
    if let features = detectText(fileName : inputURL, lang : String), !features.isEmpty{}
}

exit(EXIT_SUCCESS)
