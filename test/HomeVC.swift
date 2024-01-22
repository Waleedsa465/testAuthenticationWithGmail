import UIKit
import FirebaseAuth
import FirebaseDatabase

class HomeVC: UIViewController {

    var arrData = [User]()
    var txtData: User!
    var ref = Database.database().reference()
    
    @IBOutlet weak var firstNameLbl: UILabel!
    @IBOutlet weak var lastNameLbl: UILabel!
    @IBOutlet weak var emailAddress: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchDataForCurrentUser()
        self.firstNameLbl.text = self.txtData?.firstname
        self.lastNameLbl.text = self.txtData?.lastname
        self.emailAddress.text = self.txtData?.Email
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

            DispatchQueue.main.async {
                // Update UI after data is fetched
                self.firstNameLbl.text = ("First Name : \(self.txtData?.firstname ?? "FirstName Not Found")")
                self.lastNameLbl.text = ("Last Name : \(self.txtData?.lastname ?? "lastname Not Found")")
                self.emailAddress.text = ("Email Address : \(self.txtData?.Email ?? "Email Address Not Found")")
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

