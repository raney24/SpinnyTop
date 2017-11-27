//
//  Score.swift
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
    var username: String
    var startTime: Date
    var maxSpeed: Double = 0.0
    var duration: Double?
    var revolutions: Int?
    
    init(username: String, startTime: Date, maxSpeed: Double = 0.0, duration: Double? = nil, revolutions: Int? = nil) {
        self.username = username
        self.startTime = startTime
        self.maxSpeed = maxSpeed
        self.duration = duration
        self.revolutions = revolutions
    }
    
//    func fetchUsername(completion: @escaping (_ username: String) -> Void) {
//        let ref = Database.database().reference(withPath: "/users")
//        //        let username =
//        ref.child("/\(userId)").observe(.value, with: { (snapshot) in
//            let value = snapshot.value as? NSDictionary
//            guard let username = value?["username"] as? String else {
//                return
//            }
//            self.username = username
//            completion(username)
//        })
//    }
}
