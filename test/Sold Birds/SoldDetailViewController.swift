//
//  SoldDetailViewController.swift
//  BirdsApp
//
//  Created by MacBook Pro on 20/12/2023.
//

import UIKit
import Kingfisher
import Reachability

class SoldDetailViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var buyerName: UILabel!
    @IBOutlet weak var buyerPhoneNumber: UILabel!
    @IBOutlet weak var certificateNo: UILabel!
    @IBOutlet weak var birdSpecieLbl: UILabel!
    @IBOutlet weak var birdIdLBL: UILabel!
    @IBOutlet weak var ownerName: UILabel!
    @IBOutlet weak var sampleType: UILabel!
    @IBOutlet weak var collectionLabel: UILabel!
    @IBOutlet weak var sexDetermination: UILabel!
    @IBOutlet weak var accuracyLbl: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var reachability: Reachability!
    var alertShown = false
    var imgView = ""
    var soldData: SoldBird!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.layer.cornerRadius = 20
        activityIndicator.hidesWhenStopped = true
        allTxtLabel()
        imgView = self.soldData.uploadCurrentImage
        
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
    
    func allTxtLabel(){
        buyerName.text = ("Buyer Name :  \(self.soldData.buyerName)")
        buyerPhoneNumber.text = ("PH :  \(self.soldData.buyerPhoneNumber)")
        certificateNo.text = ("Certificate :  \(self.soldData.certificateNo)")
        birdSpecieLbl.text = ("Bird Specie :  \(self.soldData.birdSpecie)")
        birdIdLBL.text = ("Bird Id :  \(self.soldData.birdID)")
        ownerName.text = ("Owner Name :  \(self.soldData.ownerName)")
        sampleType.text = ("Sample Type :  \(self.soldData.sampleType)")
        collectionLabel.text = ("Collection :  \(self.soldData.collection)")
        sexDetermination.text = ("Sex Determination :  \(self.soldData.sexDetermination)")
        accuracyLbl.text = ("Accuracy :  \(self.soldData.accuracy)")
    }
    
    
    @IBAction func captureScreenshotTapped(_ sender: UIButton) {
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
