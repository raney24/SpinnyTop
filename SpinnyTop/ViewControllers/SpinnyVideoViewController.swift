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
    
    var motionManager = CMMotionManager()
    var timer: Timer!
    var stopTimer: Int! = 0
    
//    let videoLauncher = VideoLauncher()
    
    
    /* Start of video code */
    var originalFrame1 = CGRect(
        x: (UIScreen.main.bounds.maxX / 2) - 125,
        y: (UIScreen.main.bounds.maxY / 3) - 70,
        width: 250,
        height: 141
    )
    let videoSubview1 = UIView(frame: CGRect(
        x: (UIScreen.main.bounds.maxX / 2) - 125,
        y: (UIScreen.main.bounds.maxY / 3) - 70,
        width: 250,
        height: 141
    ))
    var player1: AVPlayer!
    var playerLayer1 = AVPlayerLayer(player: nil)
    var isSelected1 = false
    
    var originalFrame2 = CGRect(
        x: (UIScreen.main.bounds.maxX / 2) - 125,
        y: (UIScreen.main.bounds.maxY * 2 / 3) - 70,
        width: 250,
        height: 141
    )
    let videoSubview2 = UIView(frame: CGRect(
        x: (UIScreen.main.bounds.maxX / 2) - 125,
        y: (UIScreen.main.bounds.maxY * 2 / 3) - 70,
        width: 250,
        height: 141
    ))
    var player2: AVPlayer!
    var playerLayer2 = AVPlayerLayer(player: nil)
    var isSelected2 = false
    
    
    private func setupPlayerView() {
        
        let gesture1 = UITapGestureRecognizer(
            target: self,
            action: #selector (highlightVideo1 (_:))
        )
        let gesture2 = UITapGestureRecognizer(
            target: self,
            action: #selector (highlightVideo2 (_:))
        )
        
//        if let keyWindow = UIApplication.shared.keyWindow {
//            keyWindow.addSubview(videoSubview1)
//            keyWindow.addSubview(videoSubview2)
//            videoSubview1.addGestureRecognizer(gesture1)
//            videoSubview2.addGestureRecognizer(gesture2)
//        }
        
        self.view.addSubview(videoSubview1)
        self.view.addSubview(videoSubview2)
        videoSubview1.addGestureRecognizer(gesture1)
        videoSubview2.addGestureRecognizer(gesture2)
        
        guard let videoPath = Bundle.main.url(forResource: "kaleidoscope", withExtension: "mp4") else {
            debugPrint("video not found")
            return
        }
        
        player1 = AVPlayer(url: URL(fileURLWithPath: videoPath.path))
        player1?.volume = 0
        playerLayer1.player = player1
        playerLayer1.videoGravity = AVLayerVideoGravity.resizeAspect
        self.view.layer.addSublayer(playerLayer1)
        self.minimizeVideoSubview1()
        
        player2 = AVPlayer(url: URL(fileURLWithPath: videoPath.path))
        player2?.volume = 0
        playerLayer2.player = player2
        playerLayer2.videoGravity = AVLayerVideoGravity.resizeAspect
        self.view.layer.addSublayer(playerLayer2)
        self.minimizeVideoSubview2()
    }
    
    @objc func highlightVideo1(_ sender:UITapGestureRecognizer) {
        if !isSelected1 {
            self.highlightPlayerLayer(playerLayer: self.playerLayer1)
            self.defusePlayerLayer(playerLayer: self.playerLayer2)
            isSelected1 = true
            isSelected2 = false
        } else {
            self.defusePlayerLayer(playerLayer: self.playerLayer1)
            isSelected1 = false
            isSelected2 = false
        }
    }
    
    // For some reason, takes double click to activate?
    @objc func highlightVideo2(_ sender:UITapGestureRecognizer) {
        if !isSelected2 {
            self.highlightPlayerLayer(playerLayer: self.playerLayer2)
            self.defusePlayerLayer(playerLayer: self.playerLayer1)
            isSelected2 = true
            isSelected1 = false
        } else {
            self.defusePlayerLayer(playerLayer: self.playerLayer2)
            isSelected1 = false
            isSelected2 = false
        }
    }
    
    // This will highlight the playerlayer and start the video
    private func highlightPlayerLayer(playerLayer: AVPlayerLayer) {
        playerLayer.shadowOffset = .zero
        playerLayer.shadowColor = BLUE_COLOR.cgColor
        playerLayer.shadowRadius = 20
        playerLayer.shadowOpacity = 1
        playerLayer.shadowPath = UIBezierPath(rect: playerLayer.bounds).cgPath
        playerLayer.player?.play()
    }
    // This will defuse the glow and pause the playerlayer
    private func defusePlayerLayer(playerLayer: AVPlayerLayer) {
        playerLayer.shadowOpacity = 0
        playerLayer.shadowPath = nil
        playerLayer.shadowRadius = 0
        playerLayer.player?.pause()
    }
    
    func playVideo1() {
        self.playerLayer1.player?.play()
    }
    func maximizeVideoSubview1() {
        if self.playerLayer1.player?.rate == 0 {
            self.playVideo1()
        }
        self.playerLayer2.opacity = 0
        self.playerLayer1.goFullscreen()
    }
    func minimizeVideoSubview1() {
        self.playerLayer1.minimizeToFrame(self.originalFrame1)
        self.playerLayer2.opacity = 1
    }
    func pauseVideo1() {
        self.playerLayer1.player?.pause()
    }
    func playVideo2() {
        self.playerLayer2.player?.play()
    }
    func maximizeVideoSubview2() {
        if self.playerLayer2.player?.rate == 0 {
            self.playVideo2()
        }
        self.playerLayer1.opacity = 0
        self.playerLayer2.goFullscreen()
    }
    func minimizeVideoSubview2() {
        self.playerLayer2.minimizeToFrame(self.originalFrame2)
        self.playerLayer1.opacity = 1
    }
    func pauseVideo2() {
        self.playerLayer2.player?.pause()
    }
    
    /* end of video code */
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        setupPlayerView()
        
        self.checkPhoneSpeed()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        motionManager.stopAccelerometerUpdates()
    }
    
    func checkPhoneSpeed() {
        motionManager.accelerometerUpdateInterval = UPDATE_INTERVAL * 10
        motionManager.showsDeviceMovementDisplay = true
        motionManager.startAccelerometerUpdates(to: .main) { accelerometerData, error in
            guard let accelerometerData = accelerometerData else { return }
            
//            self.avPlayer.actionAtItemEnd = .none
            
            let acceleration: double3 = [accelerometerData.acceleration.x, accelerometerData.acceleration.y, accelerometerData.acceleration.z]
            
            let rad = (80 * Double.pi * 2) / 180
            let accelX = cos(rad) * acceleration.x
            let accelY = sin(rad) * acceleration.y
//            let accelY = sin(rad) * acceleration.y
            let rps = ( pow(accelX, 2) + pow(accelY, 2) ).squareRoot()
            
            // add to timer to see if it is a true stop
            if (rps < G_FORCE_MIN) {
                self.stopTimer = self.stopTimer + 1
            }
            
            // start spin video
            if (abs(acceleration.z) > 0.8) {
                if (rps > G_FORCE_MIN && self.stopTimer > 15) {
                    if self.isSelected2 {
                        self.maximizeVideoSubview2()
                    } else { // automatically play video 1
                        self.maximizeVideoSubview1()
                    }
                    
//                    self.playVideo2()
//                    self.maximizeVideoSubview2()
                
                    // disable idle timer
                    UIApplication.shared.isIdleTimerDisabled = true
                } else {
                    if self.isSelected2 {
                        self.minimizeVideoSubview2()
                    } else {
                        self.minimizeVideoSubview1()
                    }
//                    self.pauseVideo1()
//                    self.minimizeVideoSubview1()
//                    self.pauseVideo2()
//                    self.minimizeVideoSubview2()
                }
            }
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
