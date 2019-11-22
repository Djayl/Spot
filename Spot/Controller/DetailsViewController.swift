//
//  DetailsViewController.swift
//  Spot
//
//  Created by MacBook DS on 02/10/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Kingfisher
import GoogleMaps

//@available(iOS 13.0, *)
class DetailsViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pictureTakerName: UILabel!
    @IBOutlet weak var spotTitle: UILabel!
    @IBOutlet weak var spotDescription: UILabel!
    @IBOutlet weak var spotDate: UILabel!
    @IBOutlet weak var spotCoordinate: UILabel!
    @IBOutlet weak var favoriteButton: FavoriteButton!
 
    
    // MARK: - Properties
    
    var gradient: CAGradientLayer?
    var spot = Spot()
    var newImageView = UIImageView()
    var favoriteSpots = [Spot]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSpotDetails()
        getImage()
        reverseGeocodeCoordinate(spot.position)
        addGradient()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        navigationController?.setNavigationBarHidden(true, animated: false)
        imageView.addGestureRecognizer(tapGestureRecognizer)
        imageView.isUserInteractionEnabled = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        getImage()
        listenToFavoriteSpot()
    }
    
    // MARK: - Actions
    
    @IBAction func putSpotToFavorite(_ sender: Any) {
        handleCustomButton()
    }
    
    @IBAction func remove(_ sender: Any) {
        spot.map = nil
        goToMapView()
    }
    
    // MARK: - Methods
    
    private func getSpotCreatorName(_ profil: Profil) {
        pictureTakerName.text = profil.userName
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
                UIView.animate(withDuration: 0.2, animations: {
                    view.transform = CGAffineTransform.identity
                })
            default:
                return
            }
        }
    }
    
    private func getSpotDetails() {
        
        guard let name = spot.title else {return}
        spotTitle.text = name.uppercased().toNoSmartQuotes()
        
        guard let description = spot.snippet, description.isEmpty == false else {
            spotDescription.text = "Aucune description n'a été rédigée pour ce Spot"
            return }
        spotDescription.text = description
        guard let date  = (spot.userData as! CustomData).creationDate else {return}
        spotDate.text = date.asString(style: .short)
        guard let creatorName = (spot.userData as! CustomData).creatorName else {return}
        pictureTakerName.text = creatorName
        
    }
    
    private func getImage() {
        guard let urlString = spot.imageURL else {return}
        guard let url = URL(string: urlString) else {return}
        KingfisherManager.shared.retrieveImage(with: url, options: nil) { result in
            let image = try? result.get().image
            if let image = image {
                self.imageView.image = image
            }
        }
    }
    
    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
        let geocoder = GMSGeocoder()
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
                return
            }
            self.spotCoordinate.text = lines.joined(separator: "\n")
        }
    }
    
    private func updateSpot(_ marker: Marker){
        (spot.userData as! CustomData).isFavorite = marker.isFavorite
    }
    
    private func setFavoriteInFirestore(identifier: String, spot: Marker) {
        let firestoreService = FirestoreService<Marker>()
        firestoreService.saveData(endpoint: .favoriteCollection, identifier: identifier, data: spot.dictionary) { [weak self] result in
            switch result {
            case .success(let successMessage):
                print(successMessage)
                print("Successfully added in favorites")
            case .failure(let error):
                print("Error adding document: \(error)")
                self?.presentAlert(with: "Problème réseau")
            }
        }
    }
    
    private func createFavorite() {
        let coordinate = spot.position
        let longitude = coordinate.longitude
        let latitude = coordinate.latitude
        guard let name = spot.title,
            let description = spot.snippet,
            let imageURL = spot.imageURL,
            let uid = (spot.userData as! CustomData).uid,
            let creationDate = (spot.userData as! CustomData).creationDate,
            let creatorName = (spot.userData as! CustomData).creatorName,
            let publicSpot = (spot.userData as! CustomData).publicSpot,
            let isFavorite = (spot.userData as! CustomData).isFavorite else {return}
        let favoriteSpot = Marker(identifier: uid, name: name, description: description, coordinate: GeoPoint(latitude: latitude, longitude: longitude), imageURL: imageURL, isFavorite: isFavorite, publicSpot: publicSpot, creatorName: creatorName, creationDate: creationDate)
        setFavoriteInFirestore(identifier: uid, spot: favoriteSpot)
    }
    
    private func deleteFavoriteFromFirestore(identifier: String) {
        let firestoreService = FirestoreService<Marker>()
        firestoreService.deleteDocumentData(endpoint: .favoriteCollection, identifier: identifier) { [weak self] result in
            switch result {
            case .success(let successMessage):
                print(successMessage)
            case .failure(let error):
                print("Error deleting document: \(error)")
                self?.presentAlert(with: "Problème réseau")
            }
        }
    }
    
    private func removeFavorite() {
        guard let identifier = (spot.userData as! CustomData).uid else {return}
        deleteFavoriteFromFirestore(identifier: identifier)
    }
    
    private func handleCustomButton() {
        favoriteButton.isOn.toggle()
        if !favoriteButton.isOn {
            self.removeFavorite()
        } else {
            self.createFavorite()
        }
    }
    
    private func displaySpot(_ marker: Marker) {
        let name = marker.name
        let mCustomData = CustomData(creationDate: marker.creationDate, uid: marker.identifier, isFavorite: marker.isFavorite, publicSpot: marker.publicSpot, creatorName: marker.creatorName)
        let spot = Spot()
        spot.position = CLLocationCoordinate2D(latitude: marker.coordinate.latitude, longitude: marker.coordinate.longitude)
        spot.title = name
        spot.snippet = marker.description
        spot.userData = mCustomData
        spot.imageURL = marker.imageURL
        favoriteSpots.append(spot)
    }
    
    private func listenToFavoriteSpot() {
        guard let uid = (spot.userData as! CustomData).uid else {return}
        let firestoreService = FirestoreService<Marker>()
        firestoreService.listenCollection(endpoint: .favoriteCollection) { [weak self] result in
            switch result {
            case .success(let favorites):
                for favorite in favorites {
                    if favorite.identifier == uid {
                        self?.favoriteButton.isOn = true
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
                self?.presentAlert(with: "Erreur réseau")
            }
        }
    }
    
    @objc private func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = Colors.nicoDarkBlue
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(scaleImage(_:)))
        newImageView.addGestureRecognizer(pinch)
        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            self.view.addSubview(self.newImageView)
        }, completion: nil)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc private func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = false
        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            sender.view?.removeFromSuperview()
        }, completion: nil)
    }
    
    private func addGradient() {
        gradient = CAGradientLayer()
        gradient?.colors = [Colors.skyBlue.cgColor, UIColor.white]
        gradient?.startPoint = CGPoint(x: 0, y: 0)
        gradient?.endPoint = CGPoint(x: 0, y:1)
        gradient?.frame = view.frame
        self.view.layer.insertSublayer(gradient!, at: 0)
    }
    
    @objc private func goToMapView() {
        self.dismiss(animated: true, completion: nil)
    }
}

