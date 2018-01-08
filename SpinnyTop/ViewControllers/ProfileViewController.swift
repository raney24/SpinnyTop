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
        
        if let user = AppManager.sharedInstance.user {
            self.recordRPSLabel.text = String(format: "%.2f", (user.max_spin_rps) ?? 0.0)
            self.recordRotationsLabel.text = String(format: "%d", (user.max_spin_rotations) ?? 0)
            self.recordDurationLabel.text = String(format: "%.2f", (user.max_spin_duration) ?? 0.0)
            self.lifetimeRotationsLabel.text = String(format: "%d", (user.lifetime_rotations) ?? 0)
            
//
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
