//
//  DataService.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 8/24/17.
//  Copyright © 2017 Kyle Raney. All rights reserved.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase

class DataService {
    static let sharedInstance = DataService()
    
    private var _BASE_REF = Database.database().reference()
    private var _USER_REF = Database.database().reference(withPath: "/users")
    
    func createNewAccount(uid: String, user: Dictionary<String, Any>) {
        _USER_REF.child("/\(uid)").setValue(user)
    }
    
    func updateUser(uid: String, fields: Dictionary<String, String>) {
        let user = Auth.auth().currentUser
        if fields["username"] != nil {
            _USER_REF.queryOrdered(byChild: "username").queryEqual(toValue: fields["username"]).observeSingleEvent(of: .value, with: {(snapshot: DataSnapshot) in
                if snapshot.exists() {
                    let alertController = UIAlertController(title: "Error", message: "Username already exists", preferredStyle: .alert)
                } else {
                    self._USER_REF.child("/\(uid)").updateChildValues(["username" : fields["username"] ?? "Provide a username"])
                }
            })
        }
    }
//    func getUsername(uid: String) -> String {
//        _USER_REF.child("/\(uid)").observe(.value, with: { (snapshot) in
//            let value = snapshot.value as? NSDictionary
//            let username = value?["username"] as? String ?? "no name"
//        }) { (error) in
//            print(error.localizedDescription)
//        }
//        return username
//    }
    
}
