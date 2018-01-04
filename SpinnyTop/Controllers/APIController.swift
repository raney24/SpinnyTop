//
//  APIController.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 11/13/17.
//  Copyright © 2017 Kyle Raney. All rights reserved.
//

import Foundation
import Alamofire

class APIController {
    static let sharedController: APIController = APIController()
    var manager: Alamofire.SessionManager = Alamofire.SessionManager(configuration: URLSessionConfiguration.default)
    
    var requestDictionary: Dictionary<String, Date> = Dictionary()
    
    required init() {
        
    }
    
    func request(
        method: HTTPMethod,
        URLString: String,
        parameters: [String : Any]? = nil,
        encoding: ParameterEncoding = JSONEncoding.default,
        headers: [String : String]? = nil,
        debugPrintFullResponse: Bool = false,
        debugPrintFullRequest: Bool = false
    ) -> Alamofire.DataRequest
    {
        var URLStringToUse: String
        if URLString.lowercased().range(of: "Constants.BASE_URL") == nil {
            URLStringToUse = BASE_URL + URLString
        } else {
            URLStringToUse = URLString
        }
        let URLConvertibleToUse: URLConvertible = URLStringToUse
        
        print(String(format: "requesting %@", URLStringToUse))
        
        if parameters != nil {
            print(String(format: "params: %@", parameters!))
        }
        
        let headersToUse: [String : String] = self.headersWithUserSettings(headers: headers)
        
        let backgroundQueue: DispatchQueue = APIController.getBackgroundQueue()
        
        let request: Alamofire.DataRequest = manager.request(URLConvertibleToUse, method: method, parameters: parameters, encoding: encoding, headers: headersToUse).responseString(queue: backgroundQueue, completionHandler: {
            (response: DataResponse<String>) in
            
            if (response.result.isSuccess) {
                if let value = response.result.value {
                    let maxOutputLength: Int = (debugPrintFullResponse ? Int.max : 30)
                    
                    print(String(format: "request %@ successful. Response (%i chars):\n%@\n", URLStringToUse, value.count, (value.count > maxOutputLength ? value.prefix(maxOutputLength) + "..." : value)))
                } else {
                    print(String(format: "request %@ successful. NO VALUE", URLStringToUse))
                }
            } else {
                if let error = response.result.error {
                    print(String(format: "request %@ failed. Error:\n%@", URLStringToUse, error.localizedDescription))
                } else {
                    print(String(format: "request %@ failed. NO ERROR SPECIFIED", URLStringToUse))
                }
            }
        })
        if debugPrintFullRequest {
            print("request: " + URLString + "\nBody: ")
            if let httpBodyData: Data = request.request?.httpBody {
                let string = String(data: httpBodyData, encoding: String.Encoding.utf8)
                print(string ?? "encoding error")
            } else {
                print("no request body")
            }
        }
        
        return request
    }
    
    func headersWithUserSettings(headers: [String: String]? = nil) -> [String : String] {
        // add user setting headers
        //var headersToUse: [String : String] = ["header1" : UserSettings.defaultSettings.header1()]
        var headersToUse: HTTPHeaders = [:]
        if let user = AppManager.sharedInstance.user {
            if let token = user.token {
                headersToUse["Authorization"] = "Token \(String(describing: token))"
            }
        }
        
        
//        if let unwrappedHeaders = headers {
//            for tuple in unwrappedHeaders {
//                headersToUse[tuple.0] = tuple.1
//            }
//        }
        return headersToUse
    }
    
    class func getBackgroundQueue() -> DispatchQueue {
        return DispatchQueue.global(qos: .background)
    }
}





