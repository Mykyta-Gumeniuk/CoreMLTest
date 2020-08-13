//
//  ViewController.swift
//  CoreMLTest
//
//  Created by Nik on 13.08.2020.
//  Copyright © 2020 Mykyta Gumeniuk. All rights reserved.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var ImageView: UIImageView!
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let userImage = info[.originalImage] as? UIImage {
            ImageView.image = userImage
            guard let ciImage = CIImage(image: userImage) else {
                fatalError("couldn't convert uiimage to CIImage")
            }
            analyzeImage(ciImage)
        }
        
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func analyzeImage(_ image: CIImage) {
        
        guard let model = try? VNCoreMLModel(for: SqueezeNet().model) else {
            fatalError("can't load ML model")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            guard let results = request.results as? [VNClassificationObservation],
                let topResult = results.first
                else {
                    fatalError("unexpected result type from VNCoreMLRequest")
            }
            
            DispatchQueue.main.async {
                self.navigationItem.title = topResult.identifier
                self.navigationController?.navigationBar.isTranslucent = false
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do {
            try handler.perform([request])
        }
        catch {
            print(error)
        }
    }
    
    
    @IBAction func photoButtonPressed(_ sender: UIBarButtonItem) {
        
        present(imagePicker, animated: true, completion: nil)
        
    }
    
}

