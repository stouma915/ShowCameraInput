//
//  ViewController.swift
//  ShowCameraInput
//
//  Created by stouma915 on R 3/03/12.
//

import AVFoundation
import UIKit

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    private var cameraDevice: AVCaptureDevice!
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let preview = AVCaptureVideoPreviewLayer(session: self.captureSession)
        preview.videoGravity = AVLayerVideoGravity.resizeAspectFill
        return preview
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if (UserDefaults.standard.bool(forKey: "use_rear_camera")) {
            self.cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)!
        } else {
            self.cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)!
        }
        let cameraInput = try! AVCaptureDeviceInput(device: cameraDevice)
        self.captureSession.addInput(cameraInput)
        self.view.layer.addSublayer(self.previewLayer)
        self.captureSession.startRunning()
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "my.image.handling.queue"))
        self.captureSession.addOutput(videoOutput)
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let screenSize = self.view.bounds.size
        if let touchPoint = touches.first {
            let x = touchPoint.location(in: self.view).y / screenSize.height
            let y = 1.0 - touchPoint.location(in: self.view).x / screenSize.width
            let focusPoint = CGPoint(x: x, y: y)
            try! self.cameraDevice.lockForConfiguration()
            self.cameraDevice.focusPointOfInterest = focusPoint
            self.cameraDevice.focusMode = .autoFocus
            self.cameraDevice.exposurePointOfInterest = focusPoint
            self.cameraDevice.exposureMode = AVCaptureDevice.ExposureMode.continuousAutoExposure
            self.cameraDevice.unlockForConfiguration()
        }
    }
}

