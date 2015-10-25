//
//  LoginViewController.swift
//  On The Map
//
//  Created by Marcus Ronélius on 2015-10-06.
//  Copyright © 2015 Ronelium Applications. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    // MARK: Properties
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var errorTextLabel: UILabel!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loadingView: UIVisualEffectView!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    
    var session: NSURLSession!
    var textFieldDelegate = CustomTextFieldDelegate()
    
    enum InputError: ErrorType {
        case MissingEmail
        case InvalidEmail
        case MissingPassword
    }
   
    // Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        /* Get the shared url session */
        session = NSURLSession.sharedSession()
        
        textFieldDelegate.loginVC = self
        emailTextField.delegate = textFieldDelegate
        passwordTextField.delegate = textFieldDelegate
    }
    
    func setCurrentTextField(textField: UITextField) {
        if textField.tag == 0 {
            emailTextField = textField
        } else if textField.tag == 1 {
            passwordTextField = textField
        }
    }
    
    @IBAction func signUpButtonTapped(sender: AnyObject) {
        UIApplication.sharedApplication().openURL(NSURL(string: "https://www.udacity.com/account/auth#!/signup")!)
    }
    // Actions
    @IBAction func loginButtonTapped(sender: AnyObject) {
    
        var textFieldArray = [UITextField]()
        textFieldArray.append(emailTextField)
        textFieldArray.append(passwordTextField)
        
        do {
            for textField in textFieldArray {
                try inputExistAndValidForTextField(textField)
            }
        } catch InputError.MissingEmail {
            self.displayError("Email is missing...")
            return
            
        } catch InputError.InvalidEmail {
            self.displayError("Incorrect email format...")
            return
            
        } catch InputError.MissingPassword {
            self.displayError("Password is missing...")
            return
        } catch {
            // Shouldnt happen
            return
        }
        
        self.showLoadingView(true)
        for textField in textFieldArray {
            textField.resignFirstResponder()
        }
        
        UdacityClient.sharedInstance().authenticateWithViewController(self, username: emailTextField.text, password: passwordTextField.text) { (success, errorString) -> Void in
            if success {
                self.showLoadingView(false)
                self.completeLogin()
            } else {
                self.showLoadingView(false)
                self.displayError(errorString)
            }
        }
    }
    
    func authenticate() {
        
    }
    
    // LoginViewController
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.errorTextLabel.text = ""
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("OnTheMapNavController") as! UINavigationController
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    func displayError(errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            if let errorString = errorString {
                self.errorTextLabel.text = errorString
            }
        })
    }
    
    // Helpers
    func inputExistAndValidForTextField(textField: UITextField) throws {
        if (textField.tag == 0 && textField.text == "") {
            throw InputError.MissingEmail
        }
        if (textField.tag == 0 && !Reachability.isValidEmail(textField.text!)) {
            throw InputError.InvalidEmail
        }
        
        if (textField.tag == 1 && textField.text == "") {
            throw InputError.MissingPassword
        }
        
        /*
        if textField.tag == 0 {
            if emailTextField.text == "" {
                errorTextLabel.text = "Email is missing..."
                return false
            } else if !isValidEmail(emailTextField.text!) {
                errorTextLabel.text = "Incorrect email format..."
                return false
            }
        } else if textField.tag == 1 {
             if passwordTextField.text == "" {
                errorTextLabel.text = "Password is missing..."
                return false
            }
        }
        return true
        */
    }
    
    /* Helper: Show/Hide loading View */
    func showLoadingView(show: Bool) {
        if show {
            dispatch_async(dispatch_get_main_queue(), {
                self.loadingView.hidden = false
                self.loadingIndicator.startAnimating()
            })
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                self.loadingView.hidden = true
                self.loadingIndicator.stopAnimating()
            })
        }
        
    }
    
    
    // TextField Delegates
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        // Tag 0 is email textField
        if textField.tag == 0 {
            self.passwordTextField.becomeFirstResponder()
        }
        // Tag 1 is password textField
        else if textField.tag == 1 {
            self.loginButtonTapped(self)
        }
        
        return true
    }
}
