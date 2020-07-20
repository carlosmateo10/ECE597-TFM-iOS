//
//  AddBlueprintViewController.swift
//  ECE-597-2
//
//  Created by Carlos Mateo on 29/06/2020.
//  Copyright © 2020 Carlos Mateo. All rights reserved.
//

import UIKit
import FirebaseStorage
import Firebase
import Photos
import FirebaseFirestore

class AddBlueprintViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var blueprintImage: UIImageView!
    @IBOutlet weak var blueprintName: UITextField!
    
    var imagePickerController = UIImagePickerController()
    var imageURL:URL!
    var userID:String!
    var imageData:Data!
    var db:Firestore! = Firestore.firestore()
    
    @IBAction func selectBlueprint(_ sender: Any) {
        self.imagePickerController.sourceType = .photoLibrary
        self.present(self.imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func saveBlueprint(_ sender: Any) {

        if(blueprintName.text == ""){
            print("empty name")
        } else if (imageURL == nil) {
            print("empty image")
        } else {
            let storageRef = Storage.storage().reference()
                    
            let path = userID+"/"+blueprintName.text!

            let photoRef = storageRef.child(path)
                            
            let uploadTask = photoRef.putData(imageData, metadata: nil) { (metadata, err) in
                guard let metadata = metadata else {
                    print(err?.localizedDescription)
                    return
                }
                self.db.collection("users/"+self.userID+"/blueprints").document(self.blueprintName.text!).setData([
                    "name" : self.blueprintName.text!])
                print("Photo uploaded")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imagePickerController.delegate = self
        
        userID = Auth.auth().currentUser?.uid
    }

    func checkPermissions() {
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.authorized {
            PHPhotoLibrary.requestAuthorization({(status: PHAuthorizationStatus) -> Void in ()})
        }
        
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {} else {
            PHPhotoLibrary.requestAuthorization(requestAuthorizationHandler)
        }
    }
    
    func requestAuthorizationHandler(status: PHAuthorizationStatus){
        if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
            print("User is authorized")
        } else {
            print("User NOT authorized")
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let url = info[UIImagePickerController.InfoKey.imageURL] as? URL {
            self.imageURL = url
            do {
                let data = try Data(contentsOf: url)
                self.imageData = data
                blueprintImage.image = UIImage(data: data)
            } catch let err {
                print("Error : \(err.localizedDescription)")
            }
        }
        
        imagePickerController.dismiss(animated: true, completion: nil)
    }
}
