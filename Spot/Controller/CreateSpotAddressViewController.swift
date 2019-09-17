//
//  CreateSpotAddressViewController.swift
//  Spot
//
//  Created by MacBook DS on 17/09/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase

class CreateSpotAddressViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var addressTextField: UITextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var subtitleTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var addSpotButton: UIButton!
    
   
    weak var delegate: AddSpotDelegate!
    var myImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
    }
    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        guard let address = addressTextField.text else {return true}
//
//        if !address.isEmpty  {
//
//        getCoordinate(from: address)
//        }
//        return true
//    }
    
    func getCoordinate(from address: String) {
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            if error != nil {
                print(error!)
            }
            
            if let coor = placemarks?.first?.location?.coordinate {
                
                let annotation = Spot(title: "", subtitle: "", coordinate: coor, info: "", image: UIImage())
                
                //                annotation.title = placemarks?.first?.name
                annotation.title = self.titleTextField.text
                //                annotations.append(annotation)
                //                print(annotations.count)
                
                self.delegate.addSpotToMapView(annotation: annotation)
                self.goToMapView()
            }
        }
    }
    
    @IBAction func createSpot(_ sender: Any) {
        
        guard let address = addressTextField.text else {return}
        
        if !address.isEmpty  {
            
            getCoordinate(from: address)
    }
        
    }
    @objc func goToMapView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc private func hideKeyboard() {
        addressTextField.resignFirstResponder()
        titleTextField.resignFirstResponder()
        subtitleTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    fileprivate func setUpKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChange), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    @objc func keyboardWillChange(notification: Notification){
        guard let keyboardRect = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {return}
        if notification.name == UIResponder.keyboardWillShowNotification || notification.name == UIResponder.keyboardWillChangeFrameNotification {
            view.frame.origin.y = -keyboardRect.height
        } else {
            view.frame.origin.y = 0
        }
        
    }
}
