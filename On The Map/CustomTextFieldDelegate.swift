//
//  CustomTextFieldDelegate.swift
//  On The Map
//
//  Created by Marcus Ronélius on 2015-10-21.
//  Copyright © 2015 Ronelium Applications. All rights reserved.
//

import Foundation
import UIKit

class CustomTextFieldDelegate : NSObject, UITextFieldDelegate {
    
    var loginVC: LoginViewController?
    var currentTextField = UITextField()
    var keyboardVisible = false
    
    
    override init() {
        super.init()
        
        // Subscribe to keyboard notifications
        subscribeToNotifications()
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        
        // Assign currentTextField property the current textField, we do this so that we can access the property later on in this class
        currentTextField = textField
        
        // Removing constraints. Otherwise the element  will "pop" back when its becoming first responder. This is due to autolayout. This will throw some errors in the console but still works properly
        currentTextField.removeConstraints(currentTextField.constraints)
        currentTextField.translatesAutoresizingMaskIntoConstraints = true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        keyboardVisible = false
        
        if textField.tag == 0 {
            loginVC!.passwordTextField.becomeFirstResponder()
        }
        else if textField.tag == 1 {
            loginVC!.loginButtonTapped(self)
        }
        /*
        if textField.tag == 0 {
        self.loginVC.emailTextField = currentTextField
        }
        else if textField.tag == 1 {
        self.loginVC.passwordTextField = currentTextField
        }
        */
        
        return true
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if !keyboardVisible {
            keyboardVisible = true
            // Change currentTextFields superview's view (view of CreateMemeViewController) only if keyboard hids the currentTextFields frame
            if textFieldIsHiddenByKeyboard(notification) {
                // This will make the view go up together with the keyboard
                currentTextField.superview!.superview?.superview?.frame.origin.y -= getKeyboardHeight(notification)
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        // This method checks if viewcontrollers view is not in its original y position (which essentially means that it has been moved in methodkeyboardWillShow:. If its not, we can safetly move it back
        
        let parentViewFrame = currentTextField.superview!.superview?.frame.origin.y
        let windowOriginFrame = currentTextField.superview!.superview?.superview?.frame.origin.y
        
        if !(parentViewFrame == windowOriginFrame) {
            currentTextField.superview!.superview?.superview?.frame.origin.y += getKeyboardHeight(notification)
            keyboardVisible = false
        }
    }
    
    
    func textFieldIsHiddenByKeyboard(notification: NSNotification) -> Bool {
        let textFieldRect = currentTextField.superview?.frame
        //textFieldRect.origin.x = 0 // For some reason, textFields y origin is -9. This will break CGRectContainsPoint function
        
        if let dict = notification.userInfo {
            // Get the CGRect of the keyboardFrame provided by NSNotification object
            var keyboardFrame: CGRect = (dict[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
            
            keyboardFrame.origin.y -= 100
            
            // If active text field will be hidden by keyboard then return true, if not, return false
            if (CGRectContainsPoint(keyboardFrame, textFieldRect!.origin)) {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        // Notification has a dictionary (userInfo) where we can grab the cgrect-position of the keyboard when its fully up.
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        
        return keyboardSize.CGRectValue().height - 20
    }
    
    func subscribeToNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeToNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    deinit {
        unsubscribeToNotifications()
    }

}