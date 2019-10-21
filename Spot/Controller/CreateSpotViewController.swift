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
    @IBOutlet weak var subtitleTextfield: UITextField!
    @IBOutlet weak var creationButton: CustomButton!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("success")
        setupTextFields()
        setupView()
        hideKeyboardWhenTappedAround()
        setUpKeyboard()
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
    
    fileprivate func setupTextFields() {
        titleTextfield.delegate = self
        subtitleTextfield.delegate = self
        descriptionTextView.delegate = self
    }
    
    @objc func goBack() {
        dismiss(animated: true, completion: nil)
    }

    
        func getSpot() {
               let geocoder = GMSGeocoder()

            geocoder.reverseGeocodeCoordinate(location) { (placemarks, error) in
                   if error != nil {
                       print(error!)
                   }
                if let coor = placemarks?.firstResult()?.coordinate {
    //                   guard let image = self.myImage else {
    //                       self.creationButton.shake()
    //                       self.presentAlert(with: "Un Spot doit avoir une image")
    //                       return
    //                   }
                       guard let title = self.titleTextfield.text, self.titleTextfield.text?.isEmpty == false else {
    //                       self.creationButton.shake()
    //                       self.presentAlert(with: "Un Spot doit avoir un titre")
                           return
                       }
                       let spot = Spot(position: coor)
                    let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: self.customMarkerWidth, height: self.customMarkerHeight), image: self.myImage!, borderColor: UIColor.darkGray)
                    spot.iconView = customMarker
                    spot.title = title
                    spot.coordinate = coor
                    print(coor)
                    print(title)
                    self.delegate.addSpotToMapView(marker: spot)


                       self.goToMapView()
                   }

               }
           }
    
    func saveData() {
        
    }
    
    
    @objc func goToMapView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendData(_ sender: Any) {
     
        getSpot()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    @objc func addPhoto() {
        showImagePicckerControllerActionSheet()
    }
    
    fileprivate func uploadImage() {
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
                let dataReference = Firestore.firestore().collection(MyKeys.imagesCollections).document()
                let documentUid = dataReference.documentID
                let urlString = url.absoluteString
                
                let data = [MyKeys.uid: documentUid,
                            MyKeys.imageUrl: urlString
                ]
                dataReference.setData(data, merge: true) { (err) in
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


