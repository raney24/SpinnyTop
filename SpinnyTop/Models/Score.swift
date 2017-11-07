//
//  Meal.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 11/6/17.
//  Copyright © 2017 Kyle Raney. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class Score {
    var userId: String
    var topSpeed: Double
    var username: String?
    
    init(userId: String, topSpeed: Double) {
        self.userId = userId
        self.topSpeed = topSpeed
//        self.username = "username"
        
    }
    
    func fetchUsername(completion: @escaping (_ username: String) -> Void) {
        let ref = Database.database().reference(withPath: "/users")
        //        let username =
        ref.child("/\(userId)").observe(.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            guard let username = value?["username"] as? String else {
                return
            }
            self.username = username
            completion(username)
        })
    }
}
