//
//  SplashViewController.swift
//  ECE-597-2
//
//  Created by Carlos Mateo on 09/06/2020.
//  Copyright © 2020 Carlos Mateo. All rights reserved.
//

import UIKit
import Firebase

class SplashViewController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if(Auth.auth().currentUser?.uid != nil){
            print("LOGGED")
            performSegue(withIdentifier: "toMain", sender: self)
        } else {
            print("NOT LOGGED")
            performSegue(withIdentifier: "toLogin", sender: self)
        }
    }

}
