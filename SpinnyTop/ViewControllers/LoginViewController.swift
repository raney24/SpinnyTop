//
//  LoginViewController.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 8/21/17.
//  Copyright © 2017 Kyle Raney. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper

class LoginViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepTextFields()
        
//        emailTextField.delegate = self
//        emailTextField.tag = 0
//        passwordTextField.delegate = self
//        passwordTextField.tag = 1
        
        // disable autocorrect for email field
        emailTextField.autocorrectionType = .no
        // tap anywhere to exit editing
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self.view, action: Selector("endEditing:")))
    }
    
    
    override func submitForm() {
        super.submitForm()
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
            let sv = UIViewController.displaySpinner(onView: self.view)

            let username = self.emailTextField.text!
            let password = self.passwordTextField.text!
            
            let parameters: Parameters = [
                "username" : username,
                "password" : password
            ]
            
            APIController.sharedController.request(method: .post, URLString: "get-token/", parameters : parameters, encoding: JSONEncoding.default, debugPrintFullResponse: false).responseJSON(queue: .main, completionHandler: { (response:DataResponse<Any>) in
                guard let objResponse = response.result.value as? [String: Any] else {
                    print("Didn't get object")
                    return
                }
                guard let token = objResponse["token"] as? String else {
                    self.alert(message: "Credentials incorrect", title: "Server Error")
                    UIViewController.removeSpinner(spinner: sv)
                    return
                }
                
                AppManager.sharedInstance.createUser(username: username, token: token) {
                    (result: Bool) in
                    if result {
                        UIViewController.removeSpinner(spinner: sv)
                        AppManager.sharedInstance.showSpinnyNavCon()
                    } else {
                        print("Not successful")
                    }
                    
                }
                
//                AppManager.sharedInstance.showSpinnyNavCon()
            })
        }
        func textFieldShouldReturn(_ textField: UITextField) -> Bool
        {
            let nextTag = textField.tag + 1
            let nextResponder = textField.superview?.viewWithTag(nextTag) as UIResponder!
            
            if nextResponder != nil {
                nextResponder?.becomeFirstResponder()
            } else {
                textField.resignFirstResponder()
            }
            return false
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

