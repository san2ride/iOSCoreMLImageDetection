//
//  ViewController.swift
//  ImageDetectionLiveStream
//
//  Created by Jason Sanchez on 6/27/18.
//  Copyright © 2018 Jason Sanchez. All rights reserved.
//

import UIKit
import AVFoundation
import CoreML
import Vision

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textView: UITextView!
    
    private let incepetionModel = Inceptionv3()
    private var requests = [VNCoreMLRequest]()
    
    let session = AVCaptureSession()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startLiveVideo()
        createImageRequest()
    }
    
    private func createImageRequest() {
        guard let model = try? VNCoreMLModel(for: self.incepetionModel.model)
            else {
                fatalError("Problem creating a core ml model")
        }
        
        let request = VNCoreMLRequest(model: model) { request, error in
            if error != nil {
                return
            }
            
            guard let observations = request.results as? [VNClassificationObservation]
                else {
                    return
            }
            
            let classifications = observations.map {
                observation in "\(observation.identifier) \(observation.confidence * 100.0)"
            }
            
            DispatchQueue.main.async {
                self.textView.text = classifications.joined(separator: "\n")
            }
            
            
        }
    }
    
    private func startLiveVideo() {
        session.sessionPreset = AVCaptureSession.Preset.photo
        let captureDevice = AVCaptureDevice.default(for: .video)
        
        let deviceInput = try! AVCaptureDeviceInput(device: captureDevice!)
        let deviceOutput = AVCaptureVideoDataOutput()
        
        deviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as
            String: Int(kCVPixelFormatType_32BGRA)]
        deviceOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default))
        
        session.addInput(deviceInput)
        session.addOutput(deviceOutput)
        
        let imageLayer = AVCaptureVideoPreviewLayer(session: session)
        imageLayer.frame = imageView.bounds
        imageView.layer.addSublayer(imageLayer)
        
        session.startRunning()
    }


}

