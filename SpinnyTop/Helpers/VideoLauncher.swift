//
//  VideoLauncher.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 9/6/18.
//  Copyright © 2018 Kyle Raney. All rights reserved.
//

import UIKit
import AVKit

class VideoPlayerView: UIView {
    
    var player: AVPlayer!
    var playerLayer = AVPlayerLayer(player: nil)
    var isPlaying = false
    var hasGoneFullScreen = false
    var originalFrame = CGRect(
        x: (UIScreen.main.bounds.maxX / 2) - 125,
        y: (UIScreen.main.bounds.maxY * 2 / 3) - 125,
        width: 250,
        height: 250
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupPlayerView()
    }
    
    private func setupPlayerView() {
//        backgroundColor = .black
        
        guard let videoPath = Bundle.main.url(forResource: "kaleidoscope", withExtension: "mp4") else {
            debugPrint("video not found")
            return
        }
        
        player = AVPlayer(url: URL(fileURLWithPath: videoPath.path))
        player?.volume = 0
        playerLayer.player = player
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        self.layer.addSublayer(playerLayer)
        playerLayer.frame = self.frame
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder) has not been implemented")
    }
}

class VideoLauncher: NSObject {
     
    var isPlaying = false
    let videoPlayerView = VideoPlayerView(
        frame: CGRect(
            x: (UIScreen.main.bounds.maxX / 2) - 125,
            y: (UIScreen.main.bounds.maxY * 2 / 3) - 125,
            width: 250,
            height: 250
        )
    )
    
    func showVideoPlayer() {
        
//        videoPlayerView.layer.shadowOffset = .zero
//        videoPlayerView.layer.shadowColor = BLUE_COLOR.cgColor
//        videoPlayerView.layer.shadowRadius = 20
//        videoPlayerView.layer.shadowOpacity = 1
//        videoPlayerView.layer.shadowPath = UIBezierPath(rect: videoPlayerView.bounds).cgPath
        
        if let keyWindow = UIApplication.shared.keyWindow {
//            self.videoPlayerView.backgroundColor = .black
            
            keyWindow.addSubview(videoPlayerView)
            
//            let gesture = UITapGestureRecognizer(
//                target: self,
//                action: #selector (highlightVideo (_:))
//            )
//
//            self.videoPlayerView.addGestureRecognizer(gesture)
            self.videoPlayerView.player?.play()

        }
    }
    
    @objc func highlightVideo(_ sender:UITapGestureRecognizer) {
        print("We are here")
    }
    
    func playVideo() {
//        self.videoPlayerView.player?.play()
        self.videoPlayerView.playerLayer.goFullscreen()
    }
    func pauseVideo() {
//        self.videoPlayerView.player?.pause()
        self.videoPlayerView.playerLayer.minimizeToFrame(self.videoPlayerView.originalFrame)
    }
    
    func hideVideoPlayer() {
//        self.videoPlayerView.player?.pause()
//        self.videoPlayerView.removeFromSuperview()
    }
}
