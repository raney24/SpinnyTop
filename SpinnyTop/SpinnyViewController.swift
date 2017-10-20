//
//  SpinnyViewController.swift
//  
//
//  Created by Kyle Raney on 8/22/17.
//
//

import UIKit
import CoreMotion
import simd
import Firebase
import FirebaseAuth

class SpinnyViewController: UIViewController {
    
    @IBOutlet weak var gForceLabel: UILabel!
    @IBOutlet weak var maxForceLabel: UILabel!
    
    
    var motionManager = CMMotionManager()
    var timer: Timer!
    var gForceMax = 0.0
    
    let user = FIRAuth.auth()?.currentUser

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.motionManager.startAccelerometerUpdates()
        startUpdates()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startUpdates() {
        
        motionManager.accelerometerUpdateInterval = 0.25
        motionManager.showsDeviceMovementDisplay = true
        motionManager.startAccelerometerUpdates(to: .main) { accelerometerData, error in
            guard let accelerometerData = accelerometerData else { return }
            
            let acceleration: double3 = [accelerometerData.acceleration.x, accelerometerData.acceleration.y, accelerometerData.acceleration.z]
            
            let gForce = (pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2) / 9.81).squareRoot()
            self.gForceLabel.text = String(format: "%.5f", gForce)
            
            if (gForce > self.gForceMax) {
                self.gForceMax = gForce
//                print(self.gForceMax)
                self.maxForceLabel.text = String(format: "Max: %.5f", self.gForceMax)
            }
        }
    }

    @IBAction func logoutButtonAction(_ sender: Any) {
        if FIRAuth.auth()?.currentUser != nil {
            do {
                try FIRAuth.auth()?.signOut()
                // Change Root view controller to spinny navigation controller
                AppManager.sharedInstance.showWelcomeNavCon()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
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
