//
//  ProfileViewController.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 8/22/17.
//  Copyright © 2017 Kyle Raney. All rights reserved.
//

import UIKit

import Firebase
import FirebaseAuth
import FirebaseDatabase

class ProfileViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordAgainTextField: UITextField!
    
    let user = FIRAuth.auth()?.currentUser
    var fieldsToChange = [String: String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the text fields to the delegate
        self.emailAddressTextField.delegate = self
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.passwordAgainTextField.delegate = self

        // Do any additional setup after loading the view.
        let email = user?.email
        emailAddressTextField.text = email
        let uid = user?.uid
        FIRDatabase.database().reference(withPath: "/users").child("/\(uid!)").observe(.value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            guard let username = value?["username"] as? String else {
                return
            }
            self.usernameTextField.text = username
        }) { (error) in
            print(error.localizedDescription)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldEndEditing(_ textFieldToChange: UITextField) -> Bool {
        
        if textFieldToChange == emailAddressTextField {
            fieldsToChange["email"] = emailAddressTextField.text
        } else if textFieldToChange == usernameTextField {
            fieldsToChange["username"] = usernameTextField.text
        } else if textFieldToChange == passwordTextField {
            
        }
        
        
        
        return true
    }
    
    @IBAction func updateProfileButtonAction(_ sender: Any) {
    }
    @IBAction func updateUsernameButtonAction(_ sender: Any) {
        DataService.sharedInstance.updateUser(uid: (self.user?.uid)!, fields: fieldsToChange)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
