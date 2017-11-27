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
import Alamofire
import SwiftyJSON

class SpinnyViewController: UIViewController {
    
    @IBOutlet weak var gForceLabel: UILabel!
    @IBOutlet weak var maxForceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var rotationLabel: UILabel!
    @IBOutlet weak var userTopSpeedLabel: UILabel!
    
    var motionManager = CMMotionManager()
    var timer: Timer!
    var maxGForce: Double?
    
    var spin: Score? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // get maximum force from db
        let username = UserDefaults.standard.string(forKey: "username")
        APIController.sharedController.request(method:.get, URLString: "users/\(username!)/", encoding: JSONEncoding.default, debugPrintFullResponse: true).responseJSON(queue: .main, completionHandler: { (response:DataResponse<Any>) in
            if let jsonValue = response.result.value as? [String: Any] {
                let json = JSON(jsonValue)
                let max_spin = json["max_spin"]["speed__max"].doubleValue
                self.maxGForce = max_spin
                self.startUpdates()
            }
            
        })
        
        // Do any additional setup after loading the view.
        self.motionManager.startAccelerometerUpdates()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startUpdates() {
        
        motionManager.accelerometerUpdateInterval = UPDATE_INTERVAL
        motionManager.showsDeviceMovementDisplay = true
        motionManager.startAccelerometerUpdates(to: .main) { accelerometerData, error in
            guard let accelerometerData = accelerometerData else { return }
            
            let acceleration: double3 = [accelerometerData.acceleration.x, accelerometerData.acceleration.y, accelerometerData.acceleration.z]
            
            let gForce = (pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2) / 9.81).squareRoot()
            
//            let attitude = accelerometerData.attitude
            self.gForceLabel.text = String(format: "%.2f", gForce)
            
            // start tracking current spin
            if (gForce > G_FORCE_MIN) {
                // initialize spin
                if (self.spin == nil) {
                    
                    self.spin = Score(username: "admin", startTime: Date())
                    self.spin?.maxSpeed = gForce
                } else {
                    print("continuing spin " + String(describing: Date().timeIntervalSince((self.spin?.startTime)!)))
                    // calc revolutions here
                    
                    // update gForce for the spin
                    if (gForce > self.spin!.maxSpeed) {
                        self.spin?.maxSpeed = gForce
                    }
                }
            } else { // Spin has finished (reached less than G_FORCE_MIN)
                if (self.spin != nil) {
                    // finalize duration
                    self.spin?.duration = Date().timeIntervalSince((self.spin?.startTime)!)
                    if (self.spin!.duration! > 1) {
                        
                    
                        // call api and save spin
                        let parameters: Parameters = [
                            "username" : UserDefaults.standard.string(forKey: "username") ?? "invalid",
                            "speed" : Double(round(100 * (self.spin?.maxSpeed)!)/100),
                            "duration" : Double(round(100 * (self.spin?.duration)!)/100),
                            "rotations" : 3// self.spin?.duration,
                        ]
                        APIController.sharedController.request(method:.post, URLString: "spins/", parameters : parameters, encoding: JSONEncoding.default, debugPrintFullResponse: true).responseJSON(queue: .main, completionHandler: { (response:DataResponse<Any>) in
                            guard let jsonResponse = response.result.value else {
                                print("No response from post")
                                return
                            }
                        })
                        
                        // Display last spin
                            // TODO: Make db call to get last spin
                        self.durationLabel.text = String(format: "%.2f", (self.spin?.duration)!)
                        self.maxForceLabel.text = String(format: "%.2f", (self.spin?.maxSpeed)!)
                    
                    }
                    self.spin = nil
                    
                }
            }
            
            self.userTopSpeedLabel.text = String(format: "%.2", self.maxGForce ?? 0.0) // or say "not scored yet"
            
            
        }
        if motionManager.isDeviceMotionAvailable == true {
            motionManager.deviceMotionUpdateInterval = UPDATE_INTERVAL
            motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
                if let attitude = motion?.attitude {
                    self.gForceLabel.transform = CGAffineTransform(rotationAngle: CGFloat(attitude.yaw))
                }
            }
        }
    }

    @IBAction func logoutButtonAction(_ sender: Any) {
        AppManager.sharedInstance.showWelcomeNavCon()
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
