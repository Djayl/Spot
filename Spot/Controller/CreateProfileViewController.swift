//
//  CreateProfileViewController.swift
//  Spot
//
//  Created by MacBook DS on 10/12/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit
import ProgressHUD


@available(iOS 13.0, *)
class CreateProfileViewController: UIViewController, UITextViewDelegate, UITextFieldDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var equipmentTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var saveButton: CustomButton!
    
    // MARK: - Properties
    
    let authService = AuthService()
    let firestoreService = FirestoreService<Profil>()
    var myImage: UIImage?
    var profileDescription = ""
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchProfilInformation()
//        showKeyboard()
        setupImageView()
        setupTextFields()
        handleTextView()
        hideKeyboardWhenTappedAround()
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addPhoto)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    // MARK: - Actions
    
    @IBAction func saveProfilData(_ sender: Any) {
        ProgressHUD.showSuccess(NSLocalizedString("Profil mis à jour", comment: ""))
        updateEquipment()
        updateDescription()
        updateProfileImage()
        updateUserName()
        updateAge()
    }
    
    // MARK: - Methods
    
    @objc private func addPhoto() {
        showImagePicckerControllerActionSheet()
    }
    
    private func getImage(_ completion: @escaping (String)->Void) {
        guard let image = myImage, let data = image.jpegData(compressionQuality: 1.0) else {
                   presentAlert(with: "Il semble y avoir une erreur")
                   return
               }
        let firebaseStorageManager = FirebaseStorageManager()
        let imageName = UUID().uuidString
        firebaseStorageManager.uploadImageData(data: data, serverFileName: imageName) { (isSuccess, url) in
            guard let imageUrl = url else {return}
            completion(imageUrl)
        }
    }
    
    private func updateScreenWithProfil(_ profil: Profil) {
        descriptionTextView.text = profil.description
        profileDescription = profil.description
    }
    
    private func fetchProfilInformation() {
        let firestoreService = FirestoreService<Profil>()
        firestoreService.fetchDocument(endpoint: .currentUser) { [weak self] result in
            switch result {
            case .success(let profil):
                self?.updateScreenWithProfil(profil)
            case .failure(let error):
                print(error.localizedDescription)
                self?.presentAlert(with: "Erreur réseau")
            }
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLen:Int = 2
        if(textField == ageTextField){
            let currentText = textField.text! + string
            return currentText.count <= maxLen
        }
        return true
    }
    
    private func setupImageView() {
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.borderColor = UIColor.gray.cgColor
    }
    
    internal func handleTextView() {
        descriptionTextView.textColor = UIColor.lightGray
//        descriptionTextView.font = UIFont(name: "GlacialIndifference-Regular", size: 15.0)
        descriptionTextView.returnKeyType = .done
        descriptionTextView.delegate = self
    }
    
//    internal func textViewDidBeginEditing(_ textView: UITextView) {
//        if textView.text == "Décrivez votre Spot" {
//            textView.text = ""
//            textView.textColor = UIColor.black
//            textView.font = UIFont(name: "GlacialIndifference-Regular", size: 14.0)
//        }
//    }
//
//    internal func textViewDidEndEditing(_ textView: UITextView) {
//        if textView.text == "" {
//            textView.text = "Décrivez votre Spot"
//            textView.textColor = UIColor.lightGray
//            textView.font = UIFont(name: "GlacialIndifference-Regular", size: 14.0)
//        }
//    }
    
    fileprivate func setupView() {
        descriptionTextView.text = "Type your description"
//        descriptionTextView.font = UIFont(name: "GlacialIndifference-Regular", size: 15)
        descriptionTextView.layer.cornerRadius = 5
        profileImageView.isUserInteractionEnabled = true
        profileImageView.layer.cornerRadius = 10
        profileImageView.layer.masksToBounds = true
    }
    
    fileprivate func setupTextFields() {
        equipmentTextField.delegate = self
        descriptionTextView.delegate = self
        ageTextField.delegate = self
        userNameTextField.delegate = self
    }
    
    private func updateProfileImage() {
        if myImage != nil {
            self.getImage { (imageUrl) in
                let data = ["imageURL": imageUrl]
                self.firestoreService.updateData(endpoint: .currentUser, data: data) { [weak self] result in
                    switch result {
                    case .success(let successMessage):
                        print(successMessage)
                        self?.dismiss(animated: true, completion: nil)
                    case .failure(let error):
                        print("Error adding document: \(error)")
                        self?.presentAlert(with: "Erreur réseau")
                    }
                }
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func updateUserName() {
        guard let userName = self.userNameTextField.text else {return}
        if userName.isEmpty == false {
            let data = ["userName": userName]
            self.firestoreService.updateData(endpoint: .currentUser, data: data) { [weak self] result in
                switch result {
                case .success(let successMessage):
                    print(successMessage)
                    self?.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    print("Error adding document: \(error)")
                    self?.presentAlert(with: "Erreur réseau")
                }
            }
        } else {
          self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func updateAge() {
        guard let age = self.ageTextField.text else {return}
        if age.isEmpty == false {
            let data = ["age": age]
            self.firestoreService.updateData(endpoint: .currentUser, data: data) { [weak self] result in
                switch result {
                case .success(let successMessage):
                    print(successMessage)
                    self?.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    print("Error adding document: \(error)")
                    self?.presentAlert(with: "Erreur réseau")
                }
            }
        } else {
          self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func updateEquipment() {
        guard let equipment = self.equipmentTextField.text else {return}
        if equipment.isEmpty == false {
            let data = ["equipment": equipment]
            self.firestoreService.updateData(endpoint: .currentUser, data: data) { [weak self] result in
                switch result {
                case .success(let successMessage):
                    print(successMessage)
                    self?.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    print("Error adding document: \(error)")
                    self?.presentAlert(with: "Erreur réseau")
                }
            }
        } else {
          self.dismiss(animated: true, completion: nil)
        }
    }
    
    private func updateDescription() {
        guard let description = self.descriptionTextView.text else {return}
        if description != profileDescription {
            let data = ["description": description]
            self.firestoreService.updateData(endpoint: .currentUser, data: data) { [weak self] result in
                switch result {
                case .success(let successMessage):
                    print(successMessage)
                    self?.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    print("Error adding document: \(error)")
                    self?.presentAlert(with: "Erreur réseau")
                }
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    private func saveUserData() {
        guard self.myImage != nil else {
            self.saveButton.shake()
            self.presentAlert(with: "Merci de choisir une photo de profil")
            return
        }
        guard let equipment = self.equipmentTextField.text, !equipment.isEmpty else {
            self.saveButton.shake()
            self.presentAlert(with: "Renseignez votre équipement")
            return
        }
        guard let description = self.descriptionTextView.text, !description.isEmpty else {
            self.saveButton.shake()
            self.presentAlert(with: "Merci de renseigner une brève description")
            return
        }
        self.getImage { (imageUrl) in
            
            let data = ["imageURL": imageUrl, "equipment": equipment, "description": description]
            self.firestoreService.updateData(endpoint: .currentUser, data: data) { [weak self] result in
                switch result {
                case .success(let successMessage):
                    ProgressHUD.showSuccess(NSLocalizedString("Profil mis à jour", comment: ""))
                    print(successMessage)
                    self?.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    print("Error adding document: \(error)")
                    self?.presentAlert(with: "Erreur réseau")
                }
            }
        }
    }
    
    
}

// MARK: - ImagePicker Delegate

@available(iOS 13.0, *)
extension CreateProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
    
    private func showImagePickerController(sourceType: UIImagePickerController.SourceType) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.sourceType = sourceType
        present(imagePickerController, animated: true, completion: nil)
    }
    
    internal func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            profileImageView.image = editedImage
            myImage = editedImage
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            myImage = originalImage
            profileImageView.image = originalImage
        }
        dismiss(animated: true, completion: nil)
    }
}
