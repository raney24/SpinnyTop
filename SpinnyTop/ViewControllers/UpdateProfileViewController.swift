//
//  ProfileViewController.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 8/22/17.
//  Copyright © 2017 Kyle Raney. All rights reserved.
//

import UIKit

import Alamofire
import ObjectMapper

class UpdateProfileViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordAgainTextField: UITextField!
    @IBOutlet weak var errorButton: UIButton!
    
    var fieldsToChange = [String: String]()
    var errorMessages = [String]()
    
    var user = User(
        username: UserDefaults.standard.string(forKey: "username")!,
        token: UserDefaults.standard.string(forKey: "token"),
        email: UserDefaults.standard.string(forKey: "email")
        
    )

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.emailAddressTextField.autocorrectionType = .no
        self.usernameTextField.autocorrectionType = .no
        
        // Set the text fields to the delegate
        self.emailAddressTextField.delegate = self
        self.usernameTextField.delegate = self
//        self.passwordTextField.delegate = self
//        self.passwordAgainTextField.delegate = self
        
        // Hide Errors
        errorButton.isHidden = true

        // Do any additional setup after loading the view.
//        let email = user?.email
//        emailAddressTextField.text = email
        let parameters = [
            "username" : user.username,
            "email" : user.email
        ]
        
        self.usernameTextField.text = user.username
        self.emailAddressTextField.text = user.email
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldEndEditing(_ textFieldToChange: UITextField) -> Bool {
        
        if textFieldToChange == usernameTextField {
            fieldsToChange["username"] = usernameTextField.text
            if usernameTextField.text!.isAlphanumeric {
                self.errorButton.isHidden = true
                errorMessages.append("Please make sure the username field is not blank and contains only letters and numbers")
            } else {
                self.errorButton.isHidden = false
            }
//            if usernameTextField.text != "" {
//                let uid = user?.uid
//                _USER_REF.child("/\(uid!)").observeSingleEvent(of: .value, with: {(snapshot: DataSnapshot) in
//                    let value = snapshot.value as? NSDictionary
//                    let currentUsername = value?["username"] as? String ?? "nothing"
//                    if ( currentUsername == self.usernameTextField.text ) {
//                        self.errorImageView.isHidden = true // Hide the error message
//                    } else if snapshot.value != nil {
//                        self.errorImageView.isHidden = true
//                    } else {
//                        self.errorImageView.isHidden = false
//                    }
//
//                })
//            }

        } else if textFieldToChange == emailAddressTextField {
            fieldsToChange["email"] = emailAddressTextField.text
            if emailAddressTextField.text!.isValidEmail(email: emailAddressTextField.text!) {
//                self.errorButton.isHidden =
//                self.errorMessages.append("Please make sure the email address is a valid email address")
            }
        }
        
        return true
    }
    
    @IBAction func updateUsernameButtonAction(_ sender: Any) {
//        DataService.sharedInstance.updateUser(uid: (self.user?.uid)!, fields: fieldsToChange)
        updateUser(user: user, fields: fieldsToChange)
        
    }
    
    func updateUser(user: User, fields: Dictionary<String, String>) {
        
//        if fields["password"] != nil {
            for (field, val) in fields {
                if field == "username" {
                    user.username = val
                } else if field == "email" {
                    user.email = val
                } else {
                    print("no values entered")
                }
            }
        let parameters: Parameters = [
            "username" : user.username,
            "email" : user.email ?? "",
            "password" : ""
        ]
            APIController.sharedController.request(method: .put, URLString: "users/\(user.username)/", parameters: parameters, encoding: JSONEncoding.default, debugPrintFullResponse: true).responseJSON(queue: .main, completionHandler: { (response: DataResponse<Any>) in
                guard let objResponse = response.result.value as? [String : Any] else {
                    print("No return")
                    return
                }
                print(objResponse)
            })
        //} else {
            // TODO: make password error
            //print("must enter password")
        //}
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func errorButtonTapped(_ sender: Any) {
        var message: String = ""
        for (i, msg) in errorMessages.enumerated() {
            message += "\(i). \(msg) \n"
        }
        self.alert(message: message, title: "Field Errors")
    }
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
