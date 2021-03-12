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
    private var cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)!
    private let videoOutput = AVCaptureVideoDataOutput()
    private var settingView: UIView!
    private var settingViewTitleLabel: UILabel!
    private var closeSettingButton: UIButton!
    private var toggleCameraButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let cameraInput = try! AVCaptureDeviceInput(device: self.cameraDevice)
        self.captureSession.addInput(cameraInput)
        self.view.layer.addSublayer(self.previewLayer)
        self.captureSession.startRunning()
        self.videoOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]
        self.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "my.image.handling.queue"))
        self.captureSession.addOutput(self.videoOutput)
        
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        self.view.addGestureRecognizer(longPressRecognizer)
        
        self.settingView = UIView(frame: UIScreen.main.bounds)
        self.settingView.backgroundColor = .white
        
        self.settingViewTitleLabel = UILabel(frame: CGRect(x: 10, y: 20, width: self.view.frame.width / 4, height: self.view.frame.height / 24))
        self.settingViewTitleLabel.text = "設定"
        self.settingViewTitleLabel.textColor = .black
        self.settingViewTitleLabel.font = .systemFont(ofSize: self.view.frame.height / 24)
        self.settingViewTitleLabel.adjustsFontSizeToFitWidth = true
        self.settingView.addSubview(self.settingViewTitleLabel)
        
        self.toggleCameraButton = UIButton(frame: CGRect(x: (self.view.frame.width / 2) - (self.view.frame.width / 3) / 2, y: 80, width: self.view.frame.width / 3, height: self.view.frame.height / 24))
        self.toggleCameraButton.setTitle("カメラ切り替え", for: .normal)
        self.toggleCameraButton.backgroundColor = .black
        self.toggleCameraButton.setTitleColor(.white, for: .normal)
        self.toggleCameraButton.addTarget(self, action: #selector(toggleCameraButtonPushed), for: .touchUpInside)
        self.settingView.addSubview(toggleCameraButton)
        
        self.closeSettingButton = UIButton(frame: CGRect(x: (self.view.frame.width - (self.view.frame.width / 8)) - 5, y: 20, width: self.view.frame.width / 8, height: self.view.frame.height / 32))
        self.closeSettingButton.setTitle("閉じる", for: .normal)
        self.closeSettingButton.backgroundColor = .black
        self.closeSettingButton.setTitleColor(.white, for: .normal)
        self.closeSettingButton.addTarget(self, action: #selector(closeSettingButtonPushed), for: .touchUpInside)
        self.settingView.addSubview(self.closeSettingButton)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewLayer.frame = self.view.bounds
    }
    
    @objc func longPressed(sender: UILongPressGestureRecognizer) {
        self.view.addSubview(self.settingView)
    }
    
    @objc func closeSettingButtonPushed(sender: UIButton) {
        self.settingView.removeFromSuperview()
    }
    
    @objc func toggleCameraButtonPushed(sender: UIButton) {
        if (self.cameraDevice.position == AVCaptureDevice.Position.back) {
            self.cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .front)!
        } else {
            self.cameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)!
        }
        let cameraInput = try! AVCaptureDeviceInput(device: self.cameraDevice)
        self.captureSession.removeInput(self.captureSession.inputs[0])
        self.captureSession.addInput(cameraInput)
    }
}

