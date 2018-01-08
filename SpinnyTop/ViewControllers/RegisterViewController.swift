//
//  RegisterViewController.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 8/23/17.
//  Copyright © 2017 Kyle Raney. All rights reserved.
//

import UIKit

import Firebase
import FirebaseAuth
//import FBSDKLoginKit
import Alamofire
import ObjectMapper


class RegisterViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepTextFields()
        
        // Do any additional setup after loading the view.
        self.emailTextField.autocorrectionType = .no
        self.usernameTextField.autocorrectionType = .no
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func registerButtonAction(_ sender: Any) {
        // Check for Errors
        if emailTextField.text == "" || usernameTextField.text == "" || passwordTextField.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please Enter your email and password", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
            
        } else { // Register User
            let username = usernameTextField.text!
            let email = emailTextField.text!
            let password = passwordTextField.text!
            
            let parameters = [
                "username" : username,
                "password" : password,
                "email" : email
            ]
            
            APIController.sharedController.request(method: .post, URLString: "register/", parameters : parameters, encoding: JSONEncoding.default, debugPrintFullResponse: false).responseJSON(queue: .main, completionHandler: { (response: DataResponse<Any>) in
                guard let objResponse = response.result.value as? [String: Any] else {
                    print("Unable to register user")
                    return
                }
//                user.username = username
//                user.email = email
                
                
                APIController.sharedController.request(method:.post, URLString: "get-token/", parameters : parameters, encoding: JSONEncoding.default, debugPrintFullResponse: false).responseJSON(queue: .main, completionHandler: { (response:DataResponse<Any>) in
                    guard let objResponse = response.result.value as? [String: Any] else {
                        print("Didn't get object")
                        return
                    }
                    guard let token = objResponse["token"] as? String else {
                        print("No token returned")
                        return
                    }
                    UserDefaults.standard.set(token, forKey: "token")
                    
                    AppManager.sharedInstance.createUser(username: username, token: token) {
                        (result: Bool) in
                        if result {
                            AppManager.sharedInstance.showSpinnyNavCon()
                        } else {
                            print("Not successful")
                        }
                        
                    }
                
                })
            })
        }
    }
    
}

