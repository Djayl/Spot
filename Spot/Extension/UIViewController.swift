//
//  UIViewController.swift
//  Spot
//
//  Created by MacBook DS on 19/11/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func setUpKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func keyboardWillChange(notification: Notification){
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            view.frame.origin.y = -keyboardRect.height
        } else {
            view.frame.origin.y = 0
        }
    }
    
    /// Method that displays an alert with a custom message
    func presentAlert(with message: String) {
        let alertVC = UIAlertController(title: "Pas si vite!", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    /// Method that presents an alert with an action
    func presentAlertWithAction(message: String, actionHandler: @escaping () -> Void) {
        let alertVC = UIAlertController(title: "Attention!", message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "Oui", style: .default, handler: { _ in
            actionHandler()
        }))
        alertVC.addAction(UIAlertAction(title: "Non", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
  
    func showSimpleAlert() {
        let alert = UIAlertController(title: "Email oublié", message: "Un mail vient de vous être transmis",preferredStyle: UIAlertController.Style.alert)
        
        alert.addAction(UIAlertAction(title: "OK",
                                      style: UIAlertAction.Style.default,
                                      handler: {(_: UIAlertAction!) in
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func showKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShowing), name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHiding), name: UIApplication.keyboardWillHideNotification, object: nil)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(hideKeyboard)))
    }
    
    @objc func keyboardShowing(notification: Notification){
        if let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue, view.frame.minY == 0 {
            UIView.animate(withDuration: 0.25, animations: {
                self.view.frame.origin.y -= keyboardFrame.height
            })
        }
    }
    
    @objc func keyboardHiding(notification: Notification){
        UIView.animate(withDuration: 0.25) {
            self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        }
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    
}
