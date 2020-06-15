//
//  PeopleListViewController.swift
//  ECE-597-2
//
//  Created by Carlos Mateo on 15/06/2020.
//  Copyright © 2020 Carlos Mateo. All rights reserved.
//

import UIKit
import FirebaseFirestore

class PeopleListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var peopleTable: UITableView!
    
    var testArray = ["CAt", "rrr", "BRRRR"]
    
    var db:Firestore! = Firestore.firestore()
    
    var query:Query!
    
    var listener:ListenerRegistration!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        query = db.collection("data/people/5-28-2020")
        
        listener = query.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.testArray = []
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    self.testArray.append(document.data()["id"] as? String ?? "")
                    
                }
                self.peopleTable.reloadData()
            }
        }
        
        peopleTable.dataSource = self
        peopleTable.delegate = self
        
    }
    
    @IBAction func buscar(_ sender: Any) {
        query = query.whereField("camera", isEqualTo: "5")
        listener.remove()
        listener = query.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.testArray = []
                for document in querySnapshot!.documents {
                    print("AFTER BUSCAR   \(document.documentID) => \(document.data())")
                    self.testArray.append(document.data()["id"] as? String ?? "")
                    
                }
                self.peopleTable.reloadData()
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath)
        
        cell.textLabel?.text = testArray[indexPath.row]
        
        return cell        
    }
    
    func fetchData() {
        
    }
}
