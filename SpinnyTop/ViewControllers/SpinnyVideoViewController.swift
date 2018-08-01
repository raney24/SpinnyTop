//
//  SpinnyVideoViewController.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 4/13/18.
//  Copyright © 2018 Kyle Raney. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import AVKit

class SpinnyVideoViewController: UIViewController {

    var avPlayer: AVPlayer!
    @IBOutlet weak var animationLayer: UIView!
    
    var circlePath = UIBezierPath()
    var circleLayer = CAShapeLayer()
    @IBOutlet weak var circleViewLayer: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.drawCircle()
        // Do any additional setup after loading the view.
//        self.animationLayer.layer.cornerRadius = self.animationLayer.frame.size.width / 2
//        self.animationLayer.clipsToBounds = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func animation() {
//        UIView.animate(withDuration: 1, animations: {
////            self.circleLayer.backgroundColor = (BLUE_COLOR as! CGColor)
//            self.circleLayer.frame.size.height -= 15
//            self.circleLayer.frame.size.width -= 15
//        }) {_ in
//            UIView.animate(withDuration: 1, delay: 0.25, options: [.autoreverse, .repeat], animations: {
//                self.circleLayer.frame.size.width += 15
//                self.circleLayer.frame.size.height += 15
//            })
//        }
        
//        let view:UIView = UIView(frame: CGRect(x: 200, y: 200, width: 100, height: 100))
//        view.layer.cornerRadius = 50
//        view.backgroundColor = BLUE_COLOR
//        self.view.addSubview(view)
        
        let scaleAnimation:CABasicAnimation = CABasicAnimation(keyPath: "transform.scale")
        
        scaleAnimation.duration = 0.5
        scaleAnimation.repeatCount = 10.0
        scaleAnimation.autoreverses = true
        scaleAnimation.fromValue = 1.2
        scaleAnimation.toValue = 0.8
        
        circleLayer.add(scaleAnimation, forKey: "scale")
    }
    
    func drawCircle() {
        //        circleLayer.fillColor = UIColor.blue.cgColor
        circleLayer.fillColor = BLUE_COLOR.cgColor
        let centerX = circleViewLayer.bounds.width / 2
        let centerY = circleViewLayer.bounds.height / 2
        let circleRadius = 55
        circlePath = UIBezierPath(arcCenter: CGPoint(x: centerX, y: centerY), radius: CGFloat(circleRadius), startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2), clockwise: true)
        circleLayer.path = circlePath.cgPath
        circleViewLayer.layer.addSublayer(circleLayer)
        
    }
    
    func playFromYoutube() {
        let webView = UIWebView(frame: self.view.frame)
        self.view.addSubview(webView)
        self.view.bringSubview(toFront: webView)
        
        webView.allowsInlineMediaPlayback = true
        webView.mediaPlaybackRequiresUserAction = false
        
        let videoID = "R8GlRWPMwFc"
        let embeddedHTML = "<html><body style='margin:0px;padding:0px;'><script type='text/javascript' src='http://www.youtube.com/iframe_api'></script><script type='text/javascript'>function onYouTubeIframeAPIReady(){ytplayer=new YT.Player('playerId',{events:{onReady:onPlayerReady}})}function onPlayerReady(a){a.target.playVideo();}</script><iframe id='playerId' type='text/html' width='\(self.view.frame.size.width)' height='\(self.view.frame.size.height)' src='https://www.youtube.com/embed/\(videoID)?enablejsapi=1&rel=0&playsinline=1&autoplay' frameborder='0'></body></html>"
        
        webView.loadHTMLString(embeddedHTML, baseURL: Bundle.main.resourceURL)
    }
    
    @IBAction func playButtonPressed(_ sender: Any) {
        animation()
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
