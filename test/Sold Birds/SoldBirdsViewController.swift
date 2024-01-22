import UIKit
import Firebase
import FirebaseDatabase

class SoldBirdsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var arrData = [SoldBird]()
    var filteredData = [SoldBird]()
    var ref = Database.database().reference()
    var keyArray: [String] = []

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(true, forKey: strLoginKey)

        configureTableView()
        fetchDataFromFirebase()
        searchBar.delegate = self
    }

    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    func fetchDataFromFirebase() {
        ref.child("SoldData").observe(.value, with: { snapshot in
            guard let data = snapshot.value as? [String: [String: Any]] else {
                print("Error: Invalid data format")
                return
            }

            self.arrData.removeAll()
            self.parseSoldBirdData(data)

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }) { error in
            print("Error fetching data: \(error.localizedDescription)")
        }
    }

    func parseSoldBirdData(_ data: [String: [String: Any]]) {
        for (_, birdData) in data {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: birdData)
                let bird = try JSONDecoder().decode(SoldBird.self, from: jsonData)
                self.arrData.append(bird)
            } catch {
                print("Error decoding SoldBird data: \(error.localizedDescription)")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SoldTableViewCell

        let currentBird: SoldBird
        if isFiltering() {
            currentBird = filteredData[indexPath.row]
        } else {
            currentBird = arrData[indexPath.row]
        }

        cell.certificateNo.text = ("Certificate : \(currentBird.certificateNo )")
        cell.birdIdLbl.text = ("Bird Id : \(currentBird.birdID )")
        cell.birdSpecieLbl.text = ("Bird Name : \(currentBird.birdSpecie )")
        cell.soldDateLbl.text = ("Sold Date : \(currentBird.Sold_or_Expire )")

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SoldDetailViewController") as! SoldDetailViewController

        let selectedBird: SoldBird
        if isFiltering() {
            selectedBird = filteredData[indexPath.row]
        } else {
            selectedBird = arrData[indexPath.row]
        }

        vc.soldData = selectedBird

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
            let selectedBird: SoldBird
            if isFiltering() {
                selectedBird = filteredData[indexPath.row]
            } else {
                selectedBird = arrData[indexPath.row]
            }
            let alert = UIAlertController(title: "Delete Bird", message: "Are you sure you want to delete this bird?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [self] _ in
                let criteria = ["Bird_ID": selectedBird.birdID]
                deleteSoldData(withCriteria: criteria, indexPath: indexPath)
            }))
            
            present(alert, animated: true, completion: nil)

        }
    }

    // Function to delete data based on specified criteria
    // Function to delete data based on specified criteria
    func deleteSoldData(withCriteria criteria: [String: Any], indexPath: IndexPath) {
        let soldDataRef = ref.child("SoldData")

        soldDataRef.queryOrdered(byChild: "Bird_ID").queryEqual(toValue: criteria["Bird_ID"]).observeSingleEvent(of: .value) { snapshot in
            guard let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                print("Error: Unable to get data snapshot")
                return
            }

            for data in dataSnapshot {
                data.ref.removeValue { error, _ in
                    if let error = error {
                        print("Error deleting sold data: \(error.localizedDescription)")
                    } else {
                        print("Sold data deleted successfully.")
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
        self.tableView.reloadData()
    }
}
