//
//  DetailsViewController.swift
//  Spot
//
//  Created by MacBook DS on 02/10/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import GoogleMaps

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pictureTakerName: UILabel!
    @IBOutlet weak var spotTitle: UILabel!
    @IBOutlet weak var spotDescription: UILabel!
    @IBOutlet weak var spotDate: UILabel!
    @IBOutlet weak var spotCoordinate: UILabel!
    @IBOutlet weak var favoriteButton: FavoriteButton!
    
    
    var spot = Spot()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSpotDetails()
        getImage()
        reverseGeocodeCoordinate(spot.position)
  
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))

        self.imageView.addGestureRecognizer(tapGestureRecognizer)
        self.imageView.isUserInteractionEnabled = true
        spotDescription.setUpLabel()
        spotDate.setUpLabel()
        spotCoordinate.setUpLabel()
        spotTitle.setUpLabel()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        getImage()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(true)
//        getImage()
//    }
    
    func getUserName() {
        
    }
    @IBAction func putSpotToFavorite(_ sender: Any) {
        addToFavorite()
    }
    
//    private func getDate() {
//        guard let uid = Auth.auth().currentUser?.uid else {return}
//        FirestoreReferenceManager.referenceForUserPublicData(uid: uid).collection("Spots").getDocuments { (querySnapshot, error) in
//            if let error = error {
//                print("Error getting documents: \(error)")
//            } else {
//                for document in querySnapshot!.documents {
//                    let creationDate = document.get("createdAt") as? String
//                    self.spotDate.text = creationDate
//    }
//            }
//        }
//    }
    
    fileprivate func handleFavoriteButton() {
        let favorite = (spot.userData as! CustomData).isFavorite
        print(favorite)
        if favorite == "Yes" {
            favoriteButton.isOn = true
        } else {
            favoriteButton.isOn = false
        }
    }
    
    func getSpotDetails() {
        
        
        guard let name = spot.title else {return}
        spotTitle.text = name.uppercased()
        
        guard let description = spot.snippet, description.isEmpty == false else {
            spotDescription.text = "Aucune description n'a été rédigée pour ce Spot"
            return }
        spotDescription.text = description
        let date  = (spot.userData as! CustomData).creationDate
        spotDate.text = date.asString(style: .short)
        
//        handleFavoriteButton()
    }
    
    func getImage() {
        
        guard let urlString = spot.imageURL else {return}
        
        guard let url = URL(string: urlString) else {return}
        
        KingfisherManager.shared.retrieveImage(with: url, options: nil) { result in
            
            let image = try? result.get().image
            
            if let image = image {
                self.imageView.image = image
            }
      
        }
    }
    
    func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
       
          let geocoder = GMSGeocoder()
       
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
              return
            }
    
            self.spotCoordinate.text = lines.joined(separator: "\n")
              
          }
        }
    
    private func addToFavorite() {
        let uid = Auth.auth().currentUser?.uid
        let spotUid = (spot.userData as! CustomData).uid
        let ref = FirestoreReferenceManager.referenceForUserPublicData(uid: uid!).collection("Spots").document(spotUid)
        
        switch favoriteButton.isOn {
        case true:
            favoriteButton.isOn = false
            ref.updateData(["isFavorite": "Yes"]) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                print("Succesfully Updated data")
            }
        case false:
            favoriteButton.isOn = true
            ref.updateData(["isFavorite": "No"]) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                print("Succesfully Updated data")
            }
        }
    }
    
  
    
        @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .white
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
  
    
    
    @IBAction func remove(_ sender: Any) {
        spot.map = nil
        goToMapView()
    }
    
    
    @objc func goToMapView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    

    
}

extension UIImageView{
    
    func makeRounded() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
    
}

extension UILabel {
    func setUpLabel() {
        layer.cornerRadius = 10
        self.clipsToBounds = true
    }
}

extension Date {
  func asString(style: DateFormatter.Style) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = style
    return dateFormatter.string(from: self)
  }
}
