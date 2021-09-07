//
//  SimpleQRSessionManager.swift
//  
//
//  Created by Pedro Farina on 07/09/21.
//

#if canImport(AVFoundation)
import AVFoundation

open class SimpleQRSessionManager: NSObject, AVCaptureMetadataOutputObjectsDelegate {
    internal private(set) var captureSession: AVCaptureSession = AVCaptureSession()
    internal weak var delegate: SimpleQROutputDelegate?
    private var contentFound: Set<String> = []
    
    open func setupSession() throws {
        contentFound = []
        captureSession.beginConfiguration()
        
        guard let device = AVCaptureDevice.default(for: .video) else {
            throw NSError(domain: "Não foi possível identificar o dispositivo.", code: Int(errSSLBadConfiguration))
        }
        
        let videoInput = try AVCaptureDeviceInput(device: device)
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        } else {
            throw NSError(domain: "Não foi possível configurar a sessão de captura.", code: Int(errSSLBadConfiguration))
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            throw NSError(domain: "Não foi possível ler o output da sessão.", code: Int(errSSLBadConfiguration))
        }
        
        captureSession.commitConfiguration()
    }
    
    public func startRunning() {
        if !captureSession.isRunning {
            captureSession.startRunning()
        }
    }
    public func stopRunning() {
        if captureSession.isRunning {
            captureSession.stopRunning()
        }
    }
    
    open func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first,
           let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
           let stringValue = readableObject.stringValue,
           !contentFound.contains(stringValue) {
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            contentFound.insert(stringValue)
            delegate?.qrCodeFound(stringValue)
        }
    }
}
#endif
