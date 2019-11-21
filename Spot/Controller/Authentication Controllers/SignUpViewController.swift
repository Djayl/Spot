//
//  SignUpViewController.swift
//  Spot
//
//  Created by MacBook DS on 17/09/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var signUpButton: CustomButton!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    
    // MARK: - Properties
    
    var gradient: CAGradientLayer?
    let authService = AuthService()
    let firestoreService = FirestoreService<Profil>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradient()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordConfirmTextField.delegate = self
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
    
    private func addGradient() {
        gradient = CAGradientLayer()
        gradient?.colors = [Colors.skyBlue.cgColor,UIColor.white]
        gradient?.startPoint = CGPoint(x: 0, y: 0)
        gradient?.endPoint = CGPoint(x: 0, y:1)
        gradient?.frame = view.frame
        self.view.layer.insertSublayer(gradient!, at: 0)
    }
    
    private func createUserAccount() {
        guard let userName = userNameTextField.text, !userName.isEmpty else {
            signUpButton.shake()
            presentAlert(with: "Merci de renseigner un nom d'utilisateur")
            return
        }
        guard let email = emailTextField.text, !email.isEmpty else {
            signUpButton.shake()
            presentAlert(with: "Merci de renseigner un email")
            return
        }
        guard let password = passwordTextField.text, !password.isEmpty else {
            signUpButton.shake()
            presentAlert(with: "Merci de renseigner un mot de passe")
            return
        }
        guard let passwordConfirmed = passwordConfirmTextField.text, passwordConfirmed == password, !passwordConfirmed.isEmpty else {
            signUpButton.shake()
            presentAlert(with: "Merci de confirmer votre mot de passe")
            return
        }
        authService.signUp(email: email, password: password) { (authResult, error) in
            if error == nil && authResult != nil {
                guard let currentUser = AuthService.getCurrentUser() else { return }
                let profil = Profil(identifier: currentUser.uid, email: email, userName: userName)
                self.saveUserData(profil)
                self.dismiss(animated: true, completion: nil)
            } else {
                print("Error creating user: \(error!.localizedDescription)")
                self.presentAlert(with: error!.localizedDescription)
            }
        }
    }
    
    private func saveUserData(_ profil: Profil) {
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
}

