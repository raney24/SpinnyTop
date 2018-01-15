//
//  UpdatePasswordViewController.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 1/14/18.
//  Copyright © 2018 Kyle Raney. All rights reserved.
//

import UIKit

import Alamofire
import ObjectMapper

class UpdatePasswordViewController: UIViewController {
    @IBOutlet weak var currentPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextFieldOne: UITextField!
    @IBOutlet weak var newPasswordTextFieldTwo: UITextField!
    @IBOutlet weak var errorButtonImage: UIButton!
    
    var user: User!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround()
        self.user = AppManager.sharedInstance.user
        if self.user == nil  {
            AppManager.sharedInstance.showWelcomeNavCon()
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changePasswordButtonPressed(_ sender: Any) {
        
        // check if fields are not empty
        if ( (currentPasswordTextField.text!.isAlphanumeric)
            || (newPasswordTextFieldOne.text!.isAlphanumeric)
            || (newPasswordTextFieldTwo.text!.isAlphanumeric) ) {
            
            // check if new1 = new2
            if (newPasswordTextFieldOne.text == newPasswordTextFieldTwo.text) {
                
                let parameters: Parameters = [
                    "old_password" : currentPasswordTextField.text!,
                    "new_password" : newPasswordTextFieldOne.text!
                ]
                
                APIController.sharedController.request(method: .put, URLString: "users/update/password/\(self.user.username)/", parameters: parameters, encoding: JSONEncoding.default, debugPrintFullResponse: true).responseJSON(queue: .main, completionHandler: { (response: DataResponse<Any>) in
                    guard let objResponse = response.result.value as? String else {
                        print("No return")
                        return
                    }
                    
                    if (objResponse == "Success.") {
                        self.alert(message: "Password successfully changed", title: "Success")
                        AppManager.sharedInstance.showSpinnyNavCon()
                    } else {
                        self.alert(message: "Current Password was incorrect", title: "Error")
                    }
                    
                    
                })
            } else {
                self.alert(message: "New passwords did not match.", title: "Field Error")
            }
        } else {
            self.alert(message: "One or more fields are not correctly formatted.", title: "Field Error")
        }
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
