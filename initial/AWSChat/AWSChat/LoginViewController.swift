//
//  LoginViewController.swift
//  AWSChat
//
//  Created by Abhishek Mishra on 07/03/2017.
//  Copyright © 2017 ASM Technology Ltd. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var facebookButton: FBSDKLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.loginButton.isEnabled = false
        
        // log out the user if previously logged in.
        let facebookLoginManager = FBSDKLoginManager()
        facebookLoginManager.logOut()
        
        // set up the information you want to read from the user's Facebook account.
        facebookButton.readPermissions = ["public_profile", "email"];
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLogin(_ sender: Any) {
        
        guard let username = self.usernameField.text,
            let password = self.passwordField.text  else {
            return
        }
        
        let userpoolController = CognitoUserPoolController.sharedInstance
        userpoolController.login(username: username, password: password) { (error) in
            
            if let error = error {
                self.displayLoginError(error: error as NSError)
                return
            }
            
            self.displaySuccessMessage()
        }
    }
    
    @IBAction func usernameDidEndOnExit(_ sender: Any) {
        dismissKeyboard()
    }
    
    @IBAction func passwordDidEndOnExit(_ sender: Any) {
        dismissKeyboard()
    }
    
}

extension LoginViewController : UITextFieldDelegate {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        if let username = self.usernameField.text,
            let password = self.passwordField.text {
            
            if ((username.characters.count > 0) &&
                (password.characters.count > 0)) {
                self.loginButton.isEnabled = true
            }
        }
        
        return true
    }

}


extension LoginViewController {
    
    fileprivate func dismissKeyboard() {
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
    
    fileprivate func displayLoginError(error:NSError) {
        
        let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                message: error.userInfo["message"] as? String,
                                                preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    fileprivate func displaySuccessMessage() {
        let alertController = UIAlertController(title: "Success.",
                                                message: "Login succesful!",
                                                preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { action in
            let storyboard = UIStoryboard(name: "ChatJourney", bundle: nil)
            
            let viewController = storyboard.instantiateInitialViewController()
            self.present(viewController!, animated: true, completion: nil)
        })
        
        alertController.addAction(action)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion:  nil)
        }
    }

}


extension LoginViewController : FBSDKLoginButtonDelegate {
    
    func loginButton(_ loginButton: FBSDKLoginButton!,
                     didCompleteWith result: FBSDKLoginManagerLoginResult!,
                     error: Error!) {
        
        if error != nil {
            displayLoginError(error: error as NSError)
            return
        }
        
        if result.isCancelled {
                return
        }
        
        guard let idToken = FBSDKAccessToken.current() else {
            let error = NSError(domain: "com.asmtechnology.awschat",
                                code: 100,
                                userInfo: ["__type":"Unknown Error", "message":"Facebook JWT token error."])
            self.displayLoginError(error: error)
            return
        }
        
        
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me",
                                                                 parameters: ["fields":"email,name"])
        
        graphRequest.start(completionHandler: { (connection, result, error) -> Void in
            
            if let error = error {
                self.displayLoginError(error: error as NSError)
                return
            }
            
            if let result = result as? [String : AnyObject],
                let name = result["name"] as? String {
                
                let email = result["email"] as? String
                
                let indentityPoolController = CognitoIdentityPoolController.sharedInstance
                indentityPoolController.getFederatedIdentityForFacebook(idToken: idToken.tokenString,
                    username: name, emailAddress: email,
                    completion: { (error: Error?) in
                        
                        if let error = error {
                            self.displayLoginError(error:error as NSError)
                            return
                        }
                        
                        self.displaySuccessMessage()
                        return
                })
                
            }
            
        })
        
    }
    
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        // do nothing.
    }
    
}
