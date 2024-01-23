import UIKit
import Firebase
import FirebaseDatabase

class ExpiredBirdsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var arrData = [ExpiredBird]()
    var filteredData = [ExpiredBird]()
    var ref = Database.database().reference()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(true, forKey: strLoginKey)

        configureTableView()
        fetchDataForCurrentUser()
        searchBar.layer.cornerRadius = 100
        searchBar.delegate = self
    }

    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    func fetchDataForCurrentUser() {
        guard let currentUserUID = Auth.auth().currentUser?.uid else {
            // Handle the case where the user is not authenticated
            return
        }

        let userExpireDataRef = ref.child("users").child(currentUserUID).child("ExpireData")

        userExpireDataRef.observe(.value, with: { snapshot in
            guard let data = snapshot.value as? [String: [String: Any]] else {
                print("Error: Invalid data format")
                return
            }

            self.arrData.removeAll()
            self.parseExpiredBirdData(data)

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }) { error in
            print("Error fetching data: \(error.localizedDescription)")
        }
    }

    func parseExpiredBirdData(_ data: [String: [String: Any]]) {
        for (_, birdData) in data {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: birdData)
                let bird = try JSONDecoder().decode(ExpiredBird.self, from: jsonData)
                self.arrData.append(bird)
            } catch {
                print("Error decoding ExpiredBird data: \(error.localizedDescription)")
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredData.count
        } else {
            return arrData.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ExpiredBirdsViewCell

        let currentBird: ExpiredBird
        if isFiltering() {
            currentBird = filteredData[indexPath.row]
        } else {
            currentBird = arrData[indexPath.row]
        }

        cell.certificateNoLbl.text = ("Certificate : \(currentBird.certificateNo )")
        cell.birdIdLbl.text = ("Bird Id : \(currentBird.birdID )")
        cell.birdSpecieLbl.text = ("Bird Name : \(currentBird.birdSpecie )")
        cell.expireDateLbl.text = ("Expire Date : \(currentBird.Sold_or_Expire )")

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ExpiredBirdsDetailsVC") as! ExpiredBirdsDetailsVC

        let selectedBird: ExpiredBird
        if isFiltering() {
            selectedBird = filteredData[indexPath.row]
        } else {
            selectedBird = arrData[indexPath.row]
        }

        vc.expireDetail = selectedBird

        self.navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Search Bar Delegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        filterContentForSearchText(searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }

    func isFiltering() -> Bool {
        return searchBar.text?.isEmpty == false
    }

    func filterContentForSearchText(_ searchText: String) {
        filteredData = arrData.filter { bird in
            return bird.birdID.range(of: searchText, options: .caseInsensitive) != nil ||
                bird.certificateNo.range(of: searchText, options: .caseInsensitive) != nil
        }

        tableView.reloadData()
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the data based on the specified criteria
            let selectedBird: ExpiredBird
            if isFiltering() {
                selectedBird = filteredData[indexPath.row]
            } else {
                selectedBird = arrData[indexPath.row]
            }
            let alert = UIAlertController(title: "Delete Bird", message: "Are you sure you want to delete this bird?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [self] _ in
                let criteria = ["Bird_ID": selectedBird.birdID]
                deleteExpiredData(withCriteria: criteria, indexPath: indexPath)
            }))

            present(alert, animated: true, completion: nil)
        }
    }

    // Function to delete data based on specified criteria
    func deleteExpiredData(withCriteria criteria: [String: Any], indexPath: IndexPath) {
        let expireDataRef = ref.child("users").child(Auth.auth().currentUser!.uid).child("ExpireData")

        expireDataRef.queryOrdered(byChild: "Bird_ID").queryEqual(toValue: criteria["Bird_ID"]).observeSingleEvent(of: .value) { snapshot in
            guard let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                print("Error: Unable to get data snapshot")
                return
            }

            for data in dataSnapshot {
                data.ref.removeValue { error, _ in
                    if let error = error {
                        print("Error deleting expired data: \(error.localizedDescription)")
                    } else {
                        print("Expired data deleted successfully.")
                    }
                }
            }

            // Remove from the local arrays
            self.arrData.remove(at: indexPath.row)

            // Update the filtered data if applicable
            if self.isFiltering() {
                self.filteredData.remove(at: indexPath.row)
            }

            // Reload the table view
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    @IBAction func refreshBtn(_ sender: Any) {
        self.fetchDataForCurrentUser()
        self.tableView.reloadData()
    }
}
