//
//  CreateSpotViewController.swift
//  Spot
//
//  Created by MacBook DS on 10/09/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import FirebaseFirestore
import FirebaseStorage
import Kingfisher
import Firebase

@available(iOS 13.0, *)
class CreateSpotViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    
    var location: CLLocationCoordinate2D!
    var controller: MapViewController?
    weak var delegate: AddSpotDelegate!
    let customMarkerWidth: Int = 50
    let customMarkerHeight: Int = 70
    var myImage: UIImage?
    var spots = [Spot]()
    
    
    @IBOutlet weak var titleTextfield: UITextField!
    @IBOutlet weak var creationButton: CustomButton!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var switchLabel: UILabel!
    @IBOutlet weak var stateSwitch: UISwitch!
    @IBOutlet weak var favoriteButton: FavoriteButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("success")
        setupTextFields()
        setupView()
        handleTextView()
        hideKeyboardWhenTappedAround()
        setUpKeyboard()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Retour", style: .done, target: self, action: #selector(goBack))
        pictureImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addPhoto)))
        stateSwitch.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
     @objc func stateChanged(switchState: UISwitch) {
        if switchState.isOn {
            switchLabel.text = "Je partage mon Spot"

        } else {
            switchLabel.text = "Je garde mon Spot pour moi"

        }
    }
    
    fileprivate func setupView() {
        
        descriptionTextView.text = "Type your description"
        descriptionTextView.layer.cornerRadius = 5
        pictureImageView.isUserInteractionEnabled = true
        pictureImageView.layer.cornerRadius = 10
        pictureImageView.layer.masksToBounds = true
    }
    
    fileprivate func setupTextFields() {
        titleTextfield.delegate = self
//        subtitleTextfield.delegate = self
        descriptionTextView.delegate = self
    }
    
    @objc func goBack() {
        dismiss(animated: true, completion: nil)
    }

    
        func createPrivateSpot() {
               let geocoder = GMSGeocoder()

            geocoder.reverseGeocodeCoordinate(location) { (placemarks, error) in
                   if error != nil {
                       print(error!)
                   }
                if let coor = placemarks?.firstResult()?.coordinate {
                       guard let image = self.myImage else {
                           self.creationButton.shake()
                           self.presentAlert(with: "Un Spot doit avoir une image")
                           return
                       }
                    let uid = Auth.auth().currentUser?.uid
//                    let favoriteRef = FirestoreReferenceManager.referenceForUserPublicData(uid: uid!).collection("Favorites").document()
                    let ref = FirestoreReferenceManager.referenceForUserPublicData(uid: uid!).collection("Spots").document()
                    let documentID = ref.documentID
                       guard let title = self.titleTextfield.text, self.titleTextfield.text?.isEmpty == false else {
                           self.creationButton.shake()
                           self.presentAlert(with: "Un Spot doit avoir un titre")
                           return
                       }
                    guard let description = self.descriptionTextView.text else {return}
                    let spot = Spot(position: coor)
                    let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: self.customMarkerWidth, height: self.customMarkerHeight), image: image, borderColor: UIColor.darkGray)
                    spot.iconView = customMarker
                    spot.title = title
                    spot.summary = description
                    spot.coordinate = coor
                    self.uploadImage { (imageUrl) in
                       
                        switch self.favoriteButton.isOn {
// VOIR POUR FAIRE PLUTOT UN MERGE EN AJOUTANT LA MENTION ISFAVORITE: YES/NO ET DANS LA CASE FALSE METTRE LE REF.SETDATA COMME CA ON AURA QU'UNE SEULE COLLECTION DE SPOTS PUIS METTRE BOUTON POUR FAIRE APPARAITRE LES FAVORIS DANS LE MAPVIEWCONTROLLER
                        case true:
                            self.favoriteButton.isOn = false
                            let data = ["title": title as Any, "coordinate": GeoPoint(latitude: coor.latitude, longitude: coor.longitude), "uid": documentID, MyKeys.imageUrl: imageUrl, "description": description, "createdAt": FieldValue.serverTimestamp(), "isFavorite": "Yes"]
                            ref.setData(data) { (err) in
                                if let err = err {
                                    print(err.localizedDescription)
                                }
                                print("very successfull")
                            }
                            print("ADDED TO FAVORITE")
                        case false:
                            self.favoriteButton.isOn = true
                            let data = ["title": title as Any, "coordinate": GeoPoint(latitude: coor.latitude, longitude: coor.longitude), "uid": documentID, MyKeys.imageUrl: imageUrl, "description": description, "createdAt": FieldValue.serverTimestamp(), "isFavorite": "No"]
                             ref.setData(data) { (err) in
                                 if let err = err {
                                     print(err.localizedDescription)
                                 }
                                 print("very successfull")
                             }
                            print("NOT ADDED TO FAVORITE")
                        }
                        
                    }
                    self.delegate.addSpotToMapView(marker: spot)
                    

                       self.goToMapView()
                   }

               }
           }
    
    func createPublicSpot() {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(location) { (placemarks, error) in
            if error != nil {
                print(error!)
            }
            if let coor = placemarks?.firstResult()?.coordinate {
                guard let image = self.myImage else {
                    self.creationButton.shake()
                    self.presentAlert(with: "Un Spot doit avoir une image")
                    return
                }
                let uid = Auth.auth().currentUser?.uid
                let ref = FirestoreReferenceManager.root.collection("publicSpot").document()
                let privateRef = FirestoreReferenceManager.referenceForUserPublicData(uid: uid!).collection("Spots").document()
                let favoriteRef = FirestoreReferenceManager.referenceForUserPublicData(uid: uid!).collection("Spots").document()
                let documentID = ref.documentID
                guard let title = self.titleTextfield.text, self.titleTextfield.text?.isEmpty == false else {
                    self.creationButton.shake()
                    self.presentAlert(with: "Un Spot doit avoir un titre")
                    return
                }
                guard let description = self.descriptionTextView.text else {return}
                let spot = Spot(position: coor)
                let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: self.customMarkerWidth, height: self.customMarkerHeight), image: image, borderColor: UIColor.darkGray)
                spot.iconView = customMarker
                spot.title = title
                spot.summary = description
                spot.coordinate = coor
                self.uploadImage { (imageUrl) in
                    let data = ["title": title as Any, "coordinate": GeoPoint(latitude: coor.latitude, longitude: coor.longitude), "uid": documentID, MyKeys.imageUrl: imageUrl, "description": description, "createdAt": FieldValue.serverTimestamp()]
                    
                    switch self.favoriteButton.isOn {
                    case true:
                        favoriteRef.setData(data) { (err) in
                            if let err = err {
                                print(err.localizedDescription)
                            }
                            print("very successfull")
                        }
                        print("added to favorite")
                    case false:
                        print("not added to favorite")
                    }
                    ref.setData(data) { (err) in
                        if let err = err {
                            print(err.localizedDescription)
                        }
                        print("very successfull")
                    }
                }
                self.delegate.addSpotToMapView(marker: spot)
                self.goToMapView()
            }
        }
    }
    
    private func setData(data: [String:Any]) {
        let uid = Auth.auth().currentUser?.uid
        let publicRef = FirestoreReferenceManager.root.collection("publicSpot").document()
        let privateRef = FirestoreReferenceManager.referenceForUserPublicData(uid: uid!).collection("Spots").document()
        let favoriteRef = FirestoreReferenceManager.referenceForUserPublicData(uid: uid!).collection("Spots").document()
        
        switch publicRef {
        case publicRef:
            publicRef.setData(data) { (err) in
                if let err = err {
                    print(err.localizedDescription)
                }
                print("public spot added")
            }
        case privateRef:
            privateRef.setData(data) { (err) in
                if let err = err {
                    print(err.localizedDescription)
                }
                print("private spot added")
            }
        case favoriteRef:
            favoriteRef.setData(data) { (err) in
                if let err = err {
                    print(err.localizedDescription)
                }
                print("favorite spot added")
            }
        default:
            print("OK")
        }
    }
    

    
    func addToFavorite() {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(location) { (placemarks, error) in
            if error != nil {
                print(error!)
            }
            if let coor = placemarks?.firstResult()?.coordinate {
                guard let image = self.myImage else {
                    self.creationButton.shake()
                    self.presentAlert(with: "Un Spot doit avoir une image")
                    return
                }
                let ref = FirestoreReferenceManager.root.collection("publicSpot").document()
                let documentID = ref.documentID
                guard let title = self.titleTextfield.text, self.titleTextfield.text?.isEmpty == false else {
                    self.creationButton.shake()
                    self.presentAlert(with: "Un Spot doit avoir un titre")
                    return
                }
                guard let description = self.descriptionTextView.text else {return}
                let spot = Spot(position: coor)
                let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: self.customMarkerWidth, height: self.customMarkerHeight), image: image, borderColor: UIColor.darkGray)
                spot.iconView = customMarker
                spot.title = title
                spot.summary = description
                spot.coordinate = coor
                self.uploadImage { (imageUrl) in
                    let data = ["title": title as Any, "coordinate": GeoPoint(latitude: coor.latitude, longitude: coor.longitude), "uid": documentID, MyKeys.imageUrl: imageUrl, "description": description, "createdAt": FieldValue.serverTimestamp()]
                    ref.setData(data) { (err) in
                        if let err = err {
                            print(err.localizedDescription)
                        }
                        print("very successfull")
                    }
                }
                self.delegate.addSpotToMapView(marker: spot)
                self.goToMapView()
            }
        }
    }
    

    
    @objc func goToMapView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendData(_ sender: Any) {
     
        createPrivateSpot()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    @objc func addPhoto() {
        showImagePicckerControllerActionSheet()
    }
    
        func uploadImage(_ completion: @escaping (String)->Void) {
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
                    
                    let urlString = url.absoluteString
  
                    completion(urlString)
                })
            }
        }
    
//    fileprivate func uploadImage() {
//        guard let image = myImage, let data = image.jpegData(compressionQuality: 1.0) else {
//            presentAlert(with: "Il semble y avoir une erreur")
//            return
//        }
//        let imageName = UUID().uuidString
//        let imageReference = Storage.storage().reference().child(MyKeys.imagesFolder).child(imageName)
//
//        imageReference.putData(data, metadata: nil) { (metadata, err) in
//            if let err = err {
//                self.presentAlert(with: err.localizedDescription)
//                return
//            }
//            imageReference.downloadURL(completion: { (url, err) in
//                if let err = err {
//                    self.presentAlert(with: err.localizedDescription)
//                    return
//                }
//
//                guard let url = url else {
//                    self.presentAlert(with: "Il semble y avoir une erreur")
//                    return
//                }
//                let dataReference = Firestore.firestore().collection(MyKeys.imagesCollections).document()
//                let documentUid = dataReference.documentID
//                let urlString = url.absoluteString
//
//                let data = [MyKeys.uid: documentUid,
//                            MyKeys.imageUrl: urlString
//                ]
//                dataReference.setData(data, merge: true) { (err) in
//                    if let err = err {
//                        self.presentAlert(with: err.localizedDescription)
//                        return
//                    }
//                    UserDefaults.standard.setValue(documentUid, forKey: MyKeys.uid)
//                    self.presentAlert(with: "Image successfully upload")
//                }
//            })
//        }
//    }
    func handleTextView() {
        descriptionTextView.text = "Décrivez votre Spot"
        descriptionTextView.textColor = UIColor.lightGray
        descriptionTextView.font = UIFont(name: "futura", size: 14.0)
        descriptionTextView.returnKeyType = .done
        descriptionTextView.delegate = self
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
           if textView.text == "Décrivez votre Spot" {
               textView.text = ""
               textView.textColor = UIColor.black
               textView.font = UIFont(name: "futura", size: 14.0)
           }
       }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Décrivez votre Spot"
            textView.textColor = UIColor.lightGray
            textView.font = UIFont(name: "futura", size: 14.0)
        }
    }
     
     func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
         // get the current text, or use an empty string if that failed
         let currentText = textView.text ?? ""

         // attempt to read the range they are trying to change, or exit if we can't
         guard let stringRange = Range(range, in: currentText) else { return false }

         // add their new text to the existing text
         let updatedText = currentText.replacingCharacters(in: stringRange, with: text)

         // make sure the result is under 16 characters
         return updatedText.count <= 140
     }
    
}




@available(iOS 13.0, *)
extension CreateSpotViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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

struct MyKeys {
    static let imagesFolder = "imagesFolder"
    static let imagesCollections = "imagesCollections"
    static let uid = "uid"
    static let imageUrl = "imageUrl"
}


