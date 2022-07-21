//
//  ViewController.swift
//  ZScanner
//
//  Created by Nagmani Singh on 21/07/22.
//

import UIKit
import ZQRScannerLib
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet var zqrScannerView : ZQRScannerView!
    @IBOutlet var flashBtn: FlashButton!

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupQRScanner()
    }

    private func setupQRScanner() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupQRScannerView()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    DispatchQueue.main.async { [weak self] in
                        self?.setupQRScannerView()
                    }
                }
            }
        default:
            showAlert()
        }
    }

    private func setupQRScannerView() {
        zqrScannerView.configure(delegate: self, input: .init(isBlurEffectEnabled: true))
        zqrScannerView.startRunning()
    }

    private func showAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            let alert = UIAlertController(title: "Error", message: "Camera is required to use in this application", preferredStyle: .alert)
            alert.addAction(.init(title: "OK", style: .default))
            self?.present(alert, animated: true)
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        zqrScannerView.stopRunning()
    }

    @IBAction func flashCLicked(_ sender: UIButton){
        zqrScannerView.setTorchActive(isOn: !sender.isSelected)
    }
}

// MARK: - QRScannerViewDelegate
extension ViewController: ZQRScannerViewDelegate {
    func qrScannerView(_ qrScannerView: ZQRScannerView, didFailure error: ZQRScannerError) {
        print(error.localizedDescription)
    }

    func qrScannerView(_ qrScannerView: ZQRScannerView, didSuccess code: String) {
        if let url = URL(string: code), (url.scheme == "http" || url.scheme == "https") {
            openWeb(url: url)
        } else {
            showAlert(code: code)
        }
    }

    func qrScannerView(_ qrScannerView: ZQRScannerView, didChangeTorchActive isOn: Bool) {
        flashBtn.isSelected = isOn
    }
}

// MARK: - Private
private extension ViewController {
    func openWeb(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: { [weak self] _ in
            self?.zqrScannerView.rescan()
        })
    }

    func showAlert(code: String) {
        let alertController = UIAlertController(title: code, message: nil, preferredStyle: .actionSheet)
        let copyAction = UIAlertAction(title: "Copy", style: .default) { [weak self] _ in
            UIPasteboard.general.string = code
            self?.zqrScannerView.rescan()
        }
        alertController.addAction(copyAction)
        let searchWebAction = UIAlertAction(title: "Search Web", style: .default) { [weak self] _ in
            if let url = URL(string: "https://www.google.com/search?q=\(code)"){
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
           //UIApplication.shared.open(URL(string: "https://www.google.com/search?q=\(code)")!, options: [:], completionHandler: nil)
            self?.zqrScannerView.rescan()
        }
        alertController.addAction(searchWebAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: { [weak self] _ in
            self?.zqrScannerView.rescan()
        })
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}

