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
            self.displayError(nil, errorString: "Email is missing...")
            return
            
        } catch InputError.InvalidEmail {
            self.displayError(nil, errorString: "Incorrect email format...")
            return
            
        } catch InputError.MissingPassword {
            self.displayError(nil, errorString: "Password is missing...")
            return
        } catch {
            // Shouldnt happen
            return
        }
        
        for textField in textFieldArray {
            textField.resignFirstResponder()
        }
        
        self.showLoadingView(true)
        
        UdacityClient.sharedInstance().authenticateWithViewController(self, username: emailTextField.text, password: passwordTextField.text) { (success, error, errorString) -> Void in
            if success {
                self.showLoadingView(false)
                self.completeLogin()
            } else {
                self.showLoadingView(false)
                self.displayError(error, errorString: errorString)
            }
        }
    }
    
    // LoginViewController
    func completeLogin() {
        dispatch_async(dispatch_get_main_queue(), {
            self.errorTextLabel.text = ""
            let controller = self.storyboard!.instantiateViewControllerWithIdentifier("OnTheMapNavController") as! UINavigationController
            
            self.showLoadingView(false)
            
            self.presentViewController(controller, animated: true, completion: nil)
        })
    }
    
    func displayError(error: NSError?, errorString: String?) {
        dispatch_async(dispatch_get_main_queue(), {
            
            // http://stackoverflow.com/questions/27987048/shake-animation-for-uitextfield-uiview-in-swift
            let animation = CABasicAnimation(keyPath: "position")
            animation.duration = 0.02
            animation.repeatCount = 4
            animation.autoreverses = true
            animation.fromValue = NSValue(CGPoint: CGPointMake(self.view.center.x - 10, self.view.center.y))
            animation.toValue = NSValue(CGPoint: CGPointMake(self.view.center.x + 10, self.view.center.y))
            self.view.layer.addAnimation(animation, forKey: "position")
            
            if let errorString = errorString {
                self.errorTextLabel.text = errorString
                if let error = error {
                    if error.domain == "badCredentials" {
                        let alertController = UIAlertController(title: "Error", message: "You have entered wrong credentials. Please try again", preferredStyle: UIAlertControllerStyle.Alert)
                        let dismissAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil)
                        alertController.addAction(dismissAction)
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
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
