//
//  SimpleQRViewController.swift
//  
//
//  Created by Pedro Farina on 07/09/21.
//

#if canImport(UIKit)
import UIKit
import AVFoundation

public final class SimpleQRViewController: UIViewController {
    
    private let qrSessionManager: SimpleQRSessionManager = SimpleQRSessionManager()
    private lazy var previewLayer: AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: qrSessionManager.captureSession)
    internal var delegate: SimpleQROutputDelegate? {
        get {
            return qrSessionManager.delegate
        }
        set {
            qrSessionManager.delegate = newValue
        }
    }
    private var cameraView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    public private(set) lazy var dismissButton: UIButton = {
        let button = UIButton(frame: .zero)
        button.setBackgroundImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(dismissButtonTap(_:)), for: .touchUpInside)
        return button
    }()

    public override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    public override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }
    convenience required init?(coder: NSCoder) {
        self.init()
    }
    
    private lazy var constraints: [NSLayoutConstraint] = {
       [
        cameraView.topAnchor.constraint(equalTo: view.topAnchor),
        cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        
        dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15),
        dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15),
        dismissButton.heightAnchor.constraint(equalToConstant: 30),
        dismissButton.widthAnchor.constraint(equalToConstant: 30)
       ]
    }()
    
    public override func viewDidLoad() {
        view.backgroundColor = .black
        view.addSubview(cameraView)
        view.addSubview(dismissButton)
    }
    
    public override func viewDidLayoutSubviews() {
        NSLayoutConstraint.activate(constraints)
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        do {
            try qrSessionManager.setupSession()
            
            previewLayer.frame = cameraView.safeAreaLayoutGuide.layoutFrame
            previewLayer.videoGravity = .resizeAspectFill
            cameraView.layer.addSublayer(previewLayer)

            qrSessionManager.startRunning()
            delegate?.viewDidSetup()
        } catch {
            showError(error, shouldDismiss: true)
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        qrSessionManager.startRunning()
    }

    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        qrSessionManager.stopRunning()
    }
    
    @objc private func dismissButtonTap(_ sender: UIButton) {
        self.dismiss(animated: true)
    }
    
    private func showError(_ error: Error, shouldDismiss: Bool) {
        let alertController = UIAlertController(title: "Oops!", message: error.localizedDescription, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default) { [weak self] _ in
            if shouldDismiss {
                self?.dismiss(animated: true)
            }
        }
        alertController.addAction(action)
        present(alertController, animated: true)
    }
    
    public override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag) { [self] in
            self.delegate?.viewWasDismissed()
            completion?()
        }
    }
}
#endif
