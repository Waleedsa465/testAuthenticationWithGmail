import UIKit
import Firebase
import AVFoundation
import AVKit

class AddBirdsViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var certificateNoTextField: UITextField!
    @IBOutlet weak var birdIDTextField: UITextField!
    @IBOutlet weak var ownerNameTextField: UITextField!
    @IBOutlet weak var birdSpecieTextField: UITextField!
    @IBOutlet weak var sampleTypeTextField: UITextField!
    @IBOutlet weak var collectionTextField: UITextField!
    @IBOutlet weak var sexDeterminedTextField: UITextField!
    @IBOutlet weak var accuracyTextField: UITextField!

    
    var videoPlayer:AVPlayer?
    var videoPlayerLayer:AVPlayerLayer?
    
    
    var arrayData = [Bird]()
    
    var ref = DatabaseReference.init()
    var spinner: UIActivityIndicatorView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        UserDefaults.standard.set(true, forKey: strLoginKey)


        imageView.layer.cornerRadius = 50



        setupTextField()
        setupKeyboardHandling()

        // Add tap gesture recognizer to the imageView
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageViewTapped))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tapGestureRecognizer)

       
        self.ref = Database.database().reference()

        // Create a spinner programmatically
        spinner = UIActivityIndicatorView(style: .large)
        spinner.hidesWhenStopped = true
        view.addSubview(spinner)
        spinner.center = view.center
        
    }
    

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }





    func setupKeyboardHandling() {
        let textFields = [
            certificateNoTextField,
            birdIDTextField,
            ownerNameTextField,
            birdSpecieTextField,
            sampleTypeTextField,
            collectionTextField,
            sexDeterminedTextField,
            accuracyTextField,
            dateTextField
        ]

        for textField in textFields {
            textField?.delegate = self
        }
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case certificateNoTextField:
            birdIDTextField.becomeFirstResponder()
        case birdIDTextField:
            ownerNameTextField.becomeFirstResponder()
        case ownerNameTextField:
            birdSpecieTextField.becomeFirstResponder()
        case birdSpecieTextField:
            sampleTypeTextField.becomeFirstResponder()
        case sampleTypeTextField:
            collectionTextField.becomeFirstResponder()
        case collectionTextField:
            sexDeterminedTextField.becomeFirstResponder()
        case sexDeterminedTextField:
            accuracyTextField.becomeFirstResponder()
        case accuracyTextField:
            dateTextField.becomeFirstResponder()
        case dateTextField:
            dateTextField.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }

    func setupTextField() {
        dateTextField.isUserInteractionEnabled = true
        dateTextField.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(textFieldTapped)))
    }

    @objc func textFieldTapped() {
        fillCurrentDateAndTime()
    }

    func fillCurrentDateAndTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd   HH:mm:ss"
        let currentDateAndTime = dateFormatter.string(from: Date())
        dateTextField.text = currentDateAndTime
    }

    @objc func imageViewTapped() {
        showImagePicker()
    }

    func showImagePicker() {
        let alertController = UIAlertController(title: "Where you want to choose the image", message: nil, preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            self?.openCamera()
        }

        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { [weak self] _ in
            self?.openGallery()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(cameraAction)
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }

    func openCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        } else {
            // Handle the case where the camera is not available
            showAlert(message: "No camera Found")
        }
    }

    func openGallery() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            imageView.image = selectedImage
        }

        dismiss(animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func uploadImage(_ image: UIImage, completion: @escaping (_ url: URL?)-> ()) {
        spinner.startAnimating()

        guard let imageData = image.pngData() else {
            spinner.stopAnimating()
            completion(nil)
            return
        }

        let imageName = UUID().uuidString
        let storageRef = Storage.storage().reference().child("myImages").child(imageName)
        let metaData = StorageMetadata()

        storageRef.putData(imageData, metadata: metaData) { [weak self] (metadata, error) in
            guard let self = self else {
                DispatchQueue.main.async {
                    completion(nil)
                    self?.spinner.stopAnimating()
                }
                return
            }
            if let error = error {
                print("Error while uploading image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(nil)
                    self.spinner.stopAnimating()
                }
            } else {
                print("Successfully uploaded image")
                storageRef.downloadURL { url, error in
                    DispatchQueue.main.async {
                        if let downloadURL = url {
                            completion(downloadURL)
                        } else {
                            completion(nil)
                        }
                        self.spinner.stopAnimating()
                        self.clearAllFields()
                        self.showAlert(message: "Data uploaded successfully!")
                    }
                }
            }
        }
    }


    func saveImage(name: String, profileURL: URL, completion: @escaping ((_ url: URL?)-> ())) {
        let dic: [String: Any] = [
            "Certificate_No": certificateNoTextField.text!,
            "Bird_ID": birdIDTextField.text!,
            "Owner_Name": ownerNameTextField.text!,
            "Bird_Specie": birdSpecieTextField.text!,
            "Sample_Type": sampleTypeTextField.text!,
            "Collection": collectionTextField.text!,
            "Sex_Determination": sexDeterminedTextField.text!,
            "Accuracy": accuracyTextField.text!,
            "Upload_Date": dateTextField.text!,
            "UploadCurrentImage": profileURL.absoluteString
        ]

        self.ref.child("BirdsApp").childByAutoId().setValue(dic)
    }

    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    func errorWhileUploadingData() {
        let actions = UIAlertController(title: "Data Upload", message: "Error While Uploading Data", preferredStyle: .alert)
        actions.addAction(UIAlertAction(title: "OK", style: .default, handler: { actions in
            print("Error while uploading data")
        }))
        present(actions, animated: true)
    }


    @IBAction func submitBtn(_ sender: Any) {
        guard let selectedImage = imageView.image else {
            showAlert(message: "Please select an image.")
            return
        }

        guard !isEmptyTextField() else {
            showAlert(message: "Please fill in all the fields.")
            return
        }

        uploadImage(selectedImage) { [weak self] url in
            guard let self = self else { return }

            if let url = url {
                self.saveImage(name: "imageName", profileURL: url) { [weak self] success in
                    guard let self = self else { return }

                    DispatchQueue.main.async {
                        self.showAlert(message: "Data uploaded successfully!")
                        self.clearAllFields()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.errorWhileUploadingData()
                }
            }
        }
    }

    func isEmptyTextField() -> Bool {
        let textFields = [
            certificateNoTextField,
            birdIDTextField,
            ownerNameTextField,
            birdSpecieTextField,
            sampleTypeTextField,
            collectionTextField,
            sexDeterminedTextField,
            accuracyTextField,
            dateTextField
        ]

        for textField in textFields {
            if let text = textField?.text, text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return true
            }
        }

        return false
    }

    func clearAllFields() {
        certificateNoTextField.text = ""
        birdIDTextField.text = ""
        ownerNameTextField.text = ""
        birdSpecieTextField.text = ""
        sampleTypeTextField.text = ""
        collectionTextField.text = ""
        sexDeterminedTextField.text = ""
        accuracyTextField.text = ""
        dateTextField.text = ""
        imageView.image = nil
    }
    
}
