//
//  SpinnyVideoViewController.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 4/13/18.
//  Copyright © 2018 Kyle Raney. All rights reserved.
//

import Foundation
import UIKit
import CoreMotion
import simd
import Alamofire
import SwiftyJSON
import AVFoundation
import AVKit
import WebKit

class SpinnyVideoViewController: UIViewController, WKUIDelegate {
    
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    
    var motionManager = CMMotionManager()
    var timer: Timer!
    var stopTimer: Int! = 0
    
    
    @IBAction func videoButtonPressed(_ sender: Any) {
        playLocalVideo()
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.checkPhoneSpeed()
        
        
        
    }
    
    func checkPhoneSpeed() {
        motionManager.accelerometerUpdateInterval = UPDATE_INTERVAL
        motionManager.showsDeviceMovementDisplay = true
        motionManager.startAccelerometerUpdates(to: .main) { accelerometerData, error in
            guard let accelerometerData = accelerometerData else { return }
            
            let acceleration: double3 = [accelerometerData.acceleration.x, accelerometerData.acceleration.y, accelerometerData.acceleration.z]
            
            let rad = (80 * Double.pi * 2) / 180
            let accelX = cos(rad) * acceleration.x
            let accelY = sin(rad) * acceleration.y
            let rps = ( pow(accelX, 2) + pow(accelY, 2) ).squareRoot()
            
            if (rps < G_FORCE_MIN) {
                self.stopTimer = self.stopTimer + 1
            }
            
            if (rps > G_FORCE_MIN && self.stopTimer < 15) {
                self.playLocalVideo()
            }
        }
    }
    
    func playLocalVideo() {
        let videoPath = Bundle.main.url(forResource: "kaleidoscope", withExtension: "mp4")
        avPlayer = AVPlayer(url: videoPath!)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        avPlayer.volume = 0
        avPlayer.actionAtItemEnd = .none
        self.tabBarController?.tabBar.isHidden = true
        avPlayerLayer.frame = view.bounds
        view.backgroundColor = .clear
        
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        avPlayer.play()
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
