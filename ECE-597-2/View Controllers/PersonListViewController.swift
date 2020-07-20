//
//  PersonListViewController.swift
//  ECE-597-2
//
//  Created by Carlos Mateo on 28/06/2020.
//  Copyright © 2020 Carlos Mateo. All rights reserved.
//

import UIKit
import Firebase
import WARangeSlider

class PersonListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {

    let datePicker = UIDatePicker()
    let date = Date()
    let dateFormatter = DateFormatter()
    
    let rangeSlider = RangeSlider(frame: CGRect.zero)
    
    @IBOutlet weak var area: UITextField!
    var testArray = [Person]()
    
    var db:Firestore! = Firestore.firestore()
    var userID:String = Auth.auth().currentUser!.uid
    
    var query:Query!
    
    var pickerView = UIPickerView()
    var areas = [String]()
    
    var listener:ListenerRegistration!
    
    var idTextFromSegue = String()
    var dateTextFromSegue = String()
    
    @IBAction func buscar(_ sender: Any) {
        var path = ""
        if(area.text == "ALL"){
            path = "data/people/"+dateTextOutlet.text!
        } else {
            path = "data/people/"+dateTextOutlet.text!+"/area/"+area.text!
        }
        
        print("PATH: "+path)
        
        query = db.collection(path).whereField("hour", isLessThanOrEqualTo: rangeSlider.upperValue).whereField("hour", isGreaterThanOrEqualTo: rangeSlider.lowerValue).order(by: "hour", descending: true).order(by: FirebaseFirestore.FieldPath.documentID()).whereField("id", isEqualTo: idTextFromSegue)
        
        if (!(cameraIdFilter.text == "")) {
            query = query.whereField("camera", isEqualTo: (cameraIdFilter.text ?? "") as String)
            print("filter camera" + cameraIdFilter.text!)
        }
        
        listener.remove()
        listener = query.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.testArray = []
                for document in querySnapshot!.documents {
                    print("AFTER BUSCAR   \(document.documentID) => \(document.data())")
                    let data = document.data()
                    let person = Person(id: data["id"] as! String, camera: data["camera"] as! String, month: data["month"] as! Int, day: data["day"] as! Int, hour: data["hour"] as! Int, minute: data["minute"] as! Int)
                    self.testArray.append(person)
                    
                }
                self.peopleTable.reloadData()
            }
        }
    }
    
    @IBOutlet weak var cameraIdFilter: UITextField!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var peopleTable: UITableView!
    @IBOutlet weak var dateTextOutlet: UITextField!
    @IBOutlet weak var timeFilter: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        idLabel.text = "ID: "+idTextFromSegue
        print("FROM SEGUE: "+idTextFromSegue)
        
        rangeSlider.minimumValue = 0
        rangeSlider.maximumValue = 24
        rangeSlider.upperValue = 17.00
        view.addSubview(rangeSlider)
        rangeSlider.addTarget(self, action: #selector(PeopleListViewController.rangeSliderValueChanged(_:)), for: .valueChanged)
        
        showDatePicker()
        dateFormatter.dateFormat = "M-d-yyyy"
        dateTextOutlet.text = dateTextFromSegue
                
        let path:String = "data/people/"+dateTextFromSegue
        
        query = db.collection(path).whereField("id", isEqualTo: idTextFromSegue)
        
        db.collection("users/"+userID+"/blueprints/").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.areas.append("ALL")
                for document in querySnapshot!.documents {
                    print("Blueprint \(document.documentID)")
                    self.areas.append(document.documentID)
                }
            }
        }
        
        pickerView.delegate = self
        pickerView.dataSource = self
        
        area.inputView = pickerView
        
        listener = query.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.testArray = []
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    let person = Person(id: data["id"] as! String, camera: data["camera"] as! String, month: data["month"] as! Int, day: data["day"] as! Int, hour: data["hour"] as! Int, minute: data["minute"] as! Int)
                    self.testArray.append(person)
                    
                }
                self.peopleTable.reloadData()
            }
        }
        
        peopleTable.dataSource = self
        peopleTable.delegate = self
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return areas.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return areas[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        area.text = areas[row]
        area.resignFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
        let margin: CGFloat = 20.0
        let width = view.bounds.width - 2.0 * margin
        rangeSlider.frame = CGRect(x: margin, y: margin + 155,
            width: width, height: 31.0)
    }
    
    @objc func rangeSliderValueChanged(_ rangeSlider: RangeSlider) {
        print("Range slider value changed: (\(rangeSlider.lowerValue) , \(rangeSlider.upperValue))")
        
        var min = ""
        var max = ""
        
        if (rangeSlider.lowerValue < 12) {
            min = "\(Int(rangeSlider.lowerValue))AM-"
        } else {
            min = "\(Int(rangeSlider.lowerValue))PM-"
        }
        
        if (rangeSlider.upperValue < 12) {
            max = "\(Int(rangeSlider.upperValue))AM"
        } else {
            max = "\(Int(rangeSlider.upperValue))PM"
        }
        
        timeFilter.text = min+max
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return testArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! PersonCell
        
        cell.idLabel?.text = "ID: "+testArray[indexPath.row].id
        cell.cameraLabel?.text = "CAMERA "+testArray[indexPath.row].camera
        
        cell.timeLabel?.text = "\(testArray[indexPath.row].hour):\(testArray[indexPath.row].minute)"
        
        return cell
    }
    
    func showDatePicker() {
        //Formate Date
        datePicker.datePickerMode = .date
        
        //ToolBar
          let toolbar = UIToolbar();
          toolbar.sizeToFit()
          let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
          let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
          let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));

        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)

         dateTextOutlet.inputAccessoryView = toolbar
         dateTextOutlet.inputView = datePicker
    }

    @objc func donedatePicker(){
        let formatter = DateFormatter()
        formatter.dateFormat = "M-d-yyyy"
        dateTextOutlet.text = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }

    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }

}
