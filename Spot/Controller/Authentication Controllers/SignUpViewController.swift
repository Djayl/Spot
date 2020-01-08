//
//  SignUpViewController.swift
//  Spot
//
//  Created by MacBook DS on 17/09/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit
import ProgressHUD


@available(iOS 13.0, *)
class SignUpViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var signUpButton: CustomButton!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var equipmentTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    // MARK: - Properties
    
    var myImage: UIImage?
    let authService = AuthService()
    let firestoreService = FirestoreService<Profil>()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTextFields()
        setupImageView()
        
        handleTextView()
        hideKeyboardWhenTappedAround()
        profileImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addPhoto)))
    }
    
    // MARK: - Actions
    
    @IBAction private func signUpAction(_ sender: Any) {
        createUserAccount()
    }
    
    // MARK: - Methods
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    
    private func setupImageView() {
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }
    
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
    
    private func createUserAccount() {
        guard myImage != nil else {
                signUpButton.shake()
                presentAlert(with: "Merci de choisir une photo de profil")
                return
            }
           guard let userName = userNameTextField.text, !userName.isEmpty else {
            signUpButton.shake()
               presentAlert(with: "Merci de renseigner un nom d'utilisateur")
               return}
           guard let email = emailTextField.text, !email.isEmpty else {
            signUpButton.shake()
               presentAlert(with: "Merci de renseigner un email")
               return}
           guard let password = passwordTextField.text, !password.isEmpty else {
            signUpButton.shake()
               presentAlert(with: "Merci de renseigner un mot de passe")
               return}
           guard let passwordConfirmed = passwordConfirmTextField.text, passwordConfirmed == password, !passwordConfirmed.isEmpty else {
            signUpButton.shake()
               presentAlert(with: "Merci de confirmer votre mot de passe")
               return}
           guard let age = ageTextField.text, !age.isEmpty else {
            signUpButton.shake()
               presentAlert(with: "Merci de renseigner un âge")
               return}
           guard let equipment = equipmentTextField.text, !equipment.isEmpty else {
            signUpButton.shake()
               presentAlert(with: "Merci de préciser l'appareil que vous utilisez pour vos photos")
               return}
           guard let description = descriptionTextView.text, !description.isEmpty, description != "Parlez-nous un peu de vous, de votre passion pour la photo..." else {
            signUpButton.shake()
               presentAlert(with: "Merci de renseigner une brève description de vous")
               return}
        
           authService.signUp(email: email, password: password) { (authResult, error) in
               if error == nil && authResult != nil {
                ProgressHUD.show()
                   guard let currentUser = AuthService.getCurrentUser() else { return }
                   self.getImage { (imageURL) in
                       let profil = Profil(identifier: currentUser.uid, email: email, userName: userName, imageURL: imageURL, equipment: equipment, age: age, description: description)
                       self.saveUserData(profil)
                       self.dismiss(animated: true, completion: nil)
                   }
               } else {
                   print("Error creating user: \(error!.localizedDescription)")
                   self.presentAlert(with: error!.localizedDescription)
               }
           }
       }
    
    private func saveUserData(_ profil: Profil) {
        ProgressHUD.showSuccess(NSLocalizedString("Votre compte a été créé", comment: ""))
        firestoreService.saveData(endpoint: .user, identifier: profil.identifier, data: profil.dictionary) { [weak self] result in
            switch result {
            case .success(let successMessage):
                
                print(successMessage)
            case .failure(let error):
                print("Error adding document: \(error)")
                self?.presentAlert(with: "Serveur indisponible")
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
        
        internal func handleTextView() {
            descriptionTextView.text = "Parlez-nous un peu de vous, de votre passion pour la photo..."
            descriptionTextView.textColor = UIColor.lightGray
            descriptionTextView.font = UIFont.systemFont(ofSize: 16)
            descriptionTextView.returnKeyType = .done
            descriptionTextView.delegate = self
            descriptionTextView.backgroundColor = UIColor.systemBackground
            descriptionTextView.layer.cornerRadius = 5
            descriptionTextView.layer.borderWidth = 1
            descriptionTextView.layer.borderColor = UIColor.systemBackground.cgColor
        }
        
        internal func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == "Parlez-nous un peu de vous, de votre passion pour la photo..." {
                textView.text = ""
                textView.textColor = UIColor.label
                textView.font = UIFont.systemFont(ofSize: 16)
            }
        }
        
        internal func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text == "" {
                textView.text = "Parlez-nous un peu de vous, de votre passion pour la photo..."
                textView.textColor = UIColor.lightGray
                textView.font = UIFont.systemFont(ofSize: 16)
            }
        }
        
        fileprivate func setupTextFields() {
            equipmentTextField.delegate = self
            descriptionTextView.delegate = self
            emailTextField.delegate = self
            passwordTextField.delegate = self
            passwordConfirmTextField.delegate = self
            ageTextField.delegate = self
            userNameTextField.delegate = self
        }
    }


    // MARK: - ImagePicker Delegate

    @available(iOS 13.0, *)
    extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        
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


