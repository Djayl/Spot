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

@available(iOS 13.0, *)
class DetailsViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pictureTakerName: UILabel!
    @IBOutlet weak var spotTitle: UILabel!
    @IBOutlet weak var spotDescription: UILabel!
    @IBOutlet weak var spotDate: UILabel!
    @IBOutlet weak var spotCoordinate: UILabel!
    @IBOutlet weak var favoriteButton: FavoriteButton!
    
    
    
    var gradient: CAGradientLayer?
    var spot = Spot()
   
    
    var newImageView = UIImageView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getSpotDetails()
        getImage()
        reverseGeocodeCoordinate(spot.position)
        addGradient()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.imageView.addGestureRecognizer(tapGestureRecognizer)
        self.imageView.isUserInteractionEnabled = true
        spotDescription.setUpLabel()
        spotDate.setUpLabel()
        spotCoordinate.setUpLabel()
        spotTitle.setUpLabel()
//        listener()
//        handleFavoriteButton()
       
//        print((spot.userData as! CustomData).isFavorite as Any)
       
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
     
        getImage()
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        listenerToPrivate()
        listenerToPublic()
//        handleFavoriteButton()
    }

    
    func getUserName() {
        
    }
    @IBAction func putSpotToFavorite(_ sender: Any) {
        
        addToFavorite()
        
    }

    
    @objc func scaleImage(_ sender: UIPinchGestureRecognizer) {
        if let view = sender.view {
            
            switch sender.state {
            case .changed:
                let pinchCenter = CGPoint(x: sender.location(in: view).x - view.bounds.midX,
                                          y: sender.location(in: view).y - view.bounds.midY)
                let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                    .scaledBy(x: sender.scale, y: sender.scale)
                    .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
                newImageView.transform = transform
                sender.scale = 1
            case .ended:
                // Nice animation to scale down when releasing the pinch.
                // OPTIONAL
                UIView.animate(withDuration: 0.2, animations: {
                    view.transform = CGAffineTransform.identity
                })
            default:
                return
            }
            
        }
        
    }
    

    
    
    private func handleFavoriteButton(){
        
        guard let favorite = (spot.userData as! CustomData).isFavorite else {return}
  
        print("****", favorite)
        if favorite.intValue == 1 || favorite == true{
            favoriteButton.isOn = true
        }
        if favorite.intValue == 0 || favorite == false {
            favoriteButton.isOn = false
        }
//                switch favorite {
//                case true:
//                    favoriteButton.isOn = true
//        
//                case false:
//                    favoriteButton.isOn = false
//                }
        
    }
    
    private func checkFavoriteButton() {
        let vc = FavoriteViewController()
        
        if vc.markers.contains(spot) || (self.spot.userData as! CustomData).isFavorite == true {
            (self.spot.userData as! CustomData).isFavorite = true
            
        } else if !vc.markers.contains(spot) || (self.spot.userData as! CustomData).isFavorite == false {
            (self.spot.userData as! CustomData).isFavorite = false
            
        }
    }
    
    
    private func remove() {
        let vc = FavoriteViewController()
        for marker in vc.markers {
            if marker == spot{
                if (marker.userData as! CustomData).isFavorite == false {
                    (spot.userData as! CustomData).isFavorite = false
                }
            }
        }
    }
    

    
    func getSpotDetails() {
        
        guard let name = spot.title else {return}
        spotTitle.text = name.uppercased().toNoSmartQuotes()
        
        guard let description = spot.snippet, description.isEmpty == false else {
            spotDescription.text = "Aucune description n'a été rédigée pour ce Spot"
            return }
        spotDescription.text = description
        guard let date  = (spot.userData as! CustomData).creationDate else {return}
        spotDate.text = date.asString(style: .short)
        
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
        favoriteButton.isOn.toggle()
        if !favoriteButton.isOn {
            
            
            
            self.removeSpotFromFavorite()
            print("FALSE")
            
            
        } else {
            
            
            
            self.addSpotToFavorite()
            print("TRUE")
        }
        
    }
    
    private func updateSpot(_ marker: Marker){
        (spot.userData as! CustomData).isFavorite = marker.isFavorite
       }
    
    private func listenerToPrivate() {
        guard let spotUid = (spot.userData as! CustomData).uid else {return}
        let firestoreService = FirestoreService<Marker>()
        firestoreService.listenDocument(endpoint: .favorite(spotId: spotUid)) { [weak self] result in
            switch result {
            case .success(let marker):
                
                self?.updateSpot(marker)
                self?.handleFavoriteButton()
                
            case .failure(let error):
                print("Error updating document: \(error)")
                self?.presentAlert(with: "Erreur réseau")
            }
        }
    }
    
    private func listenerToPublic() {
        guard let spotUid = (spot.userData as! CustomData).uid else {return}
        let firestoreService = FirestoreService<Marker>()
        firestoreService.listenDocument(endpoint: .publicSpot(spotId: spotUid)) { [weak self] result in
            switch result {
            case .success(let marker):
                
                self?.updateSpot(marker)
                self?.handleFavoriteButton()
                
            case .failure(let error):
                print("Error updating document: \(error)")
                self?.presentAlert(with: "Erreur réseau")
            }
        }
    }
    
//    private func listenDocument() {
//              // [START listen_document]
//           let uid = Auth.auth().currentUser?.uid
//            let spotID = (spot.userData as! CustomData).uid
//
//        Firestore.firestore().document(uid!).collection("spots").document(spotID!)
//                  .addSnapshotListener { querySnapshot, error in
//                    guard let document = querySnapshot else {
//                      print("Error fetching document: \(error!)")
//                      return
//                    }
//                    guard let data = document.data() else {
//                      print("Document data was empty.")
//                      return
//                    }
//                    print("Current data: \(data)")
//                  }
//              // [END listen_document]
//          }
//
    
    private func addSpotToFavorite() {
        
        guard let spotUid = (spot.userData as! CustomData).uid else {return}
        let firestoreService = FirestoreService<Marker>()
        
        let data = ["isFavorite": true]
        if (spot.userData as! CustomData).publicSpot == false {
            firestoreService.updateData(endpoint: .favorite(spotId: spotUid), data: data) { [weak self] result in
                switch result {
                case .success(let successMessage):
                    print(successMessage)
                case .failure(let error):
                    print("Error updating document: \(error)")
                    self?.presentAlert(with: "Erreur réseau")
                }
            }
        } else {
            firestoreService.updateData(endpoint: .publicSpot(spotId: spotUid), data: data) { [weak self] result in
                switch result {
                case .success(let successMessage):
                    print(successMessage)
                case .failure(let error):
                    print("Error updating document: \(error)")
                    self?.presentAlert(with: "Erreur réseau")
                }
            }
        }
    }
    
    
    private func removeSpotFromFavorite() {
        
        
        
        guard let spotUid = (spot.userData as! CustomData).uid else {return}
        let firestoreService = FirestoreService<Marker>()
        
        
        let data = ["isFavorite": false]
        if (spot.userData as! CustomData).publicSpot == false {
        firestoreService.updateData(endpoint: .favorite(spotId: spotUid), data: data) { [weak self] result in
            switch result {
            case .success(let successMessage):
//                (self?.spot.userData as! CustomData).isFavorite = false
                print(successMessage)
            case .failure(let error):
                print("Error updating document: \(error)")
                self?.presentAlert(with: "Erreur réseau")
            }
        }
        } else {
        firestoreService.updateData(endpoint: .publicSpot(spotId: spotUid), data: data) { [weak self] result in
                switch result {
                case .success(let successMessage):
                    print(successMessage)
                case .failure(let error):
                    print("Error updating document: \(error)")
                    self?.presentAlert(with: "Erreur réseau")
                }
            }
        }
    }
    
    
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .white
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(scaleImage(_:)))
        newImageView.addGestureRecognizer(pinch)
        //        self.view.addSubview(newImageView)
        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            self.view.addSubview(self.newImageView)
        }, completion: nil)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = false
        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            sender.view?.removeFromSuperview()
        }, completion: nil)
        
    }
    
    func addGradient() {
        gradient = CAGradientLayer()
        //        let startColor = UIColor(red: 3/255, green: 196/255, blue: 190/255, alpha: 1)
        //        let endColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        gradient?.colors = [Colors.skyBlue.cgColor, UIColor.white]
        gradient?.startPoint = CGPoint(x: 0, y: 0)
        gradient?.endPoint = CGPoint(x: 0, y:1)
        gradient?.frame = view.frame
        self.view.layer.insertSublayer(gradient!, at: 0)
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

extension Bool {
    var intValue: Int {
        return self ? 1 : 0
    }
}
