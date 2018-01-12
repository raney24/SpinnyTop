//
//  LoadingViewController.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 1/11/18.
//  Copyright © 2018 Kyle Raney. All rights reserved.
//

import UIKit
import AVFoundation

class LoadingViewController: UIViewController {
    
    var avPlayer: AVPlayer!
    var avPlayerLayer: AVPlayerLayer!
    var paused: Bool = false

    override func viewDidLoad() {
//        super.viewDidLoad()
        
        let videoPath = Bundle.main.url(forResource: "SpinnyTopLoading", withExtension: "m4v")
        
        avPlayer = AVPlayer(url: videoPath!)
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        avPlayer.volume = 0
        avPlayer.actionAtItemEnd = .none
        
        avPlayerLayer.frame = view.layer.bounds
        view.backgroundColor = .clear
        view.layer.insertSublayer(avPlayerLayer, at: 0)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerItemDidReachEnd(notification:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
        
        let when = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: when) {
            if let token = UserDefaults.standard.string(forKey: "token") {
                if let username = UserDefaults.standard.string(forKey: "username") {
                    AppManager.sharedInstance.createUser(username: username, token: token) {
                        (result: Bool) in
                        
                        if result {
                            AppManager.sharedInstance.showSpinnyNavCon()
                        } else {
                            
                            print("Not successful")
                        }
                        
                    }
                }
            } else {
                AppManager.sharedInstance.showWelcomeNavCon()
            }
        }
        
        
//        if let user: User = AppManager.sharedInstance.user {
//            AppManager.sharedInstance.showSpinnyNavCon()
//        } else {
//            AppManager.sharedInstance.showWelcomeNavCon()
//        }
        
    }
    
    @objc func playerItemDidReachEnd(notification: Notification) {
        let p: AVPlayerItem = notification.object as! AVPlayerItem
        p.seek(to: kCMTimeZero)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        avPlayer.play()
        paused = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        avPlayer.pause()
        paused = true
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
