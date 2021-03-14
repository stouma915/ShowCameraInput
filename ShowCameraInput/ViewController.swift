//
//  ViewController.swift
//  ShowCameraInput
//
//  Created by stouma915 on R 3/03/12.
//

import AVFoundation
import UIKit

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer(session: self.captureSession)
        preview.videoGravity = AVLayerVideoGravity.resizeAspectFill
        return preview
    }()
    private let videoOutput = AVCaptureVideoDataOutput()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        var cameraDevice: AVCaptureDevice!
        if (UserDefaults.standard.bool(forKey: "use_rear_camera")) {
            cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)!
        } else {
            cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)!
        }
        let cameraInput = try! AVCaptureDeviceInput(device: cameraDevice)
        self.captureSession.addInput(cameraInput)
        self.view.layer.addSublayer(self.previewLayer)
        self.captureSession.startRunning()
        self.videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "my.image.handling.queue"))
        self.captureSession.addOutput(self.videoOutput)
        
        let flashlightBrightness = UserDefaults.standard.integer(forKey: "flashlight_brightness")
        if (flashlightBrightness != 0) {
            try! cameraDevice.lockForConfiguration()
            try! cameraDevice.setTorchModeOn(level: Float(Double(flashlightBrightness) / 10.0))
            cameraDevice.torchMode = .on
            cameraDevice.unlockForConfiguration()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewLayer.frame = self.view.bounds
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

