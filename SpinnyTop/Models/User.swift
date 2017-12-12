//
//  User.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 11/14/17.
//  Copyright © 2017 Kyle Raney. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class User {
//    var userId: Int
    var username: String
    var token: String?
    var email: String?
    
    init(username: String, token: String?, email: String?) {
//        self.userId = userId
        self.username = username
        self.token = token
        self.email = email
//        UserDefaults.standard.set(token, forKey: "token")
//        UserDefaults.standard.set(username, forKey: "username")
    }
    
    func registerUser(username: String, password: String, email: String) {
        
        let parameters = [
            "username" : username,
            "password" : password
        ]
        
        APIController.sharedController.request(method: .post, URLString: "users/register", parameters : parameters, encoding: JSONEncoding.default, debugPrintFullResponse: true).responseJSON(queue: .main, completionHandler: { (response: DataResponse<Any>) in
            guard let objResponse = response.result.value as? [String: Any] else {
                print("Unable to register user")
                return
            }
            print(objResponse)
            UserDefaults.standard.set(username, forKey: "username")
        })
        
        APIController.sharedController.request(method:.post, URLString: "get-token/", parameters : parameters, encoding: JSONEncoding.default, debugPrintFullResponse: true).responseJSON(queue: .main, completionHandler: { (response:DataResponse<Any>) in
            guard let objResponse = response.result.value as? [String: Any] else {
                print("Didn't get object")
                return
            }
            guard let token = objResponse["token"] as? String else {
                print("No token returned")
                return
            }
            
            UserDefaults.standard.set(token, forKey: "token")
        })
    }
//    func loginWithUsername(username: String, password: String, completion: @escaping ) {
//        let parameters: Parameters = [
//            "username" : username,
//            "password" : password
//        ]
//
//        Alamofire.request("https://spinny-top.herokuapp.com/api/get-token/", method: .post, parameters: parameters, encoding: JSONEncoding.default).responseJSON { response in
//            debugPrint(response)
//            let objResponse = response.result.value
//            print(objResponse)
//
//        }
//    }
}
