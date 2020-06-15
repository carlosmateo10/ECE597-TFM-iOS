//
//  MainViewController.swift
//  ECE-597-2
//
//  Created by Carlos Mateo on 09/06/2020.
//  Copyright © 2020 Carlos Mateo. All rights reserved.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

class MainViewController: UIViewController {

    @IBAction func toPeopleList(_ sender: Any) {
        print("toPeopleList Segue")
        performSegue(withIdentifier: "toPeopleList", sender: self)
    }
    
    @IBAction func signOut(_ sender: Any) {
        print("Signing Out")
        GIDSignIn.sharedInstance()?.signOut()
        
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Failed to sign out")
            print(signOutError)
            return
        }
        
        print("Signed out")
        performSegue(withIdentifier: "toLoginAfterSignOut", sender: self)
    }
}
