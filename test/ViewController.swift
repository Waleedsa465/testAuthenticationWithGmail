//
//  ViewController.swift
//  test
//
//  Created by MacBook Pro on 02/01/2024.
//

import UIKit
import FirebaseAuth
import Lottie
import Reachability


class ViewController: UIViewController, UITextFieldDelegate {

    var reachability: Reachability!
    var alertShown = false
    
    
    @IBOutlet weak var animationView: LottieAnimationView!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passTxt: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var activitiyIndicator: UIActivityIndicatorView!
    @IBOutlet weak var showPasswordBtN: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let userDefault = UserDefaults.standard.value(forKey: strLoginKey) as? Bool {
            if userDefault {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabBarVC") as! HomeTabBarVC
                self.navigationController?.setViewControllers([vc], animated: true)
                print("Already Login successfully")
            } else {
                print("Please sign In again")
            }
        }
        
        setUpElements()
        textFieldDelegate()
        errorLabel.alpha = 0
        activitiyIndicator.isHidden = true
        animationView.layer.cornerRadius = 20
        activitiyIndicator.layer.shadowOpacity = 10
        activitiyIndicator.layer.cornerRadius = 10
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.2
        animationView.play()
        showPasswordBtN.setTitle("", for: .normal)

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
                showAlert(message: "No internet connection. Please check your network settings.")
            }
        }

        func showAlert(message: String) {
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

    
    func textFieldDelegate(){
        emailTxt.delegate = self
        passTxt.delegate = self
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case emailTxt:
            passTxt.becomeFirstResponder()
        case passTxt:
            passTxt.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }


    @IBAction func loginBtn(_ sender: Any) {
        
        activitiyIndicator.isHidden = false
        activitiyIndicator.startAnimating()
        let email = emailTxt.text!
        let password = passTxt.text!

        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            guard let self = self else { return }
            if let error = error {
                print("Error while signIn")
                activitiyIndicator.isHidden = false
                self.errorLabel.text = error.localizedDescription
                self.errorLabel.alpha = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 4){
                    self.errorLabel.text = ""
                    self.activitiyIndicator.stopAnimating()
                    self.activitiyIndicator.isHidden = true
                }
            } else {
                // Check if the user's email is verified
                activitiyIndicator.startAnimating()
                if let user = Auth.auth().currentUser, user.isEmailVerified {
                    // Save the login status
                    UserDefaults.standard.set(email, forKey: strLoginKey)

                    // Navigate to the home screen or perform other actions
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4){
                        self.activitiyIndicator.stopAnimating()
                        self.activitiyIndicator.isHidden = true
                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabBarVC") as! HomeTabBarVC
                        self.navigationController?.setViewControllers([vc], animated: true)
                        self.navigationController?.isNavigationBarHidden = true
                        print("Login successfully")
                    }

                } else {
                    // User's email is not verified, show a message or initiate the verification process
                    self.errorLabel.text = "Please verify your email before logging in."
                    self.errorLabel.alpha = 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4){
                        self.errorLabel.text = ""
                    }

                    // You can initiate the email verification process here
                    Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                        if let error = error {
                            print("Error sending verification email: \(error.localizedDescription)")
                            self.errorLabel.text = error.localizedDescription
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                                self.errorLabel.text = ""
                                self.activitiyIndicator.stopAnimating()
                                self.activitiyIndicator.isHidden = true
                                
                            }
                        } else {
                            print("Verification email sent successfully.")
                            self.errorLabel.text = "Verification email sent successfully."
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                                self.errorLabel.text = ""
                                self.activitiyIndicator.stopAnimating()
                                self.activitiyIndicator.isHidden = true
                            }
                        }
                    })
                }
            }
        }
    }

    @IBAction func signupBtn(_ sender: Any) {

    }

    func setUpElements() {
        Utilities.styleFilledButton(loginButton)
        Utilities.styleHollowButton(signUpButton)
        Utilities.styleTextField(emailTxt)
        Utilities.styleTextField(passTxt)
    }
    
    @IBAction func forgetPass(_ sender: Any) {
        activitiyIndicator.isHidden = false
        activitiyIndicator.startAnimating()
        let email = emailTxt.text!
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if error != nil{
                print("Error while sending reset password")
                self.errorLabel.text = error?.localizedDescription
                self.errorLabel.alpha = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                    self.errorLabel.text = ""
                    self.activitiyIndicator.stopAnimating()
                    self.activitiyIndicator.isHidden = true
                }
            }else{
                print("Successfully send reset password \(String(describing: error?.localizedDescription))")
                self.errorLabel.text = "Successfully send reset password"
                self.errorLabel.alpha = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                    self.activitiyIndicator.stopAnimating()
                    self.activitiyIndicator.isHidden = true
                    self.errorLabel.text = ""
                }
            }
        }
    }
    
    deinit {
            reachability.stopNotifier()
            NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: nil)
        }
    
    
    @IBAction func showPassBtn(_ sender: Any) {
        passTxt.isSecureTextEntry.toggle()
        let imageName = passTxt.isSecureTextEntry ? "close_eye" : "open_eye"
        showPasswordBtN.setImage(UIImage(named: imageName), for: .normal)
    }
    
    
}
