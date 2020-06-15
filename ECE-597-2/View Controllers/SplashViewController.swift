//
//  SplashViewController.swift
//  ECE-597-2
//
//  Created by Carlos Mateo on 09/06/2020.
//  Copyright © 2020 Carlos Mateo. All rights reserved.
//

import UIKit

class SplashViewController: UINavigationController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performSegue(withIdentifier: "toLogin", sender: self)
    }

}
