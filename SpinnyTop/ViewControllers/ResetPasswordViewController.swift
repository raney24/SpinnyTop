//
//  ResetPasswordViewController.swift
//  SpinnyTop
//
//  Created by Kyle Raney on 8/23/17.
//  Copyright © 2017 Kyle Raney. All rights reserved.
//

import UIKit

class ResetPasswordViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func resetPasswordButtonAction(_ sender: Any) {
        if self.emailTextField.text == "" {
            let alertController = UIAlertController(title: "Oops!", message: "Please enter an email.", preferredStyle: .alert)
            
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            alertController.addAction(defaultAction)
            
            present(alertController, animated: true, completion: nil)
            
        } else {
//            Auth.auth().sendPasswordReset(withEmail: self.emailTextField.text!, completion: { (error) in
//                
//                var title = ""
//                var message = ""
//                
//                if error != nil {
//                    title = "Error!"
//                    message = (error?.localizedDescription)!
//                } else {
//                    title = "Success!"
//                    message = "Password reset email sent"
//                    self.emailTextField.text = ""
//                }
//                
//                let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                alertController.addAction(defaultAction)
//                
//                self.present(alertController, animated: true, completion: nil)
//            })
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
