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
    
    @IBOutlet weak var signUpButton: CustomButton!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordConfirmTextField: UITextField!
    
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
    
    @IBAction func signUpAction(_ sender: Any) {
        createUserAccount()
//        if passwordTextField.text != passwordConfirmTextField.text{
//            signUpButton.shake()
//            let alertController = UIAlertController(title: "Mot de passe incorrect", message: "Merci de ressaisir votre mot de passe", preferredStyle: .alert)
//            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//
//            alertController.addAction(defaultAction)
//            self.present(alertController, animated: true, completion: nil)
//        } else {
//            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!){ (user, error) in
//                if error == nil {
//                    self.performSegue(withIdentifier: "signupToSpot", sender: self)
//                    let uid = Auth.auth().currentUser?.uid
//                    let userData = [
//                        "uid": uid,
//                        "name": self.userNameTextField.text]
//                    FirestoreReferenceManager.referenceForUserPublicData(uid: uid!).setData(userData as [String : Any], merge: true) { (err) in
//                        if let err = err {
//                            print(err.localizedDescription)
//                        }
//                        print("successfully done")
//                    }
//                } else {
//                    self.signUpButton.shake()
//                    let alertController = UIAlertController(title: "Erreur", message: error?.localizedDescription, preferredStyle: .alert)
//                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
//                    alertController.addAction(defaultAction)
//                    self.present(alertController, animated: true, completion: nil)
//                }
//            }
//        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
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
        guard let passwordConfirmed = passwordConfirmTextField.text, !passwordConfirmed.isEmpty else {
            signUpButton.shake()
            presentAlert(with: "Merci de confirmer votre mot de passe")
            return
        }
        
        authService.signUp(email: email, password: password) { (authResult, error) in
            if error == nil && authResult != nil {
                guard let currentUser = AuthService.getCurrentUser() else { return }
                
                let profil = Profil(identifier: currentUser.uid, email: email, userName: userName)
                self.saveUserData(profil)
//                self.performSegue(withIdentifier: "signupToSpot", sender: self)
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

//extension UITextField {
//    
//    func checkUsername(field: String, completion: @escaping (Bool) -> Void) {
//        let uid = Auth.auth().currentUser?.uid
//        let collectionRef = FirestoreReferenceManager.referenceForUserPublicData(uid: uid!).
//        collectionRef.whereField("username", isEqualTo: field).getDocuments { (snapshot, err) in
//            if let err = err {
//                print("Error getting document: \(err)")
//            } else if (snapshot?.isEmpty)! {
//                completion(false)
//            } else {
//                for document in (snapshot?.documents)! {
//                    if document.data()["username"] != nil {
//                        completion(true)
//                    }
//                }
//            }
//        }
//    }
//}
