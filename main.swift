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

func detectText(fileName : URL) -> [CIFeature]? {
    if let ciImage = CIImage(contentsOf: fileName){
        guard let img = convertCIImageToCGImage(inputImage: ciImage) else { return nil}
      
        let requestHandler = VNImageRequestHandler(cgImage: img)

        // Create a new request to recognize text.
        let request = VNRecognizeTextRequest(completionHandler: recognizeTextHandler)
        request.recognitionLanguages = ["chi_sim", "eng"]

        do {
            // Perform the text-recognition request.
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
}
    return nil
}

func supportedLanguages() {
    let request = VNRecognizeTextRequest()

    do {
        let supportedLanguages = try request.supportedRecognitionLanguages(for: .accurate, revision: VNRecognizeTextRequest.currentRevision)
        print("Supported languages: \(supportedLanguages)")
    } catch {
        print("Error getting supported languages: \(error)")
    }
}

do {
    supportedLanguages()
    if CommandLine.argc < 2 {
        print("Please provide an image path.")
    } else {
        // 获取图片路径
        let inputURL = URL(fileURLWithPath: CommandLine.arguments[1])
        if let features = detectText(fileName : inputURL), !features.isEmpty{}
    }
} catch {
    // handle parsing error
}

exit(EXIT_SUCCESS)
