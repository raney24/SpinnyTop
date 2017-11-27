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
    
    private var _USER_REF = Database.database().reference(withPath: "/users")
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordAgainTextField: UITextField!
    @IBOutlet weak var errorImageView: UIImageView!
    
    let user = Auth.auth().currentUser
    var fieldsToChange = [String: String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()

        
        // Set the text fields to the delegate
        self.emailAddressTextField.delegate = self
        self.usernameTextField.delegate = self
        self.passwordTextField.delegate = self
        self.passwordAgainTextField.delegate = self
        
        // Hide Errors
        errorImageView.isHidden = true

        // Do any additional setup after loading the view.
        let email = user?.email
        emailAddressTextField.text = email
        let uid = user?.uid
        Database.database().reference(withPath: "/users").child("/\(uid!)").observe(.value, with: { (snapshot) in
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
        
        if textFieldToChange == usernameTextField {
            fieldsToChange["username"] = usernameTextField.text
            if usernameTextField.text != "" {
                let uid = user?.uid
                _USER_REF.child("/\(uid!)").observeSingleEvent(of: .value, with: {(snapshot: DataSnapshot) in
                    let value = snapshot.value as? NSDictionary
                    let currentUsername = value?["username"] as? String ?? "nothing"
                    if ( currentUsername == self.usernameTextField.text ) {
                        self.errorImageView.isHidden = true // Hide the error message
                    } else if snapshot.value != nil {
                        self.errorImageView.isHidden = true
                    } else {
                        self.errorImageView.isHidden = false
                    }
                    
                })
            }

        } else if textFieldToChange == passwordTextField {
            
        }
        
        return true
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
