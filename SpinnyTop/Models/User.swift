//
//  User.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 11/14/17.
//  Copyright © 2017 Kyle Raney. All rights reserved.
//

import Foundation
import Alamofire

class User {
//    var userId: Int
    var username: String
    var token: String?
    
    init(username: String, token: String) {
//        self.userId = userId
        self.username = username
        self.token = token
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
