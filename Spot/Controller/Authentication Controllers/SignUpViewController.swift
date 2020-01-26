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
    var placeholderLabel = UILabel()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.black,
             NSAttributedString.Key.font: UIFont(name: "Quicksand-Bold", size: 21)!]
        self.navigationItem.title = "Inscription"
        setupTextFieldsLayer()
        setupInputTextView()
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
    
    private func setupTextFieldsLayer() {
        equipmentTextField.layer.borderWidth = 1
        equipmentTextField.layer.borderColor = Colors.blueBalloon.cgColor
        userNameTextField.layer.borderWidth = 1
        userNameTextField.layer.borderColor = Colors.blueBalloon.cgColor
        emailTextField.layer.borderWidth = 1
        emailTextField.layer.borderColor = Colors.blueBalloon.cgColor
        passwordTextField.layer.borderWidth = 1
        passwordTextField.layer.borderColor = Colors.blueBalloon.cgColor
        passwordConfirmTextField.layer.borderWidth = 1
        passwordConfirmTextField.layer.borderColor = Colors.blueBalloon.cgColor
        ageTextField.layer.borderWidth = 1
        ageTextField.layer.borderColor = Colors.blueBalloon.cgColor
        equipmentTextField.layer.cornerRadius = 5
        descriptionTextView.layer.cornerRadius = 5
        emailTextField.layer.cornerRadius = 5
        passwordTextField.layer.cornerRadius = 5
        passwordConfirmTextField.layer.cornerRadius = 5
        ageTextField.layer.cornerRadius = 5
        userNameTextField.layer.cornerRadius = 5
    }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
        textField.resignFirstResponder()
        return true
    }
    
    private func setupImageView() {
        profileImageView.layer.borderWidth = 2
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
        guard let userName = userNameTextField.text, userName.isEmptyOrWhitespace() == false else {
            signUpButton.shake()
               presentAlert(with: "Merci de renseigner un nom d'utilisateur")
               return}
           guard let email = emailTextField.text, email.isEmptyOrWhitespace() == false else {
            signUpButton.shake()
               presentAlert(with: "Merci de renseigner un email")
               return}
           guard let password = passwordTextField.text, password.isEmptyOrWhitespace() == false else {
            signUpButton.shake()
               presentAlert(with: "Merci de renseigner un mot de passe")
               return}
           guard let passwordConfirmed = passwordConfirmTextField.text, passwordConfirmed == password, passwordConfirmed.isEmptyOrWhitespace() == false else {
            signUpButton.shake()
               presentAlert(with: "Merci de confirmer votre mot de passe")
               return}
           guard let age = ageTextField.text, age.isEmptyOrWhitespace() == false else {
            signUpButton.shake()
               presentAlert(with: "Merci de renseigner un âge")
               return}
           guard let equipment = equipmentTextField.text, equipment.isEmptyOrWhitespace() == false else {
            signUpButton.shake()
               presentAlert(with: "Merci de préciser l'appareil que vous utilisez pour vos photos")
               return}
           guard let description = descriptionTextView.text, validate(textView: descriptionTextView) else {
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
//            descriptionTextView.textColor = UIColor.white
            descriptionTextView.font = UIFont.systemFont(ofSize: 17)
            descriptionTextView.returnKeyType = .done
            descriptionTextView.delegate = self
            descriptionTextView.layer.borderWidth = 1
            descriptionTextView.layer.borderColor = Colors.blueBalloon.cgColor
            descriptionTextView.layer.cornerRadius = 5

        }

    
    func validate(textView: UITextView) -> Bool {
        guard let text = textView.text,
            !text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty else {
            // this will be reached if the text is nil (unlikely)
            // or if the text only contains white spaces
            // or no text at all
            return false
        }
        return true
    }
    
    func setupInputTextView() {
            
            descriptionTextView.delegate = self
            placeholderLabel.isHidden = false
            let placeholderX: CGFloat = self.view.frame.size.width / 75
            let placeholderY: CGFloat = 0
            let placeholderWidth: CGFloat = descriptionTextView.bounds.width - placeholderX
            let placeholderHeight: CGFloat = descriptionTextView.bounds.height
//            let placeholderFontSize = self.view.frame.size.width / 25
            
            placeholderLabel.frame = CGRect(x: placeholderX, y: placeholderY, width: placeholderWidth, height: placeholderHeight)
            placeholderLabel.text = "Parlez-nous un peu de vous, de votre passion pour la photo..."
            placeholderLabel.font = UIFont.systemFont(ofSize: 17)
            placeholderLabel.textColor = .systemGray
        placeholderLabel.textAlignment = .left
        placeholderLabel.numberOfLines = 2
         
            descriptionTextView.addSubview(placeholderLabel)
            
        }
     
     func textViewDidChange(_ textView: UITextView) {
         let spacing = CharacterSet.whitespacesAndNewlines
         if !textView.text.trimmingCharacters(in: spacing).isEmpty {
             _ = textView.text.trimmingCharacters(in: spacing)
             placeholderLabel.isHidden = true
         } else {
             placeholderLabel.isHidden = false
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


