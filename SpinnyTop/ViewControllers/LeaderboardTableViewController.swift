//
//  LeaderboardTableViewController.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 11/3/17.
//  Copyright © 2017 Kyle Raney. All rights reserved.
//

import UIKit
import FirebaseDatabase
import Alamofire
import SwiftyJSON

class LeaderboardTableViewController: UITableViewController {
    
    
    
    var scores = [Score]()
    var users = [User]()
    let searchController = UISearchController(searchResultsController: nil)
    var filteredScores = [User]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 110
        
        loadHighScoreData()
        searchController.searchBar.scopeButtonTitles = ["Lifetime Spins", "RPS", "Duration", "Rotations"]
        searchController.searchBar.showsScopeBar = true
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Usernames"
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
        }
        
        definesPresentationContext = true
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if isFiltering() {
            return filteredScores.count
        }
        
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "userCell"
        let currentUser: User
        if isFiltering() {
            currentUser = filteredScores[indexPath.row]
        } else {
            currentUser = users[indexPath.row]
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! LeaderboardTableViewCell
        
        cell.usernameLabel.text = currentUser.username
        cell.lifetimeRotationsLabel.text = String(format: "%d", currentUser.lifetime_rotations!)
        cell.maxDurationLabel.text = String(format: "%.2f", currentUser.max_spin_duration!)
        cell.maxSpinRPSLabel.text = String(format: "%.2f", currentUser.max_spin_rps!)
        cell.maxRotationsLabel.text = String(format: "%d", currentUser.max_spin_rotations!)
        
        return cell
    }
    
    private func loadHighScoreData() {
        
        Alamofire.request("https://spinny-top.herokuapp.com/api/users/").responseJSON { response in
            
            if let jsonValue = response.result.value {
                let json = JSON(jsonValue)
                for (_,user) in json {
                    let username = user["username"].stringValue
                    let u = User(username: username, token: nil, email: nil)
                    u.max_spin_rps = user["max_spin_rps"]["speed__max"].doubleValue
                    u.max_spin_duration = user["max_spin_duration"]["duration__max"].doubleValue
                    u.max_spin_rotations = user["max_spin_rotations"]["rotations__max"].intValue
                    u.lifetime_rotations = user["lifetime_rotations"]["rotations__sum"].intValue
                    
                    self.users.append(u)
                    // Fix startTime
//                    let score = Score(username: username!, startTime: Date(), maxSpeed: speed)
//                    self.scores.append(score)
                }
                self.orderUsers()
                self.tableView.reloadData()

            } else {
                print("no JSON object")
            }
        }
    }
    
    func orderUsers() {
        users.sort {
            return $0.lifetime_rotations! > $1.lifetime_rotations!
        }
//        self.tableView.reloadData()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredScores = users.filter({( user : User ) -> Bool in
            let order = (scope == "Lifetime Spins")
            
            if searchBarIsEmpty() {
                return order
            } else {
                return order && user.username.lowercased().contains(searchText.lowercased())
            }
            
        })
        tableView.reloadData()
    }

    func isFiltering() -> Bool {
        let searchBarIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarIsFiltering)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LeaderboardTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
        
    }
}

extension LeaderboardTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}
