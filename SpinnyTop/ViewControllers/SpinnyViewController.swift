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
    
    
    @IBOutlet weak var lifetimeRotationsLabel: UILabel!
    
    @IBOutlet weak var currentRPSLabel: UILabel!
    
    @IBOutlet weak var shapeView: UIView!
    @IBOutlet weak var scoreLabelView: UIView!
    
    @IBOutlet weak var lastSpinRotationsLabel: UILabel!
    @IBOutlet weak var recordRotationsLabel: UILabel!
    
    @IBOutlet weak var lastSpinDurationLabel: UILabel!
    @IBOutlet weak var recordDurationsLabel: UILabel!
    
    @IBOutlet weak var lastSpinRPSLabel: UILabel!
    @IBOutlet weak var recordRPSLabel: UILabel!
    
    var circlePath = UIBezierPath()
    var circleLayer = CAShapeLayer()
    var currentCirclePath: UIBezierPath!
    var nextCirclePath: UIBezierPath!
    
    var motionManager = CMMotionManager()
    var timer: Timer!
    var stopTimer: Int! = 0
    var maxGForce: Double?
    var avgSpinSpeedArray = [Double]()
    var avgRPSArray = [Double]()
    var avgLinVelArray = [Double]()
    var spin: Score? = nil
    var user: User!

    override func viewDidLoad() {
        super.viewDidLoad()
//        shapeView.isHidden = true
        shapeView.alpha = 0
        self.drawCircle()
//        self.drawBorderLines()
        
        self.user = AppManager.sharedInstance.user
        if self.user != nil  {
            
            let sv = UIViewController.displaySpinner(onView: self.view)
            APIController.sharedController.request(method:.get, URLString: "users/\(user.username)/", encoding: JSONEncoding.default, debugPrintFullResponse: false).responseJSON(queue: .main, completionHandler: { (response:DataResponse<Any>) in
                if let jsonValue = response.result.value as? [String: Any] {
                    let json = JSON(jsonValue)
                    
                    self.user.email = json["email"].string
                    self.user.max_spin_rps = json["max_spin_rps"]["speed__max"].doubleValue
                    self.user.max_spin_duration = json["max_spin_duration"]["duration__max"].doubleValue
                    self.user.max_spin_rotations = json["max_spin_rotations"]["rotations__max"].intValue
                    self.user.lifetime_rotations = json["lifetime_rotations"]["rotations__sum"].intValue
                    
//                    var user = AppManager.sharedInstance.user
                    
                    self.recordRPSLabel.text = String(format: "%.2f", (self.user.max_spin_rps) ?? 0.0)
                    self.recordRotationsLabel.text = String(format: "%d", (self.user.max_spin_rotations) ?? 0)
                    self.recordDurationsLabel.text = String(format: "%.2f", (self.user.max_spin_duration) ?? 0.0)
                    self.lifetimeRotationsLabel.text = String(format: "%d", (self.user.lifetime_rotations) ?? 0)
                    
                    UIViewController.removeSpinner(spinner: sv)
                    self.startUpdates()
                } else {
                    print("no spins logged")
                }
                
            })
            
//            user.getUserMax { () in
//                print("all data loaded")
//            }
//
        } else {
            self.alert(message: "Users must be logged in to spin", title: "Please Log in")
            AppManager.sharedInstance.showWelcomeNavCon()
        }
        
        
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
            let rps = ( pow(accelX, 2) + pow(accelY, 2) ).squareRoot()
            
//            let attitude = accelerometerData.attitude
            self.currentRPSLabel.text = "SPIN"
            
            
            // add to timer to see if it is a true stop
            if (rps < G_FORCE_MIN) {
                self.stopTimer = self.stopTimer + 1
            }
            // start tracking current spin
            if (abs(acceleration.z) > 0.8) {
                if ( (rps > G_FORCE_MIN && self.stopTimer < 15) ) {
                    // initialize spin
                    if (self.spin == nil) {
                        
                        self.spin = Score(username: "admin", startTime: Date())
                        self.spin?.maxSpeed = rps
                    } else {
                        
                        // calc avg spin speed
                        let accel = rps * 9.80665
                        let linVel = (accel * PHONE_RADIUS).squareRoot()
                        let rps_fromLinVel = linVel / (2 * Double.pi * PHONE_RADIUS)
                        self.avgRPSArray.append(rps_fromLinVel * 1.5)
                        
                        // Display speed label
                        self.currentRPSLabel.text = String(format: "%.1f", rps)
                        
                        // Draw the circle
                        if rps > 1 {
                            UIView.transition(with: self.shapeView, duration: 0.75, animations: {
                                self.shapeView.alpha = 1
                            }, completion: nil)
    //                        self.scoreLabelView.isHidden = true
    //                        self.shapeView.isHidden = false
                            self.animateCircle(radius: Double(rps))
                        }
                        
                        // update gForce for the spin
                        if (rps > self.spin!.maxSpeed) {
                            self.spin?.maxSpeed = rps
                        }
                        // disable idle timer
                        UIApplication.shared.isIdleTimerDisabled = true
                    }
                } else { // Spin has finished (reached less than G_FORCE_MIN)
                    self.hideCircle()
                    self.stopTimer = 0
                    
    //                self.borderView.isHidden = false
                    UIView.transition(with: self.shapeView, duration: 1, animations: {
                        self.shapeView.alpha = 0
                    }, completion: nil)
                    if (self.spin != nil) {
                        // enable idle timer
                        UIApplication.shared.isIdleTimerDisabled = false
                        // finalize duration
                        self.spin?.duration = Date().timeIntervalSince((self.spin?.startTime)!)
                        
                        if (self.spin!.duration! > 1) {
                            
                            // calc rpm here
                            let avgLinVel = self.avgRPSArray.average
                            let revs = avgLinVel * self.spin!.duration!
    //                        self.spin!.revolutions = Int(revs * 1.5) // need to fix this
                            self.spin!.revolutions = Int(revs)
                            
                            self.user!.lifetime_rotations = self.spin!.revolutions! + self.user!.lifetime_rotations!
                            self.lifetimeRotationsLabel.text = String(format: "%d", (self.user?.lifetime_rotations) ?? 0)
                        
                            // call api and save spin
                            let parameters: Parameters = [
                                "username" : UserDefaults.standard.string(forKey: "username") ?? "invalid",
                                "speed" : Double(round(100 * (self.spin?.maxSpeed)!)/100),
                                "duration" : Double(round(100 * (self.spin?.duration)!)/100),
                                "rotations" : Int(self.spin?.revolutions ?? 0)
                            ]
                            APIController.sharedController.request(method:.post, URLString: "spins/", parameters : parameters, encoding: JSONEncoding.default, debugPrintFullResponse: false).responseJSON(queue: .main, completionHandler: { (response:DataResponse<Any>) in
                                guard let jsonResponse = response.result.value else {
                                    print("No response from post")
                                    return
                                }
                            })
                            
                            // Display last spin
                            // TODO: Make db call to get last spin
                            self.lastSpinDurationLabel.text = String(format: "%.2f", (self.spin?.duration)!)
                            self.lastSpinRPSLabel.text = String(format: "%.2f", (self.spin?.maxSpeed)!)
                            self.lastSpinRotationsLabel.text = "\(String(describing: (self.spin?.revolutions)!))"
                        
                        }
                        self.spin = nil
                        
                    }
                }
            }
            
        }
        if motionManager.isDeviceMotionAvailable == true {
            motionManager.deviceMotionUpdateInterval = UPDATE_INTERVAL
            motionManager.startDeviceMotionUpdates(to: .main) { motion, error in
                if let attitude = motion?.attitude {
                    self.currentRPSLabel.transform = CGAffineTransform(rotationAngle: CGFloat(attitude.yaw))
//                    print(CGFloat(attitude.yaw))
                }
            }
        }
    }

    @IBAction func logoutButtonAction(_ sender: Any) {
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.removeObject(forKey: "token")
        UserDefaults.standard.removeObject(forKey: "email")
        AppManager.sharedInstance.user = nil
        AppManager.sharedInstance.showWelcomeNavCon()
    }
    
    func degrees(radians: Double) -> Double {
        return 180 * Double.pi * radians
    }
    
    // helper function to return new circle path based on radius
    func drawCirclePath(radius: Double) -> UIBezierPath {
        let centerX = shapeView.bounds.width / 2
        let centerY = shapeView.bounds.height / 2
        
        let path = UIBezierPath(arcCenter: CGPoint(x: centerX, y: centerY), radius: CGFloat(radius), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        
        return path
    }
    
    // animates circle based on the radius
    func animateCircle(radius: Double) {
        
        let newPath = drawCirclePath(radius: radius * 35)
        let animation = CABasicAnimation(keyPath: "path")
        
        //        animation.fromValue = circlePath.cgPath
        animation.toValue = newPath.cgPath
        
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        
        circleLayer.add(animation, forKey: nil)
        scoreLabelView.isHidden = true
        
    }
    
    func hideCircle() {
        let newPath = drawCirclePath(radius: 0)
        let animation = CABasicAnimation(keyPath: "path")
        
        animation.toValue = newPath.cgPath
        
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = true
        animation.duration = 1
        
        circleLayer.add(animation, forKey: nil)
        
        scoreLabelView.isHidden = false
        
//        let borderAnimation = CATransition()
//        borderAnimation.type = kCATransitionFade
//        borderAnimation.duration = 1
//        borderView.layer.add(borderAnimation, forKey: nil)
//
//        borderView.isHidden = true
    }
    
    
    // This function is called to initialize our circle, it is only called once
    func drawCircle() {
//        circleLayer.fillColor = UIColor.blue.cgColor
        circleLayer.fillColor = BLUE_COLOR.cgColor
        let centerX = shapeView.bounds.width / 2
        let centerY = shapeView.bounds.height / 2
        let circleRadius = 55
        circlePath = UIBezierPath(arcCenter: CGPoint(x: centerX, y: centerY), radius: CGFloat(circleRadius), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        circleLayer.path = circlePath.cgPath
        shapeView.layer.addSublayer(circleLayer)
        
        
    }
    
//    func drawBorderLines() {
//        let centerX = borderView.bounds.width / 2
//        let centerY = borderView.bounds.height / 2
//        let offset1 = CGFloat(80)
//        let offset2 = CGFloat(50)
//
//        let leftPath = UIBezierPath()
//        leftPath.move(to: CGPoint(x: centerX - offset1, y: centerY))
//        leftPath.addLine(to: CGPoint(x: centerX - offset2, y: centerY))
//
//        let rightPath = UIBezierPath()
//        rightPath.move(to: CGPoint(x: centerX + offset1, y: centerY))
//        rightPath.addLine(to: CGPoint(x: centerX + offset2, y: centerY))
//
//        leftPath.append(rightPath)
//
//        let topPath = UIBezierPath()
//        topPath.move(to: CGPoint(x: centerX, y: centerY + offset1))
//        topPath.addLine(to: CGPoint(x: centerX, y: centerY  + offset2))
//
//        leftPath.append(topPath)
//
//        let bottomPath = UIBezierPath()
//        bottomPath.move(to: CGPoint(x: centerX, y: centerY - offset1))
//        bottomPath.addLine(to: CGPoint(x: centerX, y: centerY  - offset2))
//
//        leftPath.append(bottomPath)
//
//        let borderLayer = CAShapeLayer()
//        borderLayer.path = leftPath.cgPath
//        borderLayer.strokeColor = PINK_COLOR.cgColor
//        borderLayer.lineWidth = 3.0
//
//        borderView.layer.addSublayer(borderLayer)
//
//    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
