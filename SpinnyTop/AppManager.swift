//
//  AppManager.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 8/23/17.
//  Copyright © 2017 Kyle Raney. All rights reserved.
//

import Foundation
import UIKit

import SwiftyJSON
import Alamofire

class AppManager {
    
    static let sharedInstance = AppManager()
    
    var user: User? = nil
    
    init() {
        
    }
    
    func createUser(username: String, token: String, onCompletion: @escaping (_ result: Bool) -> Void ) {
        user = User(username: username, token: token, email: nil)
        UserDefaults.standard.set(token, forKey: "token")
        UserDefaults.standard.set(username, forKey: "username")
        var result = false
        APIController.sharedController.request(method:.get, URLString: "users/\(user!.username)/", encoding: JSONEncoding.default, debugPrintFullResponse: false).responseJSON(queue: .main, completionHandler: { (response:DataResponse<Any>) in
            if let jsonValue = response.result.value as? [String: Any] {
                let json = JSON(jsonValue)
                if let currentUser = self.user {
                    currentUser.email = json["email"].string
                    currentUser.max_spin_rps = json["max_spin_rps"]["speed__max"].doubleValue
                    currentUser.max_spin_duration = json["max_spin_duration"]["duration__max"].doubleValue
                    currentUser.max_spin_rotations = json["max_spin_rotations"]["rotations__max"].intValue
                    currentUser.lifetime_rotations = json["lifetime_rotations"]["rotations__sum"].intValue
                    result = true
                } else {
                    print("no user here")
                }
                

            } else {
                print("no spins logged")
                
            }
            onCompletion(result)
        })
    }
    
    func showSpinnyNavCon() {
        let storyboard: UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let appDelegate: UIApplicationDelegate? = UIApplication.shared.delegate
        
        let spinnyNavCon: UITabBarController = storyboard.instantiateViewController(withIdentifier: "SpinnyNavCon") as! UITabBarController
        
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
