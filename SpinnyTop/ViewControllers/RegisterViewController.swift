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
        
        // Do any additional setup after loading the view.
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
                "password" : password
            ]
            
            APIController.sharedController.request(method: .post, URLString: "register/", parameters : parameters, encoding: JSONEncoding.default, debugPrintFullResponse: true).responseJSON(queue: .main, completionHandler: { (response: DataResponse<Any>) in
                guard let objResponse = response.result.value as? [String: Any] else {
                    print("Unable to register user")
                    return
                }
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
                AppManager.sharedInstance.showSpinnyNavCon()
            })
            
            
            
            
            //            Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            //
            //                if error == nil {
            //                    AppManager.sharedInstance.showSpinnyNavCon()
            //
            //                    let userID = user!.uid
            //                    let myUser = ["provider": user?.providerID ?? "No ID", "email": email, "username": username, "high_score": high_score] as [String : Any]
            //
            //                    DataService.sharedInstance.createNewAccount(uid: userID, user: myUser )
            //                } else {
            //                    let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
            //
            //                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            //                    alertController.addAction(defaultAction)
            //
            //                    self.present(alertController, animated: true, completion: nil)
            //                }
            //
            //            }
        }
    }
    
}

