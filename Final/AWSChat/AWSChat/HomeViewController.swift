//
//  HomeViewController.swift
//  AWSChat
//
//  Created by Abhishek Mishra on 07/03/2017.
//  Copyright © 2017 ASM Technology Ltd. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class HomeViewController: UIViewController {

    override func viewDidLoad() {
        
        super.viewDidLoad()

        // write user's email address to console log
        let userpoolController = CognitoUserPoolController.sharedInstance
        userpoolController.getUserDetails(user: userpoolController.currentUser!) { (error: Error?, details:AWSCognitoIdentityUserGetDetailsResponse?) in
            
            if let userAttributes = details?.userAttributes {
                for attribute in userAttributes {
                    if attribute.name?.compare("email") == .orderedSame {
                        print ("Email address of logged-in user is \(attribute.value!)")
                    }
                }
            }
        }
        
    }

 

}
