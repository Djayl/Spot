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

class CreateSpotAddressViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var subtitleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var addSpotButton: UIButton!
    
    
    weak var delegate: AddSpotDelegate!
    var myImage: UIImage?
    
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
        addSpotButton.layer.cornerRadius = 10
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
                    self.presentAlert(with: "Un Spot doit avoir une image")
                    return
                }
                guard let title = self.titleTextField.text, self.titleTextField.text?.isEmpty == false else {
                    self.presentAlert(with: "Un Spot doit avoir un titre")
                    return
                }
                let annotation = Spot(title: title, subtitle: "", coordinate: coor, info: "", image: image)
                
                self.delegate.addSpotToMapView(annotation: annotation)
                self.goToMapView()
            }
        }
    }
    
    @IBAction func createSpot(_ sender: Any) {
        
        guard let address = addressTextField.text, addressTextField.text?.isEmpty == false else {
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
