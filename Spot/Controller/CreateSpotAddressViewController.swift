//
//  CreateSpotAddressViewController.swift
//  Spot
//
//  Created by MacBook DS on 17/09/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import Kingfisher

class CreateSpotAddressViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var subtitleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var addSpotButton: CustomButton!
    
    
    weak var delegate: AddSpotDelegate!
    var myImage: UIImage?
//    var myAnnotation = [String:Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setUpKeyboard()
        setupView()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Retour", style: .done, target: self, action: #selector(goBack))
        pictureImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addPhoto)))
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    fileprivate func setupView() {
        
        descriptionTextView.text = "Type your description"
        descriptionTextView.layer.cornerRadius = 5
        pictureImageView.isUserInteractionEnabled = true
        pictureImageView.layer.cornerRadius = 10
        pictureImageView.layer.masksToBounds = true
    }
    
    @objc func goBack() {
        dismiss(animated: true, completion: nil)
    }
    
    func getCoordinate(from address: String) {
        
        let geocoder = CLGeocoder()
        
        
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if error != nil {
                print(error!)
            }
            
            if let coor = placemarks?.first?.location?.coordinate {
                guard let image = self.myImage else {
                    self.addSpotButton.shake()
                    self.presentAlert(with: "Un Spot doit avoir une image")
                    return
                }
                guard let title = self.titleTextField.text, self.titleTextField.text?.isEmpty == false else {
                    self.addSpotButton.shake()
                    self.presentAlert(with: "Un Spot doit avoir un titre")
                    return
                }
                let uid = Auth.auth().currentUser?.uid
                let annotation = Spot(title: title, subtitle: "", coordinate: coor, info: "", image: image)
                let ref = FirestoreReferenceManager.referenceForUserPublicData(uid: uid!).collection("Spots").document()
                let documentId = ref.documentID
                let documentUid = ""
                let urlString = ""
                self.uploadImage()
                let data = ["title": title as Any, "coordinate": GeoPoint(latitude: coor.latitude, longitude: coor.longitude), "uid": documentId, "imageUid": documentUid, MyKeys.imageUrl: urlString]
                ref.setData(data) { (err) in
                    if let err = err {
                        print(err.localizedDescription)
                    }
                    
                    print("very successfull")
                }
                
                
                
                //                FirestoreReferenceManager.root.document("New Point").setData(myAnnotation) { (err) in
                //                    if let err = err {
                //                        print(err.localizedDescription)
                //                    }
                //                    print("successfull")
                //                }
                self.delegate.addSpotToMapView(annotation: annotation)
                self.goToMapView()
            }
        }
    }
    

    
    @IBAction func createSpot(_ sender: Any) {
        
        guard let address = addressTextField.text, addressTextField.text?.isEmpty == false else {
            addSpotButton.shake()
            presentAlert(with: "Merci de renseigner une adresse")
            return
        }
        
        getCoordinate(from: address)
       
    }
    
    @objc func goToMapView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    @objc func addPhoto() {
        showImagePicckerControllerActionSheet()
    }
    
     func uploadImage() {
        guard let image = myImage, let data = image.jpegData(compressionQuality: 1.0) else {
            presentAlert(with: "Il semble y avoir une erreur")
            return
        }
        let imageName = UUID().uuidString
        let imageReference = Storage.storage().reference().child(MyKeys.imagesFolder).child(imageName)
        
        imageReference.putData(data, metadata: nil) { (metadata, err) in
            if let err = err {
                self.presentAlert(with: err.localizedDescription)
                return
            }
            imageReference.downloadURL(completion: { (url, err) in
                if let err = err {
                    self.presentAlert(with: err.localizedDescription)
                    return
                }
                
                guard let url = url else {
                    self.presentAlert(with: "Il semble y avoir une erreur")
                    return
                }
                let uid = Auth.auth().currentUser?.uid
                let ref = FirestoreReferenceManager.referenceForUserPublicData(uid: uid!).collection("Spots").document()
                let documentId = ref.documentID
//                let dataReference = Firestore.firestore().collection(MyKeys.imagesCollections).document()
                let dataReference = FirestoreReferenceManager.referenceForUserPublicData(uid: uid!).collection("Spots").document(documentId)
                let documentUid = dataReference.documentID
                let urlString = url.absoluteString
                
                let data = ["imageUid": documentUid,
                            MyKeys.imageUrl: urlString
                ]
                
                dataReference.updateData(data) { (err) in
                    if let err = err {
                        self.presentAlert(with: err.localizedDescription)
                        return
                    }
                    
                    UserDefaults.standard.setValue(documentUid, forKey: MyKeys.uid)
                    self.presentAlert(with: "Image successfully upload")
                }
            })
        }
    }
    
    func uploadAndSet(){
        
        guard let image = myImage, let data = image.jpegData(compressionQuality: 1.0) else {
            presentAlert(with: "Il semble y avoir une erreur")
            return
        }
      
        // Create a storage reference from our storage service
        let imageName = UUID().uuidString
        let storageRef = Storage.storage().reference().child(MyKeys.imagesFolder).child(imageName)
        
        _ = storageRef.putData(data, metadata: nil, completion: { (metadata,error ) in
            guard let metadata = metadata else {
                print("Erreur")
                return
            }
           storageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    return
        }
            print(downloadURL)
        }
    })
    }
//   func downloadImage() {
//        guard let uid = UserDefaults.standard.value(forKey: MyKeys.uid) else {
//            presentAlert(with: "Il semble y avoir un problème")
//            return
//        }
//        let query = Firestore.firestore().collection(MyKeys.imagesCollections).whereField(MyKeys.uid, isEqualTo: uid)
//        query.getDocuments { (snapshot, err) in
//            if let err = err {
//                self.presentAlert(with: err.localizedDescription)
//                return
//            }
//            guard let snapshot = snapshot,
//                let data = snapshot.documents.first?.data(),
//                let urlString = data[MyKeys.imageUrl] as? String,
//                let url = URL(string: urlString) else {
//                self.presentAlert(with: "Il semble y avoir un problème")
//                return
//            }
//            let resource = ImageResource(downloadURL: url)
//            self.pictureImageView.kf.setImage(with: resource, completionHandler: { (result) in
//                switch result {
//                    
//                case .success(_):
//                    self.pictureImageView.image = self.myImage
//                    self.presentAlert(with: "BIG SUCCESS")
//                case .failure(_):
//                    self.presentAlert(with: "BIG ERREUR")
//                }
//            })
//        }
//    }
//}
}
extension CreateSpotAddressViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func showImagePicckerControllerActionSheet() {
        let photoLibraryAction = UIAlertAction(title: "Ouvrir la photothèque", style: .default) { (action) in
            self.showImagePickerController(sourceType: .photoLibrary)
        }
        let cameraAction = UIAlertAction(title: "Prendre une photo", style: .default) { (action) in
            self.showImagePickerController(sourceType: .camera)
        }
        let cancelAction = UIAlertAction(title: "Annuler", style: .cancel, handler: nil)
        
        AlertService.showAlert(style: .actionSheet, title: "Choisissez votre image", message: nil, actions: [photoLibraryAction, cameraAction, cancelAction], completion: nil)
    }
    
    func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = sourceType
        present(imagePickerController, animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            
            pictureImageView.image = editedImage
            myImage = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            myImage = originalImage
            pictureImageView.image = originalImage
        }
        dismiss(animated: true, completion: nil)
    }
}
