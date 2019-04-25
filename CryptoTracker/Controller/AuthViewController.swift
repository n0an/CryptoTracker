//
//  AuthViewController.swift
//  CryptoTracker
//
//  Created by nag on 25/04/2019.
//  Copyright © 2019 Anton Novoselov. All rights reserved.
//

import UIKit
import LocalAuthentication

class AuthViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        presentAuth()
    }
    
    func presentAuth() {
        LAContext().evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Biometrics protection") { (success, err) in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            
            if success {
                DispatchQueue.main.async {
                    let cryptoVC = CryptoTableViewController()
                    
                    let navController = UINavigationController(rootViewController: cryptoVC)
                    
                    if let window = UIApplication.shared.keyWindow {
                        
                        window.rootViewController = navController
                        
                    }
                    
                }
            } else {
                self.presentAuth()
            }
        }
    }
    

}
