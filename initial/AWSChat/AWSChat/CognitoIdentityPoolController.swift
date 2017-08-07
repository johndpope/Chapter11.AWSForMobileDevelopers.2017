//
//  CognitoIdentityPoolController.swift
//  AWSChat
//
//  Created by Abhishek Mishra on 23/03/2017.
//  Copyright © 2017 ASM Technology Ltd. All rights reserved.
//

import Foundation
import AWSCognito
import AWSCognitoIdentityProvider

class CognitoIdentityPoolController {
    
    //TO DO: Insert your Cognito identity pool settings here
    let identityPoolRegion: AWSRegionType = .USEast1
    let identityPoolD = "insert your identity pool id"
    
    private var credentialsProvider: AWSCognitoCredentialsProvider?
    private var configuration: AWSServiceConfiguration?
    
    static let sharedInstance: CognitoIdentityPoolController = CognitoIdentityPoolController()
    
    private init() {
        
        let identityProviderManager = SocialIdentityManager.sharedInstance
        
        credentialsProvider = AWSCognitoCredentialsProvider(regionType: identityPoolRegion,
                                                            identityPoolId: identityPoolD,
                                                            identityProviderManager: identityProviderManager)
        
        
        configuration = AWSServiceConfiguration(region: identityPoolRegion,
                                                credentialsProvider:credentialsProvider)
        
        AWSServiceManager.default().defaultServiceConfiguration = configuration
    }
    
    
    func getFederatedIdentityForFacebook(idToken:String, username:String, emailAddress:String?, completion:@escaping (Error?)->Void) {
        
        let identityProviderManager = SocialIdentityManager.sharedInstance
        identityProviderManager.registerFacebookToken(idToken)
        
        let task = self.credentialsProvider!.getIdentityId()
        
        task.continueWith { (task: AWSTask<NSString>) -> Any? in
            
            if task.error != nil {
                completion(task.error)
                return nil
            }
            
            let syncClient = AWSCognito.default()
            let dataSet = syncClient.openOrCreateDataset("facebookUserData")
            
            dataSet.setString(username, forKey: "name")
            
            if let emailAddress = emailAddress {
                dataSet.setString(emailAddress, forKey: "email")
            }
            
            dataSet.synchronize().continueWith(block: { (task: AWSTask<AnyObject>) -> Any? in
                
                if task.error != nil {
                    completion(task.error)
                    return nil
                }
                
                completion(nil)
                return nil
            })
            
            return nil
        }
        
    }
    
}
