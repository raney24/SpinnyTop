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
    
    var sv: UIView!
    
    var scores = [Score]()
    var users = [User]()
    let searchController = UISearchController(searchResultsController: nil)
    var filteredUsers = [User]()
    let sizeGroup = UIDevice.current.sizeGroup

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 120
        
        // show loading indicator
        self.sv = UIViewController.displaySpinner(onView: self.view)
        loadHighScoreData()
        
        searchController.searchBar.scopeButtonTitles = ["Lifetime", "RPS", "Duration", "Rotations"]
        searchController.searchBar.showsScopeBar = true
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Usernames"
        searchController.hidesNavigationBarDuringPresentation = false
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.searchController.isActive = true
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
            return filteredUsers.count
        }
        
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "userCell"
        let currentUser: User
        if isFiltering() {
            currentUser = filteredUsers[indexPath.row]
        } else {
            currentUser = users[indexPath.row]
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! LeaderboardTableViewCell
        
        cell.usernameLabel.text = currentUser.username
        cell.lifetimeRotationsLabel.text = String(format: "%d", currentUser.lifetime_rotations!)
        cell.maxDurationLabel.text = String(format: "%.2f", currentUser.max_spin_duration!)
        cell.maxSpinRPSLabel.text = String(format: "%.2f", currentUser.max_spin_rps!)
        cell.maxRotationsLabel.text = String(format: "%d", currentUser.max_spin_rotations!)
        
        if (indexPath.row % 2 == 0) {
            cell.backgroundColor = UIColor.white
        } else {
            cell.backgroundColor = UIColor.init(hex: "F2F2F2")
        }
        print(sizeGroup)
        print(UIDevice.current.modelName)
        var textSize: CGFloat
        if (sizeGroup == "small") {
            textSize = 12.0
        } else if (sizeGroup == "plus") {
            textSize = 15.0
        } else {
            textSize = 14.0
        }
        
        cell.lifeTimeRotationsTitle.font = UIFont.systemFont(ofSize: textSize)
        cell.lifetimeRotationsLabel.font = UIFont.systemFont(ofSize: textSize)
        
        cell.maxSpinRPSTitle.font = UIFont.systemFont(ofSize: textSize)
        cell.maxSpinRPSLabel.font = UIFont.systemFont(ofSize: textSize)
        
        cell.maxDurationTitle.font = UIFont.systemFont(ofSize: textSize)
        cell.maxDurationLabel.font = UIFont.systemFont(ofSize: textSize)
        
        cell.maxRotationsTitle.font = UIFont.systemFont(ofSize: textSize)
        cell.maxRotationsLabel.font = UIFont.systemFont(ofSize: textSize)
        
        if searchController.searchBar.selectedScopeButtonIndex == 0 {
            cell.lifeTimeRotationsTitle.font = UIFont.boldSystemFont(ofSize: textSize)
            cell.lifetimeRotationsLabel.font = UIFont.boldSystemFont(ofSize: textSize)
        } else if searchController.searchBar.selectedScopeButtonIndex == 1 {
            cell.maxSpinRPSTitle.font = UIFont.boldSystemFont(ofSize: textSize)
            cell.maxSpinRPSLabel.font = UIFont.boldSystemFont(ofSize: textSize)
        } else if searchController.searchBar.selectedScopeButtonIndex == 2 {
            cell.maxDurationTitle.font = UIFont.boldSystemFont(ofSize: textSize)
            cell.maxDurationLabel.font = UIFont.boldSystemFont(ofSize: textSize)
        } else if searchController.searchBar.selectedScopeButtonIndex == 3 {
            cell.maxRotationsTitle.font = UIFont.boldSystemFont(ofSize: textSize)
            cell.maxRotationsLabel.font = UIFont.boldSystemFont(ofSize: textSize)
        }
        
        if (sizeGroup != "small" && sizeGroup != "x86_64") {
            let leftBorder: CGFloat = 10
            let rightBorder: CGFloat = cell.bounds.width - 10
            let topBorder: CGFloat = 52
            let bottomBorder: CGFloat = cell.bounds.height - 18
            
            let horizLine = UIView(frame: CGRect(x: leftBorder,
                                                 y: cell.bounds.height / (1.6),
                                                 width: rightBorder - leftBorder,
                                                 height: 1.5)
            )
            horizLine.backgroundColor = UIColor.init(hex: "B2B2B2")
            cell.addSubview(horizLine)
            
            let vertLine = UIView(frame: CGRect(x: cell.bounds.width / 2,
                                                y: topBorder,
                                                width: 1.5,
                                                height: bottomBorder - topBorder)
            )
            vertLine.backgroundColor = UIColor.init(hex: "B2B2B2")
            cell.addSubview(vertLine)
        } else if (sizeGroup == "small" || sizeGroup == "x86_64") {
            cell.lifeTimeRotationsTitle.text = "Lifetime Spins"
        }
        
        return cell
    }
    
    private func loadHighScoreData() {
        
        Alamofire.request("https://spinny-top.herokuapp.com/api/users/").responseJSON { response in
            
            if let jsonValue = response.result.value {
                let json = JSON(jsonValue)
                for (_,user) in json {
                    let username = user["username"].stringValue
                    if (username != "admin" && username != "itunesuser" && username != "superuser") {
                        let u = User(username: username, token: nil, email: nil)
                        u.max_spin_rps = user["max_spin_rps"]["speed__max"].doubleValue
                        u.max_spin_duration = user["max_spin_duration"]["duration__max"].doubleValue
                        u.max_spin_rotations = user["max_spin_rotations"]["rotations__max"].intValue
                        u.lifetime_rotations = user["lifetime_rotations"]["rotations__sum"].intValue
                        
                        self.users.append(u)
                    }
                    
                    // Fix startTime
//                    let score = Score(username: username!, startTime: Date(), maxSpeed: speed)
//                    self.scores.append(score)
                }
                self.orderUsers(orderBy: "Lifetime")
                self.tableView.reloadData()
                UIViewController.removeSpinner(spinner: self.sv)
            } else {
                print("no JSON object")
            }
        }
    }
    
    func orderUsers(orderBy: String) {
        if orderBy == "Lifetime" {
            users.sort {
                return $0.lifetime_rotations! > $1.lifetime_rotations!
            }
        } else if orderBy == "RPS" {
            users.sort {
                return $0.max_spin_rps! > $1.max_spin_rps!
            }
        } else if orderBy == "Duration" {
            users.sort {
                return $0.max_spin_duration! > $1.max_spin_duration!
            }
        } else if orderBy == "Rotations" {
            users.sort {
                return $0.max_spin_rotations! > $1.max_spin_rotations!
            }
        }
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredUsers = users.filter({( user : User ) -> Bool in
            orderUsers(orderBy: scope)
//            self.tableView.reloadData()
            return user.username.lowercased().contains(searchText.lowercased())
            
        })
        tableView.reloadData()
    }

    func isFiltering() -> Bool {
        return searchController.isActive && (!searchBarIsEmpty())
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
