//
//  LoginViewController.swift
//  Spot
//
//  Created by MacBook DS on 17/09/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var loginButton: CustomButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // MARK: - Methods
    
    var gradient: CAGradientLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradient()
        emailTextField.delegate = self
        passwordTextField.delegate = self   
    }
    
    // MARK: - Actions
    
    @IBAction private func loginAction(_ sender: Any) {
        logIn()
    }
    
    @IBAction private func resetPassword() {
        guard let email = emailTextField.text, emailTextField.text?.isEmpty == false else {
            presentAlert(with: "Il vous faut renseigner une addresse email")
            return
        }
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error == nil {
                self.showSimpleAlert()
                print("password send")
            } else {
                print("thers is an error")
            }
        }
    }
    
    @IBAction private func noAccount(_ sender: Any) {
        performSegue(withIdentifier: "goToSignUp", sender: self)
    }
    
    // MARK: - Methods
    
    private func logIn() {
           guard let email = emailTextField.text, !email.isEmpty else {
               self.loginButton.shake()
               presentAlert(with: "Merci d'entrer une adresse mail")
               return
           }
           guard let password = passwordTextField.text, !password.isEmpty else {
            self.loginButton.shake()
               presentAlert(with: "Merci d'entrer un mot de passe")
               return
           }
           
           let authService = AuthService()
           authService.signIn(email: email, password: password) { [weak self] authDataResult, error in
               if error == nil && authDataResult != nil {
                   self?.dismiss(animated: true, completion: nil)
               } else {
                   print("Error loging user: \(error!.localizedDescription)")
                self?.presentAlert(with: error?.localizedDescription ?? "Erreur réseau")
               }
           }
       }
    
    internal func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
    
}




