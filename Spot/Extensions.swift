//
//  Extensions.swift
//  Spot
//
//  Created by MacBook DS on 18/09/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit
import CoreLocation

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

//        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: { _ in
//               //Cancel Action
//           }))
           alert.addAction(UIAlertAction(title: "OK",
                                         style: UIAlertAction.Style.default,
                                         handler: {(_: UIAlertAction!) in
                                           //Sign out action
           }))
           self.present(alert, animated: true, completion: nil)
       }
    
}

extension CLLocation {
    func geocode(completion: @escaping (_ placemark: [CLPlacemark]?, _ error: Error?) -> Void)  {
        CLGeocoder().reverseGeocodeLocation(self, completionHandler: completion)
    }
}
extension UINavigationController{
       func hideNavigationItemBackground() {
           self.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
           self.navigationBar.shadowImage = UIImage()
           self.navigationBar.isTranslucent = true
           self.view.backgroundColor = UIColor.clear
       }
       
   }

extension UISearchBar {

    func getTextField() -> UITextField? { return value(forKey: "searchField") as? UITextField }
    func set(textColor: UIColor) { if let textField = getTextField() { textField.textColor = textColor } }
    func setPlaceholder(textColor: UIColor) { getTextField()?.setPlaceholder(textColor: textColor) }
    func setClearButton(color: UIColor) { getTextField()?.setClearButton(color: color) }

    func setTextField(color: UIColor) {
        guard let textField = getTextField() else { return }
        switch searchBarStyle {
        case .minimal:
            textField.layer.backgroundColor = color.cgColor
            textField.layer.cornerRadius = 6
        case .prominent, .default: textField.backgroundColor = color
        @unknown default: break
        }
    }

    func setSearchImage(color: UIColor) {
        guard let imageView = getTextField()?.leftView as? UIImageView else { return }
        imageView.tintColor = color
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
    }
}

private extension UITextField {

    private class Label: UILabel {
        private var _textColor = UIColor.lightGray
        override var textColor: UIColor! {
            set { super.textColor = _textColor }
            get { return _textColor }
        }

        init(label: UILabel, textColor: UIColor = .lightGray) {
            _textColor = textColor
            super.init(frame: label.frame)
            self.text = label.text
            self.font = label.font
        }

        required init?(coder: NSCoder) { super.init(coder: coder) }
    }


    private class ClearButtonImage {
        static private var _image: UIImage?
        static private var semaphore = DispatchSemaphore(value: 1)
        static func getImage(closure: @escaping (UIImage?)->()) {
            DispatchQueue.global(qos: .userInteractive).async {
                semaphore.wait()
                DispatchQueue.main.async {
                    if let image = _image { closure(image); semaphore.signal(); return }
                    guard let window = UIApplication.shared.windows.first else { semaphore.signal(); return }
                    let searchBar = UISearchBar(frame: CGRect(x: 0, y: -200, width: UIScreen.main.bounds.width, height: 44))
                    window.rootViewController?.view.addSubview(searchBar)
                    searchBar.text = "txt"
                    searchBar.layoutIfNeeded()
                    _image = searchBar.getTextField()?.getClearButton()?.image(for: .normal)
                    closure(_image)
                    searchBar.removeFromSuperview()
                    semaphore.signal()
                }
            }
        }
    }

    func setClearButton(color: UIColor) {
        ClearButtonImage.getImage { [weak self] image in
            guard   let image = image,
                let button = self?.getClearButton() else { return }
            button.imageView?.tintColor = color
            button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        }
    }

    var placeholderLabel: UILabel? { return value(forKey: "placeholderLabel") as? UILabel }

    func setPlaceholder(textColor: UIColor) {
        guard let placeholderLabel = placeholderLabel else { return }
        let label = Label(label: placeholderLabel, textColor: textColor)
        placeholderLabel.removeFromSuperview() // To remove existing label. Otherwise it will overwrite it if called multiple times.
        setValue(label, forKey: "placeholderLabel")
    }

    func getClearButton() -> UIButton? { return value(forKey: "clearButton") as? UIButton }
}

extension String {
    func toNoSmartQuotes() -> String {
        let userInput: String = self
        return userInput.folding(options: .diacriticInsensitive, locale: .current)
    }
}

//extension Array where Element: Equatable {
//    mutating func removeDuplicates() {
//        var result = [Element]()
//        for value in self {
//            if !result.contains(value) {
//                result.append(value)
//            }
//        }
//        self = result
//    }
//}

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()

        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }

    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
