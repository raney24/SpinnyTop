//
//  ProfileViewController.swift
//  
//
//  Created by Kyle Raney on 12/15/17.
//

import UIKit
import Alamofire
import SwiftyJSON

class ProfileViewController: UIViewController {
    @IBOutlet weak var viewLeaderboardButtonOutlet: RoundedButton!
    
    @IBOutlet weak var recordRotationsLabel: UILabel!
    @IBOutlet weak var recordDurationLabel: UILabel!
    @IBOutlet weak var recordRPSLabel: UILabel!
    @IBOutlet weak var lifetimeRotationsLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.viewLeaderboardButtonOutlet.layer.cornerRadius = 5
        
//        var user = User(
//            username: UserDefaults.standard.string(forKey: "username")!,
//            token: UserDefaults.standard.string(forKey: "token"),
//            email: UserDefaults.standard.string(forKey: "email")
//        )
        
        if let user = AppManager.sharedInstance.user {
            self.recordRPSLabel.text = String(format: "%.2f", (user.max_spin_rps) ?? 0.0)
            self.recordRotationsLabel.text = String(format: "%d", (user.max_spin_rotations) ?? 0)
            self.recordDurationLabel.text = String(format: "%.2f", (user.max_spin_duration) ?? 0.0)
            self.lifetimeRotationsLabel.text = String(format: "%d", (user.lifetime_rotations) ?? 0)
            
//            APIController.sharedController.request(method:.get, URLString: "users/\(user.username)/", encoding: JSONEncoding.default, debugPrintFullResponse: true).responseJSON(queue: .main, completionHandler: { (response:DataResponse<Any>) in
//                if let jsonValue = response.result.value as? [String: Any] {
//                    let json = JSON(jsonValue)
//
//                    let max_spin_rps = json["max_spin_rps"]["speed__max"].doubleValue
//                    let max_spin_duration = json["max_spin_duration"]["duration__max"].doubleValue
//                    let max_spin_rotations = json["max_spin_rotations"]["rotations__max"].intValue
//                    let lifetime_rotations = json["lifetime_rotations"]["rotations__sum"].intValue
//
//                    user.max_spin_rps = max_spin_rps
//                    user.max_spin_rotations = max_spin_rotations
//                    user.max_spin_duration = max_spin_duration
//                    user.lifetime_rotations = lifetime_rotations
//
//                    self.recordRPSLabel.text = String(format: "%.2f", (user.max_spin_rps) ?? 0.0)
//                    self.recordRotationsLabel.text = String(format: "%d", (user.max_spin_rotations) ?? 0)
//                    self.recordDurationLabel.text = String(format: "%.2f", (user.max_spin_duration) ?? 0.0)
//                    self.lifetimeRotationsLabel.text = String(format: "%d", (user.lifetime_rotations) ?? 0)
//                } else {
//                    print("no spins logged")
//                }
//
//            })
        } else {
            self.alert(message: "Users must be logged in to spin", title: "Please Log in")
            AppManager.sharedInstance.showWelcomeNavCon()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
