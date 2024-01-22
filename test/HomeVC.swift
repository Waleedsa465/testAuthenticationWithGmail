import UIKit

class HomeVC: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
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
//        nav.navigationBar.isHidden = true
        self.view.window?.rootViewController = nav
    }
}
