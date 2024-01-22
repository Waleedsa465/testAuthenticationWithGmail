

import UIKit
import Firebase
import FirebaseDatabase

class SearchBirdsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var arrData = [Bird]()
    var filteredData = [Bird]()
    var ref = Database.database().reference()
    

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        fetchDataForCurrentUser()
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

        let userRef = ref.child("users").child(currentUserUID).child("BirdsApp")

        userRef.observe(.value, with: { snapshot in
            guard let data = snapshot.value as? [String: [String: Any]] else {
                print("Error: Invalid data format")
                return
            }

            self.arrData.removeAll()
            self.parseBirdData(data)

            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }) { error in
            print("Error fetching data: \(error.localizedDescription)")
        }
    }

    func parseBirdData(_ data: [String: [String: Any]]) {
        for (_, birdData) in data {
            do {
                let jsonData = try JSONSerialization.data(withJSONObject: birdData)
                let bird = try JSONDecoder().decode(Bird.self, from: jsonData)
                self.arrData.append(bird)
            } catch {
                print("Error decoding Bird data: \(error.localizedDescription)")
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return filteredData.count
        }
        return arrData.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! TableViewCell

        let bird: Bird
        if isFiltering() {
            bird = filteredData[indexPath.row]
        } else {
            bird = arrData[indexPath.row]
        }

        cell.birdIdLbl.text = (" Bird Id : \(bird.bird_ID )")
        cell.certificateLbl.text = ("Certificate : \(bird.certificate_No )")
        cell.birdNameLbl.text = (" Bird Name : \(bird.bird_Specie )")

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "SearchBirdsDetailController") as! SearchBirdsDetailController

        if isFiltering() {
            vc.dataForNextViewController = filteredData[indexPath.row]
        } else {
            vc.dataForNextViewController = arrData[indexPath.row]
        }

        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func refreshBtn(_ sender: Any) {
        fetchDataForCurrentUser()
        self.tableView.reloadData()
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
            return bird.bird_ID.lowercased().contains(searchText.lowercased()) ||
                bird.certificate_No.lowercased().contains(searchText.lowercased())
        }

        tableView.reloadData()
    }
    
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }


 
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let selectedBird: Bird
            if isFiltering() {
                selectedBird = filteredData[indexPath.row]
            } else {
                selectedBird = arrData[indexPath.row]
            }

            // Show a confirmation alert before deleting
            let alert = UIAlertController(title: "Delete Bird", message: "Are you sure you want to delete this bird?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [self] _ in
                let criteria = ["Bird_ID": selectedBird.bird_ID]
                deleteBird(withCriteria: criteria, indexPath: indexPath)
            }))
            
            present(alert, animated: true, completion: nil)
        }
    }
      // MARK: - Delete Data
    func deleteBird(withCriteria criteria: [String: Any], indexPath: IndexPath) {
           guard let currentUserUID = Auth.auth().currentUser?.uid else {
               // Handle the case where the user is not authenticated
               return
           }

           let userBirdsRef = ref.child("users").child(currentUserUID).child("BirdsApp")
           userBirdsRef.queryOrdered(byChild: "Bird_ID").queryEqual(toValue: criteria["Bird_ID"]).observeSingleEvent(of: .value) { snapshot in
               guard let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                   print("Error: Unable to get data snapshot")
                   return
               }

               for data in dataSnapshot {
                   data.ref.removeValue { error, _ in
                       if let error = error {
                           print("Error deleting bird data: \(error.localizedDescription)")
                       } else {
                           self.showAlert(message: "Data Deleted Successfully")
                           print("Bird data deleted successfully.")
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
    }
