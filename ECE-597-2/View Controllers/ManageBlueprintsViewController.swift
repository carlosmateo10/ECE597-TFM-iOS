//
//  ManageBlueprintsViewController.swift
//  ECE-597-2
//
//  Created by Carlos Mateo on 29/06/2020.
//  Copyright © 2020 Carlos Mateo. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI

class ManageBlueprintsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    
    var db:Firestore! = Firestore.firestore()
    var userID:String = Auth.auth().currentUser!.uid
    
    var width: Int?
    var height: Int?
    
    var iosImageWidth: CGFloat?
    var iosImageHeight: CGFloat?
    
    @IBOutlet weak var camerasNames: UITextField!
    @IBOutlet weak var camerasView: UIView!
    @IBOutlet weak var blueprintName: UITextField!
    @IBOutlet weak var blueprintImage: UIImageView!
    @IBOutlet weak var camera: UIImageView!
    
    @IBOutlet weak var xText: UITextField!
    @IBOutlet weak var yText: UITextField!
    @IBOutlet weak var idText: UITextField!
    
    @IBAction func saveButton(_ sender: Any) {
        print("WIDTH:\(width) HEIGHT:\(height)")
        if(camerasNames.text == "New Camera") {
            cameras.append(idText.text!)
            let cameraImage = UIImageView()
            cameraImage.alpha = 1
            cameraImage.image = UIImage(named: "security_camera")
            
            cameraImage.frame = CGRect(x: CGFloat(Double(xText.text!)!), y: CGFloat(Double(yText.text!)!), width: 50, height: 50)
            
            blueprintImage.addSubview(cameraImage)
            
            camerasViews.updateValue(cameraImage, forKey: idText.text!)
            camerasNames.text = idText.text
            
        } else {
            camerasViews[camerasNames.text!]?.center.x = CGFloat((xText.text! as NSString).doubleValue)
            camerasViews[camerasNames.text!]?.center.y = CGFloat((yText.text! as NSString).doubleValue)
            
            if(camerasNames.text != idText.text) {
                if(camerasViews[idText.text!] == nil) {
                    camerasViews[idText.text!] = camerasViews[camerasNames.text!]
                    camerasViews.removeValue(forKey: camerasNames.text!)
                    cameras.remove(at: cameras.firstIndex(of: camerasNames.text!)!)
                    camerasNames.text = idText.text!
                    cameras.append(idText.text!)
                }
            }
        }
        var newCamerasMap = [String: String]()
        for (cameraId, camera) in camerasViews {
            var x = ((camera.center.x)*CGFloat(width!))/iosImageWidth!
            var y = ((camera.center.y)*CGFloat(height!))/iosImageHeight!
            
            var coordinates:String = "\(x)-\(y)"
            
            newCamerasMap[cameraId] = coordinates
            db.collection("users/"+userID+"/blueprints/").document(blueprintName.text!).updateData(["cameras": newCamerasMap])
            print(newCamerasMap)
        }
    }
    
    @IBAction func removeButton(_ sender: Any) {
        camerasViews[camerasNames.text!]?.removeFromSuperview()
        camerasViews.removeValue(forKey: camerasNames.text!)
        
        var newCamerasMap = [String: String]()
        for (cameraId, camera) in camerasViews {
            var x = ((camera.center.x)*CGFloat(width!))/iosImageWidth!
            var y = ((camera.center.y)*CGFloat(height!))/iosImageHeight!
            
            var coordinates:String = "\(x)-\(y)"
            
            newCamerasMap[cameraId] = coordinates
        }
        cameras.remove(at: cameras.firstIndex(of: camerasNames.text!)!)
        camerasNames.text = "Select camera"
        
        xText.text = ""
        yText.text = ""
        idText.text = ""
        
        db.collection("users/"+userID+"/blueprints/").document(blueprintName.text!).updateData(["cameras": newCamerasMap])
        print(newCamerasMap)
    }
    
    var blueprints = [String]()
    var blueprintsPickerView = UIPickerView()
    
    var cameras = [String]()
    var camerasPickerView = UIPickerView()
    
    var camerasViews = [String: UIImageView]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        db.collection("users/"+userID+"/blueprints/").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("Blueprint \(document.documentID)")
                    self.blueprints.append(document.documentID)
                }
            }
        }
        
        blueprintsPickerView.delegate = self
        blueprintsPickerView.dataSource = self
        
        blueprintName.inputView = blueprintsPickerView
        
        camerasPickerView.delegate = self
        camerasPickerView.dataSource = self
        
        camerasNames.inputView = camerasPickerView
                
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView == blueprintsPickerView) {
            return blueprints.count
        }
        if(pickerView == camerasPickerView) {
            return cameras.count
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if(pickerView == blueprintsPickerView) {
            return blueprints[row]
        }
        if(pickerView == camerasPickerView) {
            return cameras[row]
        }
        return ""
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if(pickerView == blueprintsPickerView) {
            blueprintName.text = blueprints[row]
            blueprintName.resignFirstResponder()
            
            let storageRef = Storage.storage().reference()
                    
            let path = userID+"/"+blueprints[row]

            let photoRef = storageRef.child(path)
            
            blueprintImage.sd_setImage(with: photoRef)
            
            iosImageWidth = blueprintImage.frame.width
            iosImageHeight = blueprintImage.frame.height
            
            print("WIDTH: \(iosImageWidth) HEIGHT: \(iosImageHeight)")
            
            camerasView.frame = CGRect(x:0, y:0, width: iosImageWidth!, height: iosImageHeight!)
            camerasView.center = blueprintImage.center
            
            self.view.bringSubviewToFront(blueprintImage)
            
            cameras = [String]()
            camerasNames.text = "Select Camera"
            for (cameraId, cameraView) in camerasViews {
                cameraView.removeFromSuperview()
            }
            camerasViews = [String: UIImageView]()
            
            db.collection("users/"+userID+"/blueprints/").document(blueprintName.text!).getDocument { (blueprint, err) in
                if let err = err {
                    print("Error getting document: \(err)")
                } else {
                    if let blueprintData = blueprint!.data() {
                        if(blueprintData["cameras"] != nil) {
                            let cameras = blueprintData["cameras"] as! [String: Any]
                            self.height = Int(blueprintData["height"] as! String)
                            self.width = Int(blueprintData["width"] as! String)
                            
                            self.cameras.append("New Camera")
                            for (camera, coordinates) in cameras {
                                self.cameras.append(camera)
                                let coordinatesAux = (coordinates as! String).split(separator: "-")
                                
                                print("Camera \(camera) at x:\(coordinatesAux[0]) y:\(coordinatesAux[1])")
                                
                                let cameraImage = UIImageView()
                                cameraImage.alpha = 0.5
                                cameraImage.image = UIImage(named: "security_camera")
                                
                                let xAux = (coordinatesAux[0] as NSString).doubleValue
                                
                                let x = (Int(self.iosImageWidth!)*Int(xAux))/self.width!
                                
                                let yAux = (coordinatesAux[1] as NSString).doubleValue
                                
                                let y = (Int(self.iosImageHeight!)*Int(yAux))/self.height!
                                
                                print("Camera \(camera) PASA at x:\(x) y:\(y)")
                                
                                cameraImage.frame = CGRect(x: x, y: y, width: 50, height: 50)
                                
                                self.blueprintImage.addSubview(cameraImage)
                                
                                self.camerasViews.updateValue(cameraImage, forKey: camera)
                            }
                        }
                    }
                }
            }
        }
        if(pickerView == camerasPickerView) {
            camerasNames.text = cameras[row]
            camerasNames.resignFirstResponder()
            
            for cameraView in camerasViews {
                cameraView.value.alpha = 0.5
            }
            camerasViews[cameras[row]]?.alpha = 1.0
            
            if (camerasNames.text! == "New Camera") {
                xText.text = ""
                yText.text = ""
                idText.text = ""
            } else {
                xText.text = "\(camerasViews[cameras[row]]?.center.x.description ?? "error")"
                yText.text = "\(camerasViews[cameras[row]]?.center.y.description ?? "error")"
                idText.text = "\(cameras[row])"
            }
        }
        
    }
}
