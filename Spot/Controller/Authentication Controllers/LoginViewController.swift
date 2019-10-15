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
        
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if error == nil{
                self.performSegue(withIdentifier: "loginToSpot", sender: self)
            }
            else{
                self.loginButton.shake()
                let alertController = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {  
        textField.resignFirstResponder()
        return true
    }
    
    func addGradient() {
        gradient = CAGradientLayer()
        //        let startColor = UIColor(red: 3/255, green: 196/255, blue: 190/255, alpha: 1)
        //        let endColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        gradient?.colors = [Colors.coolGreen.cgColor,Colors.coolRed.cgColor]
        gradient?.startPoint = CGPoint(x: 0, y: 0)
        gradient?.endPoint = CGPoint(x: 0, y:1)
        gradient?.frame = view.frame
        self.view.layer.insertSublayer(gradient!, at: 0)
    }
    
    
    
}
