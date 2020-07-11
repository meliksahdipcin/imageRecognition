//
//  ViewController.swift
//  imageRecognition
//
//  Created by Melikşah on 23.08.2019.
//  Copyright © 2019 Dipcin. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var resultsLabel: UILabel!
    
    var chosenImages = CIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        resultsLabel.text = ""
    }

    @IBAction func changeButtonClicked(_ sender: Any) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imageView.image = info[.originalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        if let ciImage = CIImage(image: imageView.image!) {
            chosenImages = ciImage
            
        }
        
        recognizeImage(image: chosenImages)
        
    }
    
    func recognizeImage(image: CIImage) {
        
        resultsLabel.text = "Finding..."
        
        //1) Request
        //2) Handler
        
        if let model = try? VNCoreMLModel(for: MobileNetV2().model) {
            
            let request = VNCoreMLRequest(model: model) { (vnrequest, error) in
                
                if let results = vnrequest.results as? [VNClassificationObservation] {
                    
                    if results.count > 0 {
                        
                        let topResult = results.first
                        
                        DispatchQueue.main.async {
                            
                            let confidenceLevel = (topResult?.confidence ?? 0) * 100
                            
                            let rounded = Int(confidenceLevel * 100) / 100
                            
                            self.resultsLabel.text = "\(rounded)% it's \(topResult!.identifier)"
                        }
                    }
                }
            }
            
            let handler = VNImageRequestHandler(ciImage: image)
            DispatchQueue.global(qos: .userInteractive).async {
                do {
                    try handler.perform([request])
                } catch {
                    print("error")
                }
            }
        }
    }
}
