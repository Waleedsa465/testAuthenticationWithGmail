import UIKit
import FirebaseAuth
import Kingfisher
import FirebaseDatabase

class SearchBirdsDetailController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ownerName: UILabel!
    @IBOutlet weak var sampleType: UILabel!
    @IBOutlet weak var certificateLbl: UILabel!
    @IBOutlet weak var birdId: UILabel!
    @IBOutlet weak var birdSpecie: UILabel!
    @IBOutlet weak var collectionLbl: UILabel!
    @IBOutlet weak var sexDetermination: UILabel!
    @IBOutlet weak var accuracyLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var buyerNameText: UITextField!
    @IBOutlet weak var dateTextFields: UITextField!
    @IBOutlet weak var buyerPhoneNumber: UITextField!
    @IBOutlet weak var soldorExpireDateTxt: UITextField!
    

    var imgView = ""
    var dataForNextViewController: Bird!
    var arrayData = [Bird]()
    
    var ref = DatabaseReference.init()

    override func viewDidLoad() {
        super.viewDidLoad()

        UserDefaults.standard.set(true, forKey: strLoginKey)
        
        imageView.layer.cornerRadius = 20

        Utilities.styleTextField(soldorExpireDateTxt)
        Utilities.styleTextField(buyerPhoneNumber)
        Utilities.styleTextField(buyerNameText)
        soldorExpireDateTxt.attributedPlaceholder = NSAttributedString(string: "Sold or Expire Date", attributes: [NSAttributedString.Key.foregroundColor: UIColor.blue])
        buyerPhoneNumber.attributedPlaceholder = NSAttributedString(string: "Sold To : Buyer Phone Number", attributes: [NSAttributedString.Key.foregroundColor: UIColor.blue])
        buyerNameText.attributedPlaceholder = NSAttributedString(string: "Sold To : Buyer Name", attributes: [NSAttributedString.Key.foregroundColor: UIColor.blue])
        
        self.ref = Database.database().reference()
        buyerNameText.delegate = self
        buyerPhoneNumber.delegate = self
        
        setupKeyboardHandling()
        setupTextField()
        

        ownerName.text = ("Owner Name :  \(self.dataForNextViewController.owner_Name)")
        sampleType.text = ("Sample Type :  \(self.dataForNextViewController.sample_Type)")
        certificateLbl.text = ("Certificate :  \(self.dataForNextViewController.certificate_No)")
        birdId.text = ("Bird Id :  \(self.dataForNextViewController.bird_ID)")
        birdSpecie.text = ("Bird Specie :  \(self.dataForNextViewController.bird_Specie)")
        collectionLbl.text = ("Collection :  \(self.dataForNextViewController.collection)")
        sexDetermination.text = ("Sex :  \(self.dataForNextViewController.sex_Determination)")
        accuracyLbl.text = ("Accuracy :  \(self.dataForNextViewController.accuracy)")
        dateLbl.text = ("Upload Date :  \(self.dataForNextViewController.upload_Date)")
    
        imgView = self.dataForNextViewController.uploadCurrentImage

        let placeholderImage = UIImage(named: "placeholderImage")
        if let url = URL(string: imgView) {
            imageView.kf.setImage(with: url, placeholder: placeholderImage)
        }
        
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
        let tapGestureRecognizers = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        scrollView.addGestureRecognizer(tapGestureRecognizers)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    
    @objc func keyboardWillShow(_ notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardSize.height, right: 0)
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
        }
    }

    @objc func keyboardWillHide(_ notification: NSNotification) {
        scrollView.contentInset = .zero
        scrollView.scrollIndicatorInsets = .zero
    }

    @IBAction func soldBtn(_ sender: Any) {
        
        
        guard !isEmptyTextField() else {
            showAlert(message: "Please fill in all the fields.")
            return
        }
        DispatchQueue.main.async {
            self.showAlert(message: "Data uploaded successfully!")
            self.soldFunc()
            self.clearAllFields()
           
        }
        
    }
    
    func setupKeyboardHandling() {
        let textFields = [
            buyerNameText,
            buyerPhoneNumber,
            dateTextFields
        ]

        for textField in textFields {
            textField?.delegate = self
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case buyerNameText:
            buyerPhoneNumber.becomeFirstResponder()
        case buyerPhoneNumber:
            dateTextFields.becomeFirstResponder()
        case dateTextFields:
            dateTextFields.resignFirstResponder()
        default:
            textField.resignFirstResponder()
        }
        return true
    }
    
    func setupTextField() {
        dateTextFields.isUserInteractionEnabled = true
        dateTextFields.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(textFieldTapped)))
    }

    @objc func textFieldTapped() {
        fillCurrentDateAndTime()
    }

    func fillCurrentDateAndTime() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd   HH:mm:ss"
        let currentDateAndTime = dateFormatter.string(from: Date())
        dateTextFields.text = currentDateAndTime
    }
    
    func clearAllFields() {
        buyerNameText.text = ""
        buyerPhoneNumber.text = ""
    }

    
    func isEmptyTextField() -> Bool {
        let textFields = [
            buyerNameText,
            buyerPhoneNumber,
            soldorExpireDateTxt
        ]

        for textField in textFields {
            if let text = textField?.text, text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return true
            }
        }

        return false
    }
    
    func soldFunc() {
        guard let currentUser = Auth.auth().currentUser else {
            // Handle the case where the current user is not available
            showAlert(message: "User not authenticated.")
            return
        }
        let userUID = currentUser.uid
        
        var dic: [String: Any] = [
            "Certificate_No": dataForNextViewController.certificate_No,
            "Bird_ID": dataForNextViewController.bird_ID,
            "Owner_Name": dataForNextViewController.owner_Name,
            "Bird_Specie": dataForNextViewController.bird_Specie,
            "Sample_Type": dataForNextViewController.sample_Type,
            "Collection": dataForNextViewController.collection,
            "Sex_Determination": dataForNextViewController.sex_Determination,
            "Accuracy": dataForNextViewController.accuracy,
            "Upload_Date": dataForNextViewController.upload_Date,
            "UploadCurrentImage": dataForNextViewController.uploadCurrentImage,
            "buyer_Name": buyerNameText.text!,
            "buyer_Phone_Number": buyerPhoneNumber.text!,
            "Sold_or_Expire" : soldorExpireDateTxt.text!
        ]

        
        let soldDataRef = self.ref.child("users").child(userUID).child("SoldData").childByAutoId()

        soldDataRef.setValue(dic) { (error, _) in
            if let error = error {
                print("Error saving data to Sold_Data_Of_BirdsApp: \(error.localizedDescription)")
                self.showAlert(message: "Error While Pushing Data to Store Tab")
            } else {
                print("Data saved successfully at \(soldDataRef.url)")
                self.showAlert(message: "Data saved successfully")
            }
        }

    }
    
    

    @IBAction func expireBtn(_ sender: Any) {
        guard !isDateTextField() else {
            showAlert(message: "Please enter the date.")
            return
        }
        DispatchQueue.main.async { [self] in
            self.showAlert(message: "Data uploaded successfully!")
            expireFunc()
            self.clearAllFields()
           
        }
        
    }
    
    func expireFunc() {
        guard let currentUser = Auth.auth().currentUser else {
            // Handle the case where the current user is not available
            showAlert(message: "User not authenticated.")
            return
        }
        let userUID = currentUser.uid
        
        let dic: [String: Any] = [
            "Certificate_No": dataForNextViewController.certificate_No,
            "Bird_ID": dataForNextViewController.bird_ID,
            "Owner_Name": dataForNextViewController.owner_Name,
            "Bird_Specie": dataForNextViewController.bird_Specie,
            "Sample_Type": dataForNextViewController.sample_Type,
            "Collection": dataForNextViewController.collection,
            "Sex_Determination": dataForNextViewController.sex_Determination,
            "Accuracy": dataForNextViewController.accuracy,
            "Upload_Date": dataForNextViewController.upload_Date,
            "UploadCurrentImage": dataForNextViewController.uploadCurrentImage,
            "Sold_or_Expire" : soldorExpireDateTxt.text!
        ]
        

        let soldDataRef = self.ref.child("users").child(userUID).child("ExpireData").childByAutoId()

        soldDataRef.setValue(dic) { (error, _) in
            if error != nil {
                self.showAlert(message: "Error While Pushing Data to Expire Tab")
                // Handle failure, such as showing an error message
            } else {
                print("Data saved successfully at \(soldDataRef.url)")
                self.showAlert(message: "Data saved successfully")
                // Handle success, such as updating UI or navigating to another view controller
            }
        }
    }

    func isDateTextField() -> Bool {
        let textFields = [
            soldorExpireDateTxt
        ]

        for textField in textFields {
            if let text = textField?.text, text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                return true
            }
        }

        return false
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

}
