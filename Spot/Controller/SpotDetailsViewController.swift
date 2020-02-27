//
//  SpotDetailsViewController.swift
//  Spot
//
//  Created by MacBook DS on 18/01/2020.
//  Copyright © 2020 Djilali Sakkar. All rights reserved.
//

import UIKit
import FirebaseFirestore
import Kingfisher
import MapKit
import ProgressHUD


@available(iOS 13.0, *)
class SpotDetailsViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var spotTitle: UILabel!
    @IBOutlet weak var pictureTakerName: UILabel!
    @IBOutlet weak var spotDescriptionTextView: UITextView!
    @IBOutlet weak var spotDate: UILabel!
    @IBOutlet weak var spotCoordinate: CopyableLabel!
    @IBOutlet weak var favoriteButton: FavoriteButton!
    @IBOutlet weak var profileCreatorPictureButton: UIButton!
    @IBOutlet weak var equipmentLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var updateStatusStackView: UIStackView!
    @IBOutlet weak var statusSwitch: UISwitch!
    @IBOutlet weak var switchLabel: UILabel!
    
    
    // MARK: - Properties
    
//    var spot = Spot()
    var annotation : CustomAnnotation?
    var newImageView = UIImageView()
//    var favoriteSpots = [Spot]()
    private var userName = ""
    private var ownerId = ""
//    weak var delegate: AddSpotDelegate?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        fetchProfilInformation()
        setupImageView()
        getLocation()
//        reverseGeocodeCoordinate(spot.position)
        spotCoordinate.isUserInteractionEnabled = true
        textViewDidChange(spotDescriptionTextView)
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        imageView.addGestureRecognizer(tapGestureRecognizer)
        imageView.isUserInteractionEnabled = true
        spotDescriptionTextView.backgroundColor = UIColor.white
//        spotCoordinate.minimumScaleFactor = 0.1
//        spotCoordinate.adjustsFontSizeToFitWidth = true
         statusSwitch.addTarget(self, action: #selector(stateChanged), for: .valueChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchProfilInformation()
        let backButton = UIBarButtonItem(title: "Retour", style: .done, target: self, action: #selector(goBack))
        self.navigationItem.leftBarButtonItem = backButton
//        getSpotDetails()
        getAnnotationDetails()
        navigationController?.setNavigationBarHidden(false, animated: false)
        navigationController?.navigationBar.barTintColor = UIColor.white
        tabBarController?.tabBar.isHidden = true
        displaySpotOwnerProfile()
        getImage()
        listenToFavoriteSpot()
        setDeleteButton()
        handleSwitch()
    }
    
    
    
    // MARK: - Actions
    
    @IBAction func putSpotToFavorite(_ sender: Any) {
        handleCustomButton()
    }
    
    @IBAction func goToCreatorProfile(_ sender: Any) {
        guard let currentUser = AuthService.getCurrentUser() else { return }
        if currentUser.uid != annotation?.ownerId {
        fetchSpotOwnerProfile()
        } else {
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "profileVC") as! ProfileViewController
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
    }
    @IBAction func getDirection(_ sender: Any) {
        gps()
    }
    @IBAction func didChangedStatus(_ sender: Any) {
        guard let spotId = annotation?.uid else {return}
        let alert1 = UIAlertController(title: "Êtes-vous sûr de vouloir rendre ce Spot public?", message: "", preferredStyle: .alert)
        let alert2 = UIAlertController(title: "Êtes-vous sûr de vouloir rendre ce Spot privé?", message: "", preferredStyle: .alert)
        if statusSwitch.isOn {
        alert1.addAction(UIAlertAction(title: "Oui", style: .default, handler: { action in
            self.updateStatus(data: true, endpoint: .privateSpot(spotId: spotId))
            self.updateStatus(data: true, endpoint: .favoriteSpot(spotId: spotId))
            self.createNewPubliSpot()
            NotificationCenter.default.post(name: Notification.Name("showSpots"), object: nil)
        }))
        alert1.addAction(UIAlertAction(title: "Non", style: .cancel, handler: { action in
            self.statusSwitch.isOn = false
            self.switchLabel.text = "Spot privé"
        }))
            self.present(alert1, animated: true)
        } else {
            alert2.addAction(UIAlertAction(title: "Oui", style: .default, handler: { action in
                self.updateStatus(data: false, endpoint: .privateSpot(spotId: spotId))
                self.updateStatus(data: false, endpoint: .favoriteSpot(spotId: spotId))
                self.deleteSpotAfterSwitching()
                NotificationCenter.default.post(name: Notification.Name("showSpots"), object: nil)
            }))
            alert2.addAction(UIAlertAction(title: "Non", style: .cancel, handler: { action in
                self.statusSwitch.isOn = true
                self.switchLabel.text = "Spot public"
            }))
                self.present(alert2, animated: true)
        }
    }
    
    // MARK: - Methods
    
    @objc private func stateChanged(switchState: UISwitch) {
        
        if statusSwitch.isOn {
            switchLabel.text = "Spot public"
        } else {
            switchLabel.text = "Spot privé"
        }
    }
    
    private func setDeleteButton() {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "trash"), for: .normal)
        button.sizeToFit()
        if annotation?.ownerId == ownerId {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
            button.addTarget(self, action: #selector(removeSpot), for: .touchUpInside)
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
    }
    
    @objc private func removeSpot() {
        presentAlertWithAction(message: "Etes-vous sûr de vouloir effacer ce Spot?") {
            self.deleteSpot()
            NotificationCenter.default.post(name: Notification.Name("showMySpot"), object: nil)
            self.goToMapView()
            
        }
    }
    
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
        profileCreatorPictureButton.layer.borderColor = Colors.customBlue.cgColor
        profileCreatorPictureButton.layer.borderWidth = 2
    }
    
    
    func showSpotOwnerProfile(profil: Profil) {
        
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "spotCreatorVC") as! SpotCreatorProfileViewController
        guard let userId = annotation?.ownerId else {return}
        secondViewController.userId = userId
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    private func fetchSpotOwnerProfile() {
        guard let identifier = annotation?.ownerId else {return}
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
        guard let identifier = annotation?.ownerId else {return}
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
                
                DispatchQueue.main.async {
                    self?.setProfilData(profil)
                    self?.setDeleteButton()
                    self?.handleUpdateButton()
                }
            case .failure(let error):
                print(error.localizedDescription)
                self?.presentAlert(with: "Erreur réseau")
            }
        }
    }
    
    private func saveNewPublicSpotInFirestore(identifier: String, spot: Marker) {
            let firestoreService = FirestoreService<Marker>()
    //        ProgressHUD.showSuccess(NSLocalizedString("Spot public créé!", comment: ""))
            firestoreService.saveData(endpoint: .publicCollection, identifier: identifier, data: spot.dictionary) { [weak self] result in
                switch result {
                case .success(let successMessage):
                    print(successMessage)
                    self?.dismiss(animated: true, completion: nil)
                case .failure(let error):
                    print("Error adding document: \(error)")
                    self?.presentAlert(with: "Problème réseau")
                }
            }
        }
    
    private func deleteSpotAfterSwitching() {
        guard let uid = annotation?.uid else {return}
        ProgressHUD.showSuccess("Ce Spot est désormais privé")
        deleteSpotFromPublic(identifier: uid)
    }
    
    private func createNewPubliSpot() {
        
        guard let latitude = annotation?.coordinate.latitude ,
            let longitude = annotation?.coordinate.longitude else {return}
            let publicSpot = true
        
        guard let identifier = annotation?.uid,
        let name = annotation?.title,
        let description = annotation?.subtitle,
        let imageURL = annotation?.imageURL,
        let ownerId = annotation?.ownerId,
        
        let creatorName = annotation?.creatorName,
        let creationDate = annotation?.creationDate,
        let imageID = annotation?.imageID else {return}
        
        
        let marker = Marker(identifier: identifier, name: name, description: description, coordinate: GeoPoint(latitude: latitude, longitude: longitude), imageURL: imageURL, ownerId: ownerId, publicSpot: publicSpot, creatorName: creatorName, creationDate: creationDate, imageID: imageID)
        
        ProgressHUD.showSuccess("Ce Spot est désormais public")
        saveNewPublicSpotInFirestore(identifier: identifier, spot: marker)
        
        
//        self.navigationController?.popViewController(animated: true)
    }
    
    private func handleSwitch() {
        if annotation?.publicSpot == true {
            statusSwitch.isOn = true
            switchLabel.text = "Spot public"
        } else {
            statusSwitch.isOn = false
            switchLabel.text = "Spot privé"
        }
    }
    
    private func updateStatus(data: Bool, endpoint: Endpoint) {
//        guard let spotId = (spot.userData as? CustomData)?.uid else {return}
        let firestoreService = FirestoreService<Marker>()
        let data = ["publicSpot":data]
        firestoreService.updateDataIfExists(endpoint: endpoint, data: data) { [weak self] result in
            switch result {
            case .success(let successMessage):
                print(successMessage)
                print("Le spot a été rendu public")
//                self?.dismiss(animated: true, completion: nil)
            case .failure(let error):
                print("Error adding document: \(error)")
                self?.presentAlert(with: "Erreur réseau")
            }
        }
    }
    
//    private func getSpotDetails() {
//        guard let name = spot.title else {return}
//        spotTitle.numberOfLines = 0
//        spotTitle.text = name.capitalized.toNoSmartQuotes()
//        guard let description = spot.snippet, !description.isEmpty else {return}
//        spotDescriptionTextView.text = description
//        guard let date  = (spot.userData as? CustomData)?.creationDate else {return}
//        spotDate.text = "Spot créé le \(date.asString(style: .long))"
//        guard let creatorName = (spot.userData as? CustomData)?.creatorName else {return}
//        pictureTakerName.text = creatorName
//    }
    
    private func getAnnotationDetails() {
        guard let name = annotation?.title else {return}
        spotTitle.text = name.capitalized.toNoSmartQuotes()
        guard let description = annotation?.subtitle, !description.isEmpty else {return}
        spotDescriptionTextView.text = description
        guard let date = annotation?.creationDate else {return}
        spotDate.text = "Spot créé le \(date.asString(style: .long))"
        guard let creatorName = annotation?.creatorName else {return}
        pictureTakerName.text = creatorName
    }
    
    
    private func getImage() {
        guard let urlString = annotation?.imageURL else {return}
        guard let url = URL(string: urlString) else {return}
        KingfisherManager.shared.retrieveImage(with: url, options: nil) { result in
            let image = try? result.get().image
            if let image = image {
                self.imageView.image = image
            }
        }
    }
    
//    private func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
//        let geocoder = GMSGeocoder()
//        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
//            guard let address = response?.firstResult(), let lines = address.lines else {
//                return
//            }
//            self.spotCoordinate.text = lines.joined(separator: "\n")
//        }
//    }
    
    private func getLocation() {
         
          let geoCoder = CLGeocoder()
        guard let coordinate = annotation?.coordinate else {return}
        let coor = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
          geoCoder.reverseGeocodeLocation(coor) { [weak self] (placemarks, error) in
              guard let self = self else { return }
              if let _ = error {
                  print("geocoder not dispo")
                  return
              }
              guard let placemark = placemarks?.first else {
                  return
              }
//              let lon = String(format: "%.04f", (placemark.location?.coordinate.longitude ?? 0.0))
//              let lat = String(format: "%.04f", (placemark.location?.coordinate.latitude ?? 0.0))
              let country = placemark.country
              let locality = placemark.locality

//              self.spotCoordinate.text = "\(lat) \(lon)"
              let streetNumber = placemark.subThoroughfare
              let streetName = placemark.thoroughfare 

              DispatchQueue.main.async {
                let address = [streetNumber, streetName, locality, country].compactMap { $0 }
                .joined(separator: " ")
                self.spotCoordinate.text = address
//                  self.spotCoordinate.text = "\(streetNumber) \(streetName) \(locality) \(country)"
                    
              } // dispatch
          }// geocoder
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
    
    private func handleUpdateButton() {
        if annotation?.ownerId == ownerId  {
                updateStatusStackView.isHidden = false
                handleSwitch()
            } else {
                updateStatusStackView.isHidden = true
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
                self?.presentAlert(with: "DELETE SPOT FROM PUBLIC")
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
    
    private func removeImageFromFirebase() {
        let firebaseStorageManager = FirebaseStorageManager()
        guard let imageID = annotation?.imageID else {return}
        firebaseStorageManager.deleteImageData(serverFileName: imageID)
    }
    
    private func deleteSpot() {
        guard let uid = annotation?.uid else {return}
        ProgressHUD.showSuccess(NSLocalizedString("Le Spot a bien été effacé", comment: ""))
        deleteSpotFromPrivate(identifier: uid)
        deleteSpotFromPublic(identifier: uid)
        deleteSpotFromFavorite(identifier: uid)
        removeImageFromFirebase()
    }
    
    private func createFavorite() {
        guard let coordinate = annotation?.coordinate else {return}
        let longitude = coordinate.longitude
        let latitude = coordinate.latitude
        guard let name = annotation?.title,
            let description = annotation?.subtitle,
            let imageURL = annotation?.imageURL,
            let uid = annotation?.uid,
            let imageId = annotation?.imageID,
            let creationDate = annotation?.creationDate,
            let creatorName = annotation?.creatorName,
            let publicSpot = annotation?.publicSpot,
            let ownerId = annotation?.ownerId else {return}
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
        guard let identifier = annotation?.uid else {return}
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
    
//    private func displaySpot(_ marker: Marker) {
//        let name = marker.name
//        let mCustomData = CustomData(creationDate: marker.creationDate, uid: marker.identifier, ownerId: marker.ownerId, publicSpot: marker.publicSpot, creatorName: marker.creatorName, imageID: marker.imageID)
//        let spot = Spot()
//        spot.position = CLLocationCoordinate2D(latitude: marker.coordinate.latitude, longitude: marker.coordinate.longitude)
//        spot.title = name
//        spot.snippet = marker.description
//        spot.userData = mCustomData
//        spot.imageURL = marker.imageURL
//        favoriteSpots.append(spot)
//    }
    
    private func listenToFavoriteSpot() {
        guard let uid = annotation?.uid else {return}
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
        newImageView.backgroundColor = UIColor.white
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
//        self.dismiss(animated: true, completion: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func gps() {
        guard let coordinate = annotation?.coordinate else {return}
        let placemark = MKPlacemark(coordinate: coordinate)
        let options = [MKLaunchOptionsDirectionsModeKey:
            MKLaunchOptionsDirectionsModeDriving]
        let map = MKMapItem(placemark: placemark)
        map.openInMaps(launchOptions: options)
    }
    
}

@available(iOS 13.0, *)
extension SpotDetailsViewController: UITextViewDelegate {
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
