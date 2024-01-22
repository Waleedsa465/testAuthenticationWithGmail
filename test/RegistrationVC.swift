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
    
    @IBOutlet weak var firstNameTxt: UITextField!
    @IBOutlet weak var lastNameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passTxt: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.alpha = 0
        textFieldDelegate()
        Utilities.styleTextField(firstNameTxt)
        Utilities.styleTextField(lastNameTxt)
        Utilities.styleTextField(emailTxt)
        Utilities.styleTextField(passTxt)
        
        
        // Do any additional setup after loading the view.
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
        
        let error = validateFields()
        if error != nil {
            showError(error!)
        }
        else {
            let firstName = firstNameTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            
            // Create the user
            
            
            
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                
                // Check for errors
                if err != nil {
                    
                    // There was an error creating the user
                    self.showError("Error creating user")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 5){
                        self.errorLabel.text = ""
                    }

                }
                else {
                    
                    
                    
                    let db = Firestore.firestore()
                    db.collection("users").addDocument(data: ["firstname":firstName, "lastname":lastName, "uid": result!.user.uid ]) { (error) in
                        
                        if error != nil {
                            // Show error message
                            self.showError("Error saving user data")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5){
                                self.errorLabel.text = ""
                            }

                        }
                    }
//                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeTabBarVC") as! HomeTabBarVC
//                    UserDefaults.standard.set(email, forKey: strLoginKey)
//                    self.navigationController?.isNavigationBarHidden = true
//                    self.navigationController?.pushViewController(vc, animated: true)
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                    let nav = UINavigationController(rootViewController: vc)
            //        nav.navigationBar.isHidden = true
                    self.view.window?.rootViewController = nav
                    
                }
            }
        }
    }
}
