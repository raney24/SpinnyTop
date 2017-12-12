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
    @IBOutlet weak var shapeView: UIView!
    
    
    var circlePath = UIBezierPath()
    var circleLayer = CAShapeLayer()
    var currentCirclePath: UIBezierPath!
    var nextCirclePath: UIBezierPath!
    
    
    @IBAction func hideCircleButtonTapped(_ sender: Any) {
        shapeView.isHidden = true
    }
    
    var motionManager = CMMotionManager()
    var timer: Timer!
    var maxGForce: Double?
    var avgSpinSpeedArray = [Double]()
    var avgRPSArray = [Double]()
    var avgLinVelArray = [Double]()
    
    @IBOutlet weak var angularRotationsLabel: UILabel!
    var spin: Score? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        shapeView.isHidden = true
        self.drawCircle()
        // get maximum force from db if username exists (logged in)
        guard let username = UserDefaults.standard.string(forKey: "username") else {
            AppManager.sharedInstance.showWelcomeNavCon()
            return
        }
        APIController.sharedController.request(method:.get, URLString: "users/\(username)/", encoding: JSONEncoding.default, debugPrintFullResponse: true).responseJSON(queue: .main, completionHandler: { (response:DataResponse<Any>) in
            if let jsonValue = response.result.value as? [String: Any] {
                let json = JSON(jsonValue)
                let max_spin = json["max_spin"]["speed__max"].doubleValue
                self.maxGForce = max_spin
                self.startUpdates()
            } else {
                print("no speed logged")
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
            
//            let gForce = ( ( pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2) ) / 9.81 ).squareRoot()
//            let gForce = (pow(acceleration.x, 2) + pow(acceleration.y, 2) + pow(acceleration.z, 2)).squareRoot()
            let rad = (80 * Double.pi * 2) / 180
            let accelX = cos(rad) * acceleration.x
            let accelY = sin(rad) * acceleration.y
            let gForce = ( pow(accelX, 2) + pow(accelY, 2) ).squareRoot()
            
//            let attitude = accelerometerData.attitude
            self.gForceLabel.text = String(format: "%.2f", gForce)
            
            // start tracking current spin
            if (gForce > G_FORCE_MIN && abs(acceleration.z) > 0.8) {
                // initialize spin
                if (self.spin == nil) {
                    
                    self.spin = Score(username: "admin", startTime: Date())
                    self.spin?.maxSpeed = gForce
                } else {
                    
                    // calc avg spin speed
                    let accel = gForce * 9.80665
                    let linVel = (accel * PHONE_RADIUS).squareRoot()
                    let rps = linVel / (2 * Double.pi * PHONE_RADIUS)
                    self.avgRPSArray.append(rps)
                    
                    // Draw the circle
                    if gForce > 1.5 {
                        self.shapeView.isHidden = false
                        self.animateCircle(radius: Double(gForce))
                    }
                    
                    // update gForce for the spin
                    if (gForce > self.spin!.maxSpeed) {
                        self.spin?.maxSpeed = gForce
                    }
                }
            } else { // Spin has finished (reached less than G_FORCE_MIN)
                self.shapeView.isHidden = true
                if (self.spin != nil) {
                    // finalize duration
                    self.spin?.duration = Date().timeIntervalSince((self.spin?.startTime)!)
                    if (self.spin!.duration! > 1) {
                        
                        // calc rpm here
                        let avgLinVel = self.avgRPSArray.average
                        let revs = avgLinVel * self.spin!.duration!
//                        self.spin!.revolutions = Int(revs * 1.5) // need to fix this
                        self.spin!.revolutions = Int(revs)
                    
                        // call api and save spin
                        let parameters: Parameters = [
                            "username" : UserDefaults.standard.string(forKey: "username") ?? "invalid",
                            "speed" : Double(round(100 * (self.spin?.maxSpeed)!)/100),
                            "duration" : Double(round(100 * (self.spin?.duration)!)/100),
                            "rotations" : self.spin?.revolutions
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
                        self.rotationLabel.text = "\(String(describing: (self.spin?.revolutions)!))"
                    
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
//                    print(CGFloat(attitude.yaw))
                }
            }
        }
    }

    @IBAction func logoutButtonAction(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "token")
        AppManager.sharedInstance.showWelcomeNavCon()
    }
    
    func degrees(radians: Double) -> Double {
        return 180 * Double.pi * radians
    }
    
    func drawCirclePath(radius: Double) -> UIBezierPath {
        let centerX = shapeView.bounds.width / 2
        let centerY = shapeView.bounds.height / 2
        
        let path = UIBezierPath(arcCenter: CGPoint(x: centerX, y: centerY), radius: CGFloat(radius), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        
        return path
    }
    
    func animateCircle(radius: Double) {
        
        let newPath = drawCirclePath(radius: radius * 35)
        let animation = CABasicAnimation(keyPath: "path")
        
        //        animation.fromValue = circlePath.cgPath
        animation.toValue = newPath.cgPath
        
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        
        circleLayer.add(animation, forKey: nil)
        
    }
    
    func drawCircle() {
        circleLayer.fillColor = UIColor.blue.cgColor
        
        let centerX = shapeView.bounds.width / 2
        let centerY = shapeView.bounds.height / 2
        let circleRadius = 55
        circlePath = UIBezierPath(arcCenter: CGPoint(x: centerX, y: centerY), radius: CGFloat(circleRadius), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        circleLayer.path = circlePath.cgPath
        shapeView.layer.addSublayer(circleLayer)
        
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
