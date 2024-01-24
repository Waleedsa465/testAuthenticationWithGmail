//
//  ExpiredBirdsDetailsVC.swift
//  BirdsApp
//
//  Created by MacBook Pro on 29/12/2023.
//

import UIKit
import Kingfisher
import Reachability

class ExpiredBirdsDetailsVC: UIViewController {
    
    var imgView = ""
    var expireDetail : ExpiredBird!
    var reachability: Reachability!
    var alertShown = false
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var certificateNo: UILabel!
    @IBOutlet weak var birdSpecie: UILabel!
    @IBOutlet weak var birdID: UILabel!
    @IBOutlet weak var ownerName: UILabel!
    @IBOutlet weak var sampleType: UILabel!
    @IBOutlet weak var collectionLbl: UILabel!
    @IBOutlet weak var sexDetermination: UILabel!
    @IBOutlet weak var accuracyLbl: UILabel!
    @IBOutlet weak var expireDate: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(true, forKey: strLoginKey)
        lblForAllText()
        activityIndicator.hidesWhenStopped = true
        
        let placeholderImage = UIImage(named: "placeholderImage")
        if let url = URL(string: imgView) {
            // Start the activity indicator
            activityIndicator.startAnimating()
            imageView.kf.setImage(with: url, placeholder: placeholderImage, completionHandler: { _ in
                // Stop the activity indicator after the image is loaded
                self.activityIndicator.stopAnimating()
            })
        }
        do {
            reachability = try Reachability()
        } catch {
            print("Unable to create Reachability")
        }
        
        // Observe Reachability Changes
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged), name: .reachabilityChanged, object: reachability)
        
        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start Reachability notifier")
        }
    }
    
    @objc func reachabilityChanged(notification: Notification) {
        guard let reachability = notification.object as? Reachability else { return }
        
        if reachability.connection != .unavailable {
            print("Network is available")
            if alertShown {
                dismissAlert()
            }
        } else {
            print("Network is not available")
            showAlerts(message: "No internet connection. Please check your network settings.")
        }
        
    }
    
    func showAlerts(message: String) {
        if !alertShown {
            alertShown = true
            let alert = UIAlertController(title: "Network Unavailable", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] (_) in
                self?.dismissAlert()
            }))
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    func dismissAlert() {
        alertShown = false
        dismiss(animated: true, completion: nil)
        
    }
    
    func lblForAllText(){
        imageView.layer.cornerRadius = 20
        ownerName.text = ("Owner Name :  \(self.expireDetail.ownerName)")
        sampleType.text = ("Sample Type :  \(self.expireDetail.sampleType)")
        certificateNo.text = ("Certificate :  \(self.expireDetail.certificateNo)")
        birdID.text = ("Bird Id :  \(self.expireDetail.birdID)")
        birdSpecie.text = ("Bird Specie :  \(self.expireDetail.birdSpecie)")
        collectionLbl.text = ("Collection :  \(self.expireDetail.collection)")
        sexDetermination.text = ("Sex :  \(self.expireDetail.sexDetermination)")
        accuracyLbl.text = ("Accuracy :  \(self.expireDetail.accuracy)")
        expireDate.text = ("Expire Date : \(self.expireDetail.Sold_or_Expire)")
        imgView = self.expireDetail.uploadCurrentImage
    }
    
    @IBAction func downloadBTN(_ sender: Any) {
        
        // Capture the screenshot
        if let screenshot = captureScreenshot() {
            // Save or use the screenshot as needed
            // For example, you can save it to the photo library
            UIImageWriteToSavedPhotosAlbum(screenshot, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
    }
    
    func captureScreenshot() -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(view.bounds.size, false, 0.0)
        view.drawHierarchy(in: view.bounds, afterScreenUpdates: true)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return screenshot
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // Handle the error if saving the image failed
            print("Error saving image: \(error.localizedDescription)")
            let alert = UIAlertController(title: "Error", message: "Failed to save screenshot", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        } else {
            // Display an alert indicating that the screenshot has been saved successfully
            let alert = UIAlertController(title: "Success", message: "Screenshot saved to gallery", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
    }
    
    deinit {
            reachability.stopNotifier()
            NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
        }
}

