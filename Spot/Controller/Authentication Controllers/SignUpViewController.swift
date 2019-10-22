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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradient()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        passwordConfirmTextField.delegate = self
    }
    
    @IBAction func signUpAction(_ sender: Any) {
        
        if passwordTextField.text != passwordConfirmTextField.text{
            signUpButton.shake()
            let alertController = UIAlertController(title: "Mot de passe incorrect", message: "Merci de ressaisir votre mot de passe", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
            
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else{
            Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!){ (user, error) in
                if error == nil {
                    self.performSegue(withIdentifier: "signupToSpot", sender: self)
                    let uid = Auth.auth().currentUser?.uid
                
                    let userData = [
                        "uid": uid,
                        "name": self.userNameTextField.text
                    ]
                    FirestoreReferenceManager.referenceForUserPublicData(uid: uid!).setData(userData as [String : Any], merge: true) { (err) in
                        if let err = err {
                            print(err.localizedDescription)
                        }
                        print("successfully done")
                    }
                }
                else{
                    self.signUpButton.shake()
                    let alertController = UIAlertController(title: "Erreur", message: error?.localizedDescription, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {   //delegate method
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
