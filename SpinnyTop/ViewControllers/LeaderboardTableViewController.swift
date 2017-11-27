//
//  LeaderboardTableViewController.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 11/3/17.
//  Copyright © 2017 Kyle Raney. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseDatabase
import Alamofire
import SwiftyJSON

class LeaderboardTableViewController: UITableViewController {
    
    private var _USER_REF = Database.database().reference(withPath: "/users")
    private var _BASE_REF = Database.database().reference()
    
    var scores = [Score]() // userId, topSpeed

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadHighScoreData()
        
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
        return scores.count
    }
    
    private func loadHighScoreData() {
        
        Alamofire.request("https://spinny-top.herokuapp.com/api/spins/").responseJSON { response in
            
            if let jsonValue = response.result.value {
                let json = JSON(jsonValue)
                for (_,spin) in json {
                    let speed = spin["speed"].doubleValue
                    let username = spin["owner"].string
                    // Fix startTime
                    let score = Score(username: username!, startTime: Date(), maxSpeed: speed)
                    self.scores.append(score)
                }
                self.tableView.reloadData()

            } else {
                print("no JSON object")
            }
        }
        
//        _BASE_REF.child("/spin").queryOrdered(byChild: "/top_speed").observeSingleEvent(of: .value, with: { (snapshot) in
//            for child in snapshot.children {
//                if let scoreDict = (child as! DataSnapshot).value as? [String: AnyObject] {
//                    let uid = scoreDict["user_id"] as? String
//                    let topspd = (scoreDict["top_speed"] as? NSNumber)?.doubleValue
////                    self.scoresDict[userId!] = topSpeed
//                    let score = Score(userId: uid!, topSpeed: topspd!)
//                    self.scores.append(score)
//
//                    score.fetchUsername() {
//                        (username: String) in
//                        DispatchQueue.main.async {
//                            self.tableView.reloadData()
//                        }
//                    }
//                }
//            }
//            self.tableView.reloadData()
//        })
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "scoreCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        
        let currentScore = scores[indexPath.row]
        cell.textLabel?.text = currentScore.username
        cell.detailTextLabel?.text = String(currentScore.maxSpeed)

        return cell
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