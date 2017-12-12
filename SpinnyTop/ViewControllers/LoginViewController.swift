//
//  LoginViewController.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 8/21/17.
//  Copyright © 2017 Kyle Raney. All rights reserved.
//

import Foundation
import Firebase
//import FirebaseAuth
//import FBSDKLoginKit
import Alamofire
import ObjectMapper

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(ViewController.update), userInfo: nil, repeats: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginButtonAction(_ sender: Any) {
        if self.emailTextField.text == "" || self.passwordTextField.text == "" {
            let alertController = UIAlertController(title: "Error", message: "Please enter an email and password", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            self.present(alertController, animated: true, completion: nil)
        } else {
            let username = self.emailTextField.text!
            let password = self.passwordTextField.text!
            
            let parameters: Parameters = [
                "username" : username,
                "password" : password
            ]
            
            APIController.sharedController.request(method:.post, URLString: "get-token/", parameters : parameters, encoding: JSONEncoding.default, debugPrintFullResponse: true).responseJSON(queue: .main, completionHandler: { (response:DataResponse<Any>) in
                guard let objResponse = response.result.value as? [String: Any] else {
                    print("Didn't get object")
                    return
                }
                guard let token = objResponse["token"] as? String else {
                    print("No token returned")
                    return
                }
                
                AppManager.sharedInstance.showSpinnyNavCon()
            })
        }
    }
    
//    @IBAction func loginWithFacebookAction(_ sender: Any) {
//        let fbLoginManager = FBSDKLoginManager()
//        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email"], from: self) { (result, error) in
//            if let error = error {
//                print("Failed to login: \(error.localizedDescription)")
//                return
//            }
//            guard let accessToken = FBSDKAccessToken.current() else {
//                print("Failed to get access token")
//                return
//            }
//
//            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
//
//            Auth.auth().signIn(with: credential, completion: { (user, error) in
//                if let error = error {
//                    print("Login Error: \(error.localizedDescription)")
//                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
//                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//
//                    alertController.addAction(okayAction)
//                    self.present(alertController, animated: true, completion: nil)
//
//                    return
//                }
//                AppManager.sharedInstance.showSpinnyNavCon()
//            })
//        }
//    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        var homeVC: HomeViewController = segue.destination as! HomeViewController
//        homeVC
        
    }
    
    
}
