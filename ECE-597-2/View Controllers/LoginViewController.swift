//
//  LoginViewController.swift
//  ECE-597-2
//
//  Created by Carlos Mateo on 09/06/2020.
//  Copyright © 2020 Carlos Mateo. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInDelegate {
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.delegate = self
        
        let gSignIn = GIDSignInButton(frame: CGRect(x: 0, y: 0, width: 150, height: 48))
        gSignIn.center = view.center
        view.addSubview(gSignIn)
        
    }
    

    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        print("Running sign in")
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            // Perform any operations on signed in user here.
            print(user.profile.name)
        }
        
        // Firebase sign in
        guard let authentication = user.authentication else { return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signIn(with: credential) { (authResult, error) in
            if let error = error {
                print("Firebase sign in error")
                print(error)
                return
            }
            print("User is signed in with Firebase")
            self.performSegue(withIdentifier: "toMainAfterLogin", sender: self)
        }
        
    }
    
}

