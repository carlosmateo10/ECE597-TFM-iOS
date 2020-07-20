//
//  SettingsViewController.swift
//  ECE-597-2
//
//  Created by Carlos Mateo on 29/06/2020.
//  Copyright © 2020 Carlos Mateo. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func toAddBlueprint(_ sender: Any) {
        print("toAddBlueprint Segue")
        performSegue(withIdentifier: "toAddBlueprint", sender: self)
    }
    
    @IBAction func toManageBlueprints(_ sender: Any) {
        print("toManageBlueprints Segue")
        performSegue(withIdentifier: "toManageBlueprints", sender: self)
    }
    
}
