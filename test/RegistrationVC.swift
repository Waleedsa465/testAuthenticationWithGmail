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
import FirebaseStorage
import Lottie

class RegistrationVC: UIViewController,UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var ref: DatabaseReference!
    var iconClick = false
    let imageIcon = UIImageView()
    var selectedImage: UIImage?
    @IBOutlet weak var animationView: LottieAnimationView!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var firstNameTxt: UITextField!
    @IBOutlet weak var lastNameTxt: UITextField!
    @IBOutlet weak var emailTxt: UITextField!
    @IBOutlet weak var passTxt: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageIconClose()
        animationView.isHidden = true
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 70
        errorLabel.alpha = 0
        activityIndicator.isHidden = true
        activityIndicator.layer.shadowOpacity = 10
        activityIndicator.layer.cornerRadius = 10
        textFieldDelegate()
        lotieAnimation()
        Utilities.styleTextField(firstNameTxt)
        Utilities.styleTextField(lastNameTxt)
        Utilities.styleTextField(emailTxt)
        Utilities.styleTextField(passTxt)
        ref = Database.database().reference()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)
        activityIndicator.hidesWhenStopped = true
        
        // Do any additional setup after loading the view.
    }
    
    @objc func imageViewTapped() {
        showImagePicker()
    }
    
    func lotieAnimation(){
        animationView.layer.cornerRadius = 20
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.animationSpeed = 0.5
        animationView.play()
    }
    
    func showImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self

        // Create an action sheet with options for choosing from the photo library or taking a photo with the camera
        let actionSheet = UIAlertController(title: "Select Image", message: nil, preferredStyle: .actionSheet)

        // Option to choose from photo library
        actionSheet.addAction(UIAlertAction(title: "Choose from Library", style: .default, handler: { [weak self] (_) in
            guard let self = self else { return }
            imagePicker.sourceType = .photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }))

        // Option to take a photo with the camera if available
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { [weak self] (_) in
                guard let self = self else { return }
                imagePicker.sourceType = .camera
                self.present(imagePicker, animated: true, completion: nil)
            }))
        }

        // Option to cancel
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // Present the action sheet
        present(actionSheet, animated: true, completion: nil)
    }

    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = pickedImage
            imageView.image = pickedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    func uploadImage(completion: @escaping (String?) -> Void) {
        guard let imageData = selectedImage?.jpegData(compressionQuality: 0.5) else {
            completion(nil)
            return
        }
        
        let imageName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
        
        storageRef.putData(imageData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Error uploading image to storage: \(error.localizedDescription)")
                completion(nil)
            } else {
                storageRef.downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        completion(nil)
                        return
                    }
                    let imageURLString = downloadURL.absoluteString
                    completion(imageURLString)
                }
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
        if firstNameTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            lastNameTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passTxt.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            
            return "Please fill in all fields."
        }
        let cleanedPassword = passTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedPassword) == false {
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
        activityIndicator.startAnimating()
        let error = validateFields()
        if error != nil {
            self.showError(error!)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                self.activityIndicator.stopAnimating()
                self.animationView.isHidden = true
                self.errorLabel.text = ""
            }
        } else {
            let firstName = firstNameTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let lastName = lastNameTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passTxt.text!.trimmingCharacters(in: .whitespacesAndNewlines)

            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
                if err != nil {
                    self.showError("Error creating user")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                        self.activityIndicator.stopAnimating()
                        self.errorLabel.text = ""
                    }
                    } else {
                        self.animationView.isHidden = false
                        self.lotieAnimation()
                        
                    Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                        if let error = error {
                            print("Error sending verification email: \(error.localizedDescription)")
                            self.showError(error.localizedDescription)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                                self.activityIndicator.stopAnimating()
                                self.errorLabel.text = ""
                            }
                        } else {
                            print("Verification email sent successfully.")
                            self.showError("Verification email sent successfully.")
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3){
                                self.activityIndicator.stopAnimating()
                                self.errorLabel.text = ""
                            }
                        }
                    })

                    let databaseRef = Database.database().reference()

                    self.uploadImage { imageUrl in
                        if let imageUrl = imageUrl {
                            // Save the imageUrl and other user data to the Realtime Database
                            let userData = [
                                "firstname": firstName,
                                "lastname": lastName,
                                "Email": email,
                                "Password": password,
                                "ProfileImageURL": imageUrl
                            ]

                            databaseRef.child("users").child(result!.user.uid).setValue(userData) { [weak self] (error, ref) in
                                guard self != nil else { return }
                                if let error = error {
                                    print("Error saving user data to Realtime Database: \(error.localizedDescription)")
                                } else {
                                    
                                    print("User data saved to Realtime Database successfully.")
                                    
                                }
                            }

                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                            let nav = UINavigationController(rootViewController: vc)

                            DispatchQueue.main.async {
                                // Make sure to update UI changes on the main thread
                                self.view.window?.rootViewController = nav
                            }
                        }
                    }
                }
            }
        }
    }
}
