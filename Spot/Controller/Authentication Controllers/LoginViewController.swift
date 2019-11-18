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
    
    @IBOutlet weak var loginButton: CustomButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    var gradient: CAGradientLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradient()
        emailTextField.delegate = self
        passwordTextField.delegate = self   
    }
    
    @IBAction func loginAction(_ sender: Any) {
        logIn()
//        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
//            if error == nil{
//                self.dismiss(animated: true, completion: nil)
//            }
//            else{
//                self.loginButton.shake()
//                let alertController = UIAlertController(title: "Pas si vite!", message: error?.localizedDescription, preferredStyle: .alert)
//                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//
//                alertController.addAction(defaultAction)
//                self.present(alertController, animated: true, completion: nil)
//            }
//        }
        
    }
    
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
                   self?.presentAlert(with: "Erreur serveur")
               }
           }
       }
    
    @IBAction func resetPassword() {
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
    @IBAction func noAccount(_ sender: Any) {
        performSegue(withIdentifier: "goToSignUp", sender: self)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {  
        textField.resignFirstResponder()
        return true
    }
    
    func addGradient() {
        gradient = CAGradientLayer()
        gradient?.colors = [Colors.skyBlue.cgColor,UIColor.white]
        gradient?.startPoint = CGPoint(x: 0, y: 0)
        gradient?.endPoint = CGPoint(x: 0, y:1)
        gradient?.frame = view.frame
        self.view.layer.insertSublayer(gradient!, at: 0)
    }
    
}




