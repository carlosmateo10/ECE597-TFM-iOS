//
//  PeopleListViewController.swift
//  ECE-597-2
//
//  Created by Carlos Mateo on 15/06/2020.
//  Copyright © 2020 Carlos Mateo. All rights reserved.
//

import UIKit
import Firebase
import WARangeSlider

class PeopleListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let datePicker = UIDatePicker()
    
    var personID = String()
    
    let rangeSlider = RangeSlider(frame: CGRect.zero)
    
    @IBAction func dateText(_ sender: Any) {
        //showDatePicker()
    }
    @IBOutlet weak var area: UITextField!
    
    @IBOutlet weak var dateTextOutlet: UITextField!
    @IBOutlet weak var peopleTable: UITableView!
    @IBOutlet weak var cameraIdFilter: UITextField!
    
    var detectionsArray = [Person]()
    
    var pickerView = UIPickerView()
    var areas = [String]()
    
    var db:Firestore! = Firestore.firestore()
    var userID:String = Auth.auth().currentUser!.uid
    
    var query:Query!
    
    var listener:ListenerRegistration!
    
    @IBOutlet weak var timeFilter: UILabel!
    
    let date = Date()
    let dateFormatter = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        rangeSlider.minimumValue = 0
        rangeSlider.maximumValue = 24
        rangeSlider.upperValue = 17.00
        view.addSubview(rangeSlider)
        rangeSlider.addTarget(self, action: #selector(PeopleListViewController.rangeSliderValueChanged(_:)), for: .valueChanged)
        
        showDatePicker()
        
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
        
        dateFormatter.dateFormat = "M-d-yyyy"
        
        dateTextOutlet.text = dateFormatter.string(from: date)
        
        let path:String = "data/people/"+dateFormatter.string(from: date)
        
        print(path)
        
        query = db.collection(path)
        
        listener = query.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.detectionsArray = []
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                    let data = document.data()
                    let person = Person(id: data["id"] as! String, camera: data["camera"] as! String, month: data["month"] as! Int, day: data["day"] as! Int, hour: data["hour"] as! Int, minute: data["minute"] as! Int)
                    self.detectionsArray.append(person)
                    
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
        rangeSlider.frame = CGRect(x: margin, y: margin + 100,
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
    
    @IBAction func buscar(_ sender: Any) {
        var path = ""
        if(area.text == "ALL"){
            path = "data/people/"+dateTextOutlet.text!
        } else {
            path = "data/people/"+dateTextOutlet.text!+"/area/"+area.text!
        }

        
        print("PATH: "+path)
        
        query = db.collection(path).order(by: FirebaseFirestore.FieldPath.documentID())
        
        listener.remove()
        listener = query.addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.detectionsArray = []
                for document in querySnapshot!.documents {
                    //print("AFTER BUSCAR   \(document.documentID) => \(document.data())")
                    let data = document.data()
                    let person = Person(id: data["id"] as! String, camera: data["camera"] as! String, month: data["month"] as! Int, day: data["day"] as! Int, hour: data["hour"] as! Int, minute: data["minute"] as! Int)
                    self.detectionsArray.append(person)
                    
                }
                
                self.peopleTable.reloadData()
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return detectionsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyCell", for: indexPath) as! PersonCell
        
        cell.idLabel?.text = "ID: "+detectionsArray[indexPath.row].id
        cell.cameraLabel?.text = "CAMERA "+detectionsArray[indexPath.row].camera
        
        cell.timeLabel?.text = "\(detectionsArray[indexPath.row].hour):\(detectionsArray[indexPath.row].minute)"
        
        if (detectionsArray[indexPath.row].hour < Int(rangeSlider.lowerValue) || detectionsArray[indexPath.row].hour > Int(rangeSlider.upperValue)) {
            self.detectionsArray.remove(at: indexPath.row)
            self.peopleTable.deleteRows(at: [indexPath], with: .automatic)
            self.peopleTable.reloadData()
            print("Filtered by time: \(detectionsArray[indexPath.row].hour) < \(Int(rangeSlider.lowerValue)) or > \(Int(rangeSlider.upperValue))")
        }
        
        if (!(cameraIdFilter.text == "")) {
            if (cameraIdFilter.text != detectionsArray[indexPath.row].camera) {
                self.detectionsArray.remove(at: indexPath.row)
                self.peopleTable.deleteRows(at: [indexPath], with: .automatic)
                self.peopleTable.reloadData()
                print("filter camera" + cameraIdFilter.text!)
            }
        }
        
        return cell        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected cell \(indexPath.row)")
        personID = detectionsArray[indexPath.row].id
        performSegue(withIdentifier: "toPerson", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "toPerson" {
            let destinationController = segue.destination as! PersonListViewController
            destinationController.idTextFromSegue = personID
            destinationController.dateTextFromSegue = dateTextOutlet.text ?? "3/28/2020"
        }
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


