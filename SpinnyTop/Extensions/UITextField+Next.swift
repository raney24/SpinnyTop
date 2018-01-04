//
//  ViewController.swift
//  PrevNextForm
//
//  Created by Bear Cahill on 7/28/17.
//  Copyright © 2017 Brainwash Inc. All rights reserved.
//

import UIKit

var tbKeyboard : UIToolbar?
var tfLast : UITextField?

extension UIViewController : UITextFieldDelegate {
    
    // set all of the UITextFields' delegate to the view controller (self)
    // if no view is passed in, start w/ the self.view
    func prepTextFields(inView view : UIView? = nil) {
        
        // cycle thru all the subviews looking for text fields
        for v in view?.subviews ?? self.view.subviews {
            
            if let tf = v as? UITextField {
                // set the delegate and return key to 'Next'
                tf.delegate = self
                tf.returnKeyType = .next
                // save the last text field for later
                if tfLast == nil || tfLast!.tag < tf.tag {
                    tfLast = tf
                }
            }
            else if v.subviews.count > 0 { // recursive
                prepTextFields(inView: v)
            }
        }
        
        // Set the last text field's return key to 'Send'
        // * view == nil - only do this on the end of
        // the original call (not recursive calls)
        if view == nil {
            tfLast?.returnKeyType = .send
            tfLast = nil
        }
    }
    
    // make the first UITextField (tag=0) the first responder
    // if no view is passed in, start w/ the self.view
//    func firstTFBecomeFirstResponder(view : UIView? = nil) {
//        for v in view?.subviews ?? self.view.subviews {
//            if v is UITextField, v.tag == 0 {
//                (v as! UITextField).becomeFirstResponder()
//            }
//            else if v.subviews.count > 0 { // recursive
//                firstTFBecomeFirstResponder(view: v)
//            }
//        }
//    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        // if there's no tool bar, create it
        if tbKeyboard == nil {
            tbKeyboard = UIToolbar.init(frame: CGRect.init(x: 0, y: 0,
                                                           width: self.view.frame.size.width, height: 44))
            let bbiPrev = UIBarButtonItem.init(title: "Previous",
                                               style: .plain, target: self, action: #selector(doBtnPrev))
            let bbiNext = UIBarButtonItem.init(title: "Next", style: .plain,
                                               target: self, action: #selector(doBtnNext))
            let bbiSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                            target: nil, action: nil)
            let bbiSubmit = UIBarButtonItem.init(title: "Submit", style: .plain,
                                                 target: self, action: #selector(UIViewController.doBtnSubmit))
            tbKeyboard?.items = [bbiPrev, bbiNext, bbiSpacer, bbiSubmit]
        }
        
        // set the tool bar as this text field's input accessory view
        textField.inputAccessoryView = tbKeyboard
        return true
    }
    
    // search view's subviews
    // if no view is passed in, start w/ the self.view
    func findTextField(withTag tag : Int,
                       inViewsSubviewsOf view : UIView? = nil) -> UITextField? {
        for v in view?.subviews ?? self.view.subviews {
            
            // found a match? return it
            if v is UITextField, v.tag == tag {
                return (v as! UITextField)
            }
            else if v.subviews.count > 0 { // recursive
                if let tf = findTextField(withTag: tag, inViewsSubviewsOf: v) {
                    return tf
                }
            }
        }
        return nil // not found
    }
    
    // make the next (or previous if next=false) text field the first responder
    func makeTFFirstResponder(next : Bool) -> Bool {
        
        // find the current first responder (text field)
        if let fr = self.view.findFirstResponder() as? UITextField {
            
            // find the next (or previous) text field based on the tag
            if let tf = findTextField(withTag: fr.tag + (next ? 1 : -1)) {
                tf.becomeFirstResponder()
                return true
            }
        }
        return false
    }
    
    @objc func doBtnPrev(_ sender: Any) {
        let _ = makeTFFirstResponder(next: false)
    }
    
    @objc func doBtnNext(_ sender: Any) {
        let _ = makeTFFirstResponder(next: true)
    }
    
    // delegate method
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // when user taps Return, make the next text field first responder
        if makeTFFirstResponder(next: true) == false {
            // if it fails (last text field), submit the form
            submitForm()
        }
        
        return false
    }
    
    @objc func doBtnSubmit(_ sender: Any) {
        submitForm()
    }
    
    @objc func submitForm() {
        self.view.endEditing(true)
        // override me
    }
}

extension UIView {
    
    // go thru this view's subviews and look for the current first responder
    func findFirstResponder() -> UIResponder? {
        
        // if self is the first responder, return it
        // (this is from the recursion below)
        if isFirstResponder {
            return self
        }
        
        for v in subviews {
            if v.isFirstResponder == true {
                return v
            }
            if let fr = v.findFirstResponder() { // recursive
                return fr
            }
        }
        
        // no first responder
        return nil
    }
}



class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // make this view controller the delegate of all the text fields
        prepTextFields()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // make the first form text field the first responder
//        firstTFBecomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func submitForm() {
        super.submitForm()
        // actually submit the form
        print ("Submit")
    }
}
