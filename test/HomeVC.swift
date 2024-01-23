import UIKit
import FirebaseAuth
import FirebaseDatabase
import Kingfisher

class HomeVC: UIViewController {

    var arrData = [User]()
    var txtData: User!
    var ref = Database.database().reference()
    
    var imgView = ""
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var firstNameLbl: UILabel!
    @IBOutlet weak var lastNameLbl: UILabel!
    @IBOutlet weak var emailAddress: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDataForCurrentUser()
        imageView.layer.cornerRadius = 75
        self.firstNameLbl.text = self.txtData?.firstname
        self.lastNameLbl.text = self.txtData?.lastname
        self.emailAddress.text = self.txtData?.Email
        activityIndicator.isHidden = true
    }
    
    func fetchDataForCurrentUser() {

        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            // Handle the case where the user is not authenticated
            return
        }

        let userSoldDataRef = ref.child("users").child(currentUserUID)
        userSoldDataRef.observe(.value, with: { snapshot in
            print(snapshot.value ?? "SnapShot Nil")

            guard let data = snapshot.value as? [String: Any] else {
                print("Error: Invalid data format")
                return
            }
            self.parseUserData(data)

            // Update UI after data is fetched
            DispatchQueue.main.async {
                self.firstNameLbl.text = ("First Name : \(self.txtData?.firstname ?? "FirstName Not Found")")
                self.lastNameLbl.text = ("Last Name : \(self.txtData?.lastname ?? "lastname Not Found")")
                self.emailAddress.text = ("Email Address : \(self.txtData?.Email ?? "Email Address Not Found")")

                let placeholderImage = UIImage(named: "placeholderImage")
                if let url = URL(string: self.txtData.ProfileImageURL) {
                    self.activityIndicator.isHidden = false
                    self.activityIndicator.startAnimating()

                    self.imageView.kf.setImage(with: url, placeholder: placeholderImage, completionHandler: { result in
                        switch result {
                        case .success(_):
                            self.activityIndicator.isHidden = true
                            self.activityIndicator.stopAnimating()
                        case .failure(let error):
                            print("Error loading image: \(error.localizedDescription)")
                            self.activityIndicator.isHidden = true
                            self.activityIndicator.stopAnimating()
                        }
                    })

                } else {
                    // Handle invalid URL
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                }
            }
        }) { error in
            print("Error fetching data: \(error.localizedDescription)")
        }
    }
    func parseUserData(_ data: [String: Any]) {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data)
            let user = try JSONDecoder().decode(User.self, from: jsonData)
            self.arrData.append(user)
            self.txtData = user
            print("Parsed User: \(user)")
        } catch {
            print("Error decoding user data: \(error)")
        }
    }


    @IBAction func logoutBtn(_ sender: Any) {
        // Create an alert to confirm logout
        let alert = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: .alert)

        // Add logout action
        alert.addAction(UIAlertAction(title: "Logout", style: .destructive, handler: { action in
            self.performLogout()
        }))

        // Add cancel action
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        // Present the alert
        present(alert, animated: true, completion: nil)
    }
        func performLogout() {
            UserDefaults.standard.set(false, forKey: strLoginKey)
            print("Logout Successfully")
            let loginVC = storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            let nav = UINavigationController(rootViewController: loginVC)
            self.view.window?.rootViewController = nav
        }
    }

