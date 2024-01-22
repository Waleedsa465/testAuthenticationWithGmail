//
//  RegistrationVC.swift
//  test
//
//  Created by MacBook Pro on 02/01/2024.
//

import UIKit
import FirebaseFirestore
import FirebaseAuth
import FirebaseDatabase

class RegistrationVC: UIViewController,UITextFieldDelegate {
    
    var ref: DatabaseReference!
    var iconClick = false
    let imageIcon = UIImageView()
    
    @IBOutlet weak var firstNameTxt: UITextField!
    @IBOutlet weak var lastNameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passTxt: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageIconClose()
        errorLabel.alpha = 0
        activityIndicator.isHidden = true
        activityIndicator.layer.shadowOpacity = 10
        activityIndicator.layer.cornerRadius = 10
        textFieldDelegate()
        Utilities.styleTextField(firstNameTxt)
        Utilities.styleTextField(lastNameTxt)
        Utilities.styleTextField(emailTxt)
        Utilities.styleTextField(passTxt)
        ref = Database.database().reference()
        
        // Do any additional setup after loading the view.
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
        firstNameTxt.delegate = self
        lastNameTxt.delegate = self
        emailTxt.delegate = self
        passTxt.delegate = self
    }
    
    
    func validateFields() -> String? {
        
        // Check that all fields are filled in
        if firstNameTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {

            return "Please fill in all fields."
        }
        
        // Check if the password is secure
        let cleanedPassword = passTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utilities.isPasswordValid(cleanedPassword) == false {
            // Password isn't secure enough
            return "Please make sure your password is at least 8 characters, contains a special character and a number."
        }
        
        return nil
    }
    func showError(_ message:String) {
        
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        switch textField{
            
        case firstNameTxt :
            lastNameTxt.becomeFirstResponder()
        case lastNameTxt :
            emailTxt.becomeFirstResponder()
        case emailTxt:
            passTxt.becomeFirstResponder()
        case passTxt:
            passTxt.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }

    
    @IBAction func registrationBtn(_ sender: Any) {
//        activityIndicator.isHidden = false
//        activityIndicator.startAnimating()
        
        let error = validateFields()
        if error != nil {
            showError(error!)
        } else {
            let firstName = firstNameTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                if err != nil {
                    self.showError("Error creating user")
                } else {
                    Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                        if let error = error {
                            print("Error sending verification email: \(error.localizedDescription)")
                            self.showError(error.localizedDescription)
                        } else {
                            print("Verification email sent successfully.")
                            self.showError("Verification email sent successfully.")
                        }
                    })
                    
                    let databaseRef = Database.database().reference()
                    
                    let userData = ["firstname": firstName,
                                    "lastname": lastName,
                                    "Email": email,
                                    "Password": password,
                                    "uid": result!.user.uid
                    ]
                    
                    databaseRef.child("users").child(result!.user.uid).setValue(userData) { [weak self] (error, ref) in
                        guard let self = self else { return }
                        if let error = error {
                            print("Error saving user data to Realtime Database: \(error.localizedDescription)")
                        }

                    }
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                    let nav = UINavigationController(rootViewController: vc)
                    print("Successfully create user")
                    self.view.window?.rootViewController = nav
                }
            }
        }
    }

}
