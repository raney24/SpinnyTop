//
//  APIController.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 11/13/17.
//  Copyright © 2017 Kyle Raney. All rights reserved.
//

import Foundation

class APIController {
    func createURLWithString(date: NSDate) -> NSURL? {
        var urlString: String = "https://spinny-top.herokuapp.com/api/"
        
        // append params
        urlString += "spins"
        
        return NSURL(string: urlString)
    }
    
    func createURLWithComponents(components: [String: String]) -> NSURL? {
        let urlComponents = NSURLComponents()
        urlComponents.scheme = "https"
        urlComponents.host = "spinny-top.herokuapp.com"
        urlComponents.path = "/api"
        
        // add params
        for path in components {
            
        }
        return urlComponents.url as! NSURL
    }
    
    enum URLPaths: String {
        case base = "https://spinny-top.herokuapp.com/api/"
        case spins = "https://spinny-top.herokuapp.com/api/spins/"
        case login = "https://spinny-top.herokuapp.com/api/auth/login/"
        case register = "https://spinny-top.herokuapp.com/users/register/"
    }
}
