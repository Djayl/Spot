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
import MapKit


@available(iOS 13.0, *)
class DetailsViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pictureTakerName: UILabel!
    @IBOutlet weak var spotTitle: UILabel!
    @IBOutlet weak var spotDescriptionTextView: UITextView!
    @IBOutlet weak var spotDate: UILabel!
    @IBOutlet weak var spotCoordinate: UILabel!
    @IBOutlet weak var favoriteButton: FavoriteButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var profileCreatorPictureButton: UIButton!
    @IBOutlet weak var equipmentLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    
    
    
    
    // MARK: - Properties
    
    var spot = Spot()
    var newImageView = UIImageView()
    var favoriteSpots = [Spot]()
    private var userName = ""
    private var ownerId = ""
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchProfilInformation()
        setupImageView()
        reverseGeocodeCoordinate(spot.position)
        spotCoordinate.isUserInteractionEnabled = true
        textViewDidChange(spotDescriptionTextView)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
//        navigationController?.setNavigationBarHidden(true, animated: false)
        imageView.addGestureRecognizer(tapGestureRecognizer)
        imageView.isUserInteractionEnabled = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        let backButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(goBack))
        let backButton = UIBarButtonItem(title: "Carte", style: .done, target: self, action: #selector(goBack))
        self.navigationItem.leftBarButtonItem = backButton
        getSpotDetails()
        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = true
        displaySpotOwnerProfile()
        getImage()
        listenToFavoriteSpot()
    }
    
    
    
    // MARK: - Actions
    
    @IBAction func putSpotToFavorite(_ sender: Any) {
        handleCustomButton()
    }
    
    @IBAction func remove(_ sender: Any) {
        presentAlertWithAction(message: "Etes-vous sûr de vouloir effacer ce Spot?") {
            self.spot.map = nil
            self.deleteSpot()
            self.goToMapView()
        }
    }
    @IBAction func goToCreatorProfile(_ sender: Any) {
        fetchSpotOwnerProfile()
    }
    @IBAction func getDirection(_ sender: Any) {
        gps()
    }
    
    // MARK: - Methods
    
    private func getSpotCreatorName(_ profil: Profil) {
        pictureTakerName.text = profil.userName
    }
    
    @objc func goBack() {
//        self.navigationController?.popViewController(animated: true)
        self.navigationController?.popToRootViewController(animated: true)
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
    
    private func setupImageView() {
        profileCreatorPictureButton.layer.cornerRadius = profileCreatorPictureButton.frame.height / 2
        profileCreatorPictureButton.clipsToBounds = true
        profileCreatorPictureButton.layer.borderColor = UIColor.lightGray.cgColor
        profileCreatorPictureButton.layer.borderWidth = 2
    }
    
    func showSpotOwnerProfile(profil: Profil) {
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        let vc = storyboard.instantiateViewController(identifier: "spotCreatorVC") as! SpotCreatorProfileViewController
//        guard let userId = (spot.userData as? CustomData)?.ownerId else {return}
//        vc.userId = userId
//        navigationController?.pushViewController(vc, animated: true)
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "spotCreatorVC") as! SpotCreatorProfileViewController
        guard let userId = (spot.userData as? CustomData)?.ownerId else {return}
        secondViewController.userId = userId
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    private func fetchSpotOwnerProfile() {
        guard let identifier = (spot.userData as? CustomData)?.ownerId else {return}
        let firestoreService = FirestoreService<Profil>()
        firestoreService.fetchDocument(endpoint: .particularUser(userId: identifier)) { [weak self] result in
            switch result {
            case .success(let profil):
                self?.showSpotOwnerProfile(profil: profil)
                self?.setSpotCreatorProfile(profil)
            case .failure(let error):
                print(error.localizedDescription)
                self?.presentAlert(with: "Erreur réseau")
            }
        }
    }
    
    private func displaySpotOwnerProfile() {
        guard let identifier = (spot.userData as? CustomData)?.ownerId else {return}
        let firestoreService = FirestoreService<Profil>()
        firestoreService.fetchDocument(endpoint: .particularUser(userId: identifier)) { [weak self] result in
            switch result {
            case .success(let profil):
                self?.setSpotCreatorProfile(profil)
                self?.getProfileImage(profil)
            case .failure(let error):
                print(error.localizedDescription)
                self?.presentAlert(with: "Erreur réseau")
            }
        }
    }
    
    private func getProfileImage(_ profil: Profil) {
        let urlString = profil.imageURL
        guard let url = URL(string: urlString) else {return}
        KingfisherManager.shared.retrieveImage(with: url, options: nil) { result in
            let image = try? result.get().image
            if let image = image {
                self.profileCreatorPictureButton.setImage(image, for: .normal)
            }
        }
    }
    
    private func setProfilData(_ profil: Profil){
        userName = profil.userName
        ownerId = profil.identifier
    }
    
    private func setSpotCreatorProfile(_ profil: Profil){
        pictureTakerName.text = "\(profil.userName.capitalized)"
        equipmentLabel.text = profil.equipment.capitalized
        ageLabel.text = "\(profil.age) ans"
    }
    
    
    private func fetchProfilInformation() {
        let firestoreService = FirestoreService<Profil>()
        firestoreService.fetchDocument(endpoint: .currentUser) { [weak self] result in
            switch result {
            case .success(let profil):
                self?.setProfilData(profil)
                self?.handleDeleteButton()
            case .failure(let error):
                print(error.localizedDescription)
                self?.presentAlert(with: "Erreur réseau")
            }
        }
    }
    
    private func getSpotDetails() {
        guard let name = spot.title else {return}
        spotTitle.numberOfLines = 0
        spotTitle.text = name.capitalized.toNoSmartQuotes()
        guard let description = spot.snippet else {return}
        spotDescriptionTextView.text = description
        guard let date  = (spot.userData as? CustomData)?.creationDate else {return}
        spotDate.text = "Spot créé le \(date.asString(style: .long))"
        guard let creatorName = (spot.userData as? CustomData)?.creatorName else {return}
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
    
    private func handleDeleteButton() {
        if (spot.userData as? CustomData)?.ownerId == ownerId {
            deleteButton.isHidden = false
        } else {
            deleteButton.isHidden = true
        }
    }
    
    private func deleteSpotFromPrivate(identifier: String) {
        let firestoreService = FirestoreService<Marker>()
        firestoreService.deleteDocumentData(endpoint: .spot, identifier: identifier) { [weak self] result in
            switch result {
            case .success(let successMessage):
                print(successMessage)
            case .failure(let error):
                print("Error deleting document: \(error)")
                self?.presentAlert(with: "Erreur réseau")
            }
        }
    }
    
    private func deleteSpotFromPublic(identifier: String) {
        let firestoreService = FirestoreService<Marker>()
        firestoreService.deleteDocumentData(endpoint: .publicCollection, identifier: identifier) { [weak self] result in
            switch result {
            case .success(let successMessage):
                print(successMessage)
            case .failure(let error):
                print("Error deleting document: \(error)")
                self?.presentAlert(with: "Erreur réseau")
            }
        }
    }
    
    private func deleteSpotFromFavorite(identifier: String) {
        let firestoreService = FirestoreService<Marker>()
        firestoreService.deleteDocumentData(endpoint: .favoriteCollection, identifier: identifier) { [weak self] result in
            switch result {
            case .success(let successMessage):
                print(successMessage)
            case .failure(let error):
                print("Error deleting document: \(error)")
                self?.presentAlert(with: "Erreur réseau")
            }
        }
    }
    
    private func removeImageFromFirebase(spot: Spot) {
        let firebaseStorageManager = FirebaseStorageManager()
        guard let imageID = (spot.userData as? CustomData)?.imageID else {return}
        firebaseStorageManager.deleteImageData(serverFileName: imageID)
    }
    
    private func deleteSpot() {
        guard let uid = (spot.userData as? CustomData)?.uid else {return}
        deleteSpotFromPrivate(identifier: uid)
        deleteSpotFromPublic(identifier: uid)
        deleteSpotFromFavorite(identifier: uid)
        removeImageFromFirebase(spot: spot)
    }
    
    private func createFavorite() {
        let coordinate = spot.position
        let longitude = coordinate.longitude
        let latitude = coordinate.latitude
        guard let name = spot.title,
            let description = spot.snippet,
            let imageURL = spot.imageURL,
            let uid = (spot.userData as? CustomData)?.uid,
            let imageId = (spot.userData as? CustomData)?.imageID,
            let creationDate = (spot.userData as? CustomData)?.creationDate,
            let creatorName = (spot.userData as? CustomData)?.creatorName,
            let publicSpot = (spot.userData as? CustomData)?.publicSpot,
            let ownerId = (spot.userData as? CustomData)?.ownerId else {return}
        let favoriteSpot = Marker(identifier: uid, name: name, description: description, coordinate: GeoPoint(latitude: latitude, longitude: longitude), imageURL: imageURL, ownerId: ownerId, publicSpot: publicSpot, creatorName: creatorName,creationDate: creationDate, imageID: imageId)
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
        guard let identifier = (spot.userData as? CustomData)?.uid else {return}
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
        let mCustomData = CustomData(creationDate: marker.creationDate, uid: marker.identifier, ownerId: marker.ownerId, publicSpot: marker.publicSpot, creatorName: marker.creatorName, imageID: marker.imageID)
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
        newImageView.backgroundColor = Colors.customBlue
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
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = true
        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            sender.view?.removeFromSuperview()
        }, completion: nil)
    }
    
    @objc private func goToMapView() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func gps() {
        let coordinate = spot.position
        let placemark = MKPlacemark(coordinate: coordinate)
        let options = [MKLaunchOptionsDirectionsModeKey:
            MKLaunchOptionsDirectionsModeDriving]
        let map = MKMapItem(placemark: placemark)
        map.openInMaps(launchOptions: options)
    }
    
}

@available(iOS 13.0, *)
extension DetailsViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
}
