//
//  AVPlayerLayer+FullScreen.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 9/11/18.
//  Copyright © 2018 Kyle Raney. All rights reserved.
//

import Foundation
import CoreGraphics
import AVKit

extension CGAffineTransform {
    
    static let ninetyDegreeRotation = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
}

extension AVPlayerLayer {
    
    var fullScreenAnimationDuration: TimeInterval {
        return 0.15
    }
    
    func minimizeToFrame(_ frame: CGRect) {
        UIView.animate(withDuration: fullScreenAnimationDuration) {
            self.setAffineTransform(.identity)
            self.frame = frame
        }
    }
    
    func goFullscreen() {
        UIView.animate(withDuration: fullScreenAnimationDuration) {
            self.setAffineTransform(.ninetyDegreeRotation)
            self.frame = UIScreen.main.bounds
        }
    }
}
