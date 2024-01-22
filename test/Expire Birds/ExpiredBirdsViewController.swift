


import UIKit
import Firebase
import FirebaseDatabase

class ExpiredBirdsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    var arrData = [ExpiredBird]()
    var filteredData = [ExpiredBird]()
    var ref = Database.database().reference()
    
    var keyArray:[String] = []

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        fetchDataFromFirebase()
        searchBar.delegate = self
    }

    func configureTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }

    func fetchDataFromFirebase() {
        ref.child("ExpireData").observe(.value, with: { snapshot in
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
                let bird = try JSONDecoder().decode(ExpiredBird.self, from: jsonData)
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ExpiredBirdsViewCell

            let bird: ExpiredBird
            if isFiltering() {
                bird = filteredData[indexPath.row]
            } else {
                bird = arrData[indexPath.row]
            }

            cell.certificateNoLbl.text = ("Certificate : \(bird.certificateNo )")
            cell.birdIdLbl.text = ("Bird Id : \(bird.birdID )")
            cell.birdSpecieLbl.text = ("Bird Name : \(bird.birdSpecie )")
            cell.expireDateLbl.text = ("Expire Date : \(bird.Sold_or_Expire )")

            return cell
        }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ExpiredBirdsDetailsVC") as! ExpiredBirdsDetailsVC

        if isFiltering() {
            vc.expireDetail = filteredData[indexPath.row]
        } else {
            vc.expireDetail = arrData[indexPath.row]
        }

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
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Alert", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }


    func filterContentForSearchText(_ searchText: String) {
        filteredData = arrData.filter { bird in
            return bird.birdID.lowercased().contains(searchText.lowercased()) ||
                bird.certificateNo.lowercased().contains(searchText.lowercased())
        }

        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
          return true
      }

      func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
          if editingStyle == .delete {
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

      // MARK: - Delete Data

      func deleteExpiredData(withCriteria criteria: [String: Any], indexPath: IndexPath) {
          let expiredDataRef = ref.child("ExpireData")

          expiredDataRef.queryOrdered(byChild: "Bird_ID").queryEqual(toValue: criteria["Bird_ID"]).observeSingleEvent(of: .value) { snapshot in
              guard let dataSnapshot = snapshot.children.allObjects as? [DataSnapshot] else {
                  print("Error: Unable to get data snapshot")
                  return
              }

              for data in dataSnapshot {
                  data.ref.removeValue { error, _ in
                      if let error = error {
                          print("Error deleting expired data: \(error.localizedDescription)")
                      } else {
                          self.showAlert(message: "Data Deleted Successfully")
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
        self.tableView.reloadData()
    }
    
}
