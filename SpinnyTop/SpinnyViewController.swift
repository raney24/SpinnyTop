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
    
    private var _BASE_REF = Database.database().reference()
    private var _USER_REF = Database.database().reference(withPath: "/users")
    
    let user = Auth.auth().currentUser
    
    var motionManager = CMMotionManager()
    var timer: Timer!
    var gForceMax: Double?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // get maximum force from db
        self._USER_REF.child((self.user?.uid)!).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.gForceMax = value?["high_score"] as? Double
            self.startUpdates()
        })
        
        // Do any additional setup after loading the view.
        self.motionManager.startAccelerometerUpdates()
        
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
            
            
            // check if current gforce is greater than max
            if (gForce > self.gForceMax ?? 0) {
                self.gForceMax = gForce
                
                self._USER_REF.child((self.user?.uid)!).updateChildValues(["high_score": gForce])
            }
            
            self.maxForceLabel.text = String(format: "%.5", self.gForceMax ?? 0.0) // or say "not scored yet"
            
            
        }
        if motionManager.isDeviceMotionAvailable == true {
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
                if let attitude = motion?.attitude {
                    self.gForceLabel.transform = CGAffineTransform(rotationAngle: CGFloat(attitude.yaw))
                }
            }
            
        }
        
    }

    @IBAction func logoutButtonAction(_ sender: Any) {
        if Auth.auth().currentUser != nil {
            do {
                try Auth.auth().signOut()
                // Change Root view controller to spinny navigation controller
                AppManager.sharedInstance.showWelcomeNavCon()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
    }
    
    func degrees(radians: Double) -> Double {
        return 180 * M_PI * radians
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
