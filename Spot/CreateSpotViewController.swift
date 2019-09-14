//
//  CreateSpotViewController.swift
//  Spot
//
//  Created by MacBook DS on 10/09/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit
import CoreLocation



class CreateSpotViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
//    var spot: Spot?
//    var location = [CLLocationCoordinate2D]()
//    var Thelocation: CLLocationCoordinate2D!
    var location: CLLocation!
    weak var delegate: AddSpotDelegate!
    
    

    @IBOutlet weak var titleTextfield: UITextField!
    @IBOutlet weak var subtitleTextfield: UITextField!
    @IBOutlet weak var creationButton: UIButton!
    @IBOutlet weak var pictureView: UIImageView!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("success")
        titleTextfield.delegate = self
        subtitleTextfield.delegate = self
        descriptionTextView.delegate = self
        creationButton.layer.cornerRadius = 10
        descriptionTextView.text = "Type your description"
        
        descriptionTextView.layer.cornerRadius = 5
        descriptionTextView.layer.borderColor = UIColor.gray.withAlphaComponent(0.5).cgColor
        descriptionTextView.layer.borderWidth = 0.5
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
        
        setUpKeyboard()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
//    func createSpot(from coordinate: CLLocation) {
//        let geopoint = CLGeocoder()
//        geopoint.reverseGeocodeLocation(coordinate) { (placemarks, error) in
//            if error != nil {
//                print(error!)
//            }
//            if let coor = placemarks?.first?.location?.coordinate {
//
//                let annotation = Spot(title: String(), subtitle: String(), coordinate: coor, info: String())
//                annotation.title = self.titleTextfield.text
//                self.delegate?.addSpotToMapView(annotation: annotation)
//                self.goToMapView()
//    }
//
//    }
//    }
//    func getLocation() {
//    let point = CLLocation(latitude: location[0].coordinate.latitude, longitude: location[0].coordinate.longitude)
//    point.geocode { placemark, error in
//    if let error = error as? CLError {
//    print("CLError:", error)
//    return
//    } else if let placemark = placemark?.first {
//    print(placemark.location?.coordinate as Any)
//    // you should always update your UI in the main thread
//    DispatchQueue.main.async {
//        print(placemark.location?.coordinate as Any)
////        if let coor = placemark.location?.coordinate {
//        let annotation = Spot(title: "", subtitle: "", coordinate: CLLocationCoordinate2D(), info: "")
//            annotation.title = self.titleTextfield.text
//            print(annotation.title as Any)
//            print(annotation.coordinate)
//            self.delegate.addSpotToMapView(annotation: annotation)
//            self.goToMapView()
//    //  update UI here
//    print("name:", placemark.name ?? "unknown")
//
//    print("address1:", placemark.thoroughfare ?? "unknown")
//    print("address2:", placemark.subThoroughfare ?? "unknown")
//    print("neighborhood:", placemark.subLocality ?? "unknown")
//    print("city:", placemark.locality ?? "unknown")
//
//    print("state:", placemark.administrativeArea ?? "unknown")
//    print("subAdministrativeArea:", placemark.subAdministrativeArea ?? "unknown")
//    print("zip code:", placemark.postalCode ?? "unknown")
//    print("country:", placemark.country ?? "unknown", terminator: "\n\n")
//
//    print("isoCountryCode:", placemark.isoCountryCode ?? "unknown")
//    print("region identifier:", placemark.region?.identifier ?? "unknown")
//
//    print("timezone:", placemark.timeZone ?? "unknown", terminator:"\n\n")
//
//    // Mailind Address
////    print(placemark.mailingAddress ?? "unknown")
////    }
//    }
//    }
//    }
//    }
    
    func getSpot() {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if error != nil {
                print(error!)
            }
            if let coor = placemarks?.first?.location?.coordinate {
                let annotation = Spot(title: "", subtitle: "", coordinate: coor, info: "")
                print(annotation.coordinate)
                annotation.title = self.titleTextfield.text
                annotation.subtitle = self.subtitleTextfield.text
                annotation.info = self.descriptionTextView.text
                self.delegate.addSpotToMapView(annotation: annotation)
                print(annotation)
                self.goToMapView()
            }
        }
    }
    

    
    @objc func goToMapView() {
//        navigationController?.popViewController(animated: false)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendData(_ sender: Any) {

        getSpot()
       
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
    

@objc private func hideKeyboard() {
    titleTextfield.resignFirstResponder()
    subtitleTextfield.resignFirstResponder()
    descriptionTextView.resignFirstResponder()
}

func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
}


}
extension CLLocation {
    func geocode(completion: @escaping (_ placemark: [CLPlacemark]?, _ error: Error?) -> Void)  {
        CLGeocoder().reverseGeocodeLocation(self, completionHandler: completion)
    }
}


