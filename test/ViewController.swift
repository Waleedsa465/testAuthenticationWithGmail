//
//  ViewController.swift
//  test
//
//  Created by MacBook Pro on 02/01/2024.
//

import UIKit
import FirebaseAuth
import AVKit
import AVFoundation

class ViewController: UIViewController, UITextFieldDelegate {

    var videoPlayer: AVPlayer?
    var videoPlayerLayer: AVPlayerLayer?
    var iconClick = false
    let imageIcon = UIImageView()

    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passTxt: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var activitiyIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageIconClose()
        setUpElements()
        textFieldDelegate()
        errorLabel.alpha = 0
        activitiyIndicator.isHidden = true
        activitiyIndicator.layer.shadowOpacity = 10
        activitiyIndicator.layer.cornerRadius = 10

        if let userDefault = UserDefaults.standard.value(forKey: strLoginKey) as? Bool {
            if userDefault {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabBarVC") as! HomeTabBarVC
                self.navigationController?.setViewControllers([vc], animated: true)
                print("Already Login successfully")
            } else {
                print("Please sign In again")
            }
        }
    }
    
    func imageIconClose(){
        imageIcon.image = UIImage(named: "close_eye")
        let contentView = UIView()
        contentView.addSubview(imageIcon)
        
        contentView.frame = CGRect(x: 0, y: 0, width: UIImage(named: "close_eye")!.size.width, height: UIImage(named: "close_eye")!.size.height)
        
        imageIcon.frame = CGRect(x: -10, y: 0, width: UIImage(named: "close_eye")!.size.width, height: UIImage(named: "close_eye")!.size.height)
        
        
        passTxt.rightView = contentView
        passTxt.rightViewMode = .always
        
//        further addition here for pass show
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imageIcon.isUserInteractionEnabled = true
        imageIcon.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func imageTapped(tapGestureRecognizer:UITapGestureRecognizer){
        
        let tappedImage = tapGestureRecognizer.view as! UIImageView
        if iconClick{
            
            iconClick = false
            tappedImage.image = UIImage(named: "open_eye")
            passTxt.isSecureTextEntry = false
        }
        else{
            iconClick = true
            tappedImage.image = UIImage(named: "close_eye")
            passTxt.isSecureTextEntry = true
        }
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
}
