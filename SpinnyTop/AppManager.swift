//
//  AppManager.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 8/23/17.
//  Copyright © 2017 Kyle Raney. All rights reserved.
//

import Foundation
import UIKit

class AppManager {
    
    static let sharedInstance = AppManager()
    
    init() {
        
    }
    
    func showSpinnyNavCon() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let appDelegate: UIApplicationDelegate? = UIApplication.shared.delegate
        
        let spinnyNavCon: UINavigationController = storyboard.instantiateViewController(withIdentifier: "SpinnyNavCon") as! UINavigationController
        
        if let window = appDelegate?.window {
            window!.rootViewController = spinnyNavCon
            UIView.transition(with: window!, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                window?.rootViewController = spinnyNavCon
            }, completion: nil)
        }
    }
    
    func showWelcomeNavCon() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let appDelegate: UIApplicationDelegate? = UIApplication.shared.delegate
        
        let spinnyNavCon: UINavigationController = storyboard.instantiateViewController(withIdentifier: "WelcomeNavCon") as! UINavigationController
        
        if let window = appDelegate?.window {
            window!.rootViewController = spinnyNavCon
            UIView.transition(with: window!, duration: 0.5, options: .transitionFlipFromLeft, animations: {
                window?.rootViewController = spinnyNavCon
            }, completion: nil)
        }
    }
}
