//
//  MapViewController.swift
//  Spot
//
//  Created by MacBook DS on 21/10/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit
import GoogleMaps
import Kingfisher

protocol AddSpotDelegate: class {
    func addSpotToMapView(marker: Spot)
}

@available(iOS 13.0, *)
class MapViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var chooseDataButton: CustomButton!
    @IBOutlet weak var chooseMapTypeButton: UIButton!
    
    // MARK: - Properties
    
    var sourceView: UIView?
    var userPosition: CLLocation?
    let locationManager = CLLocationManager()
    let customMarkerWidth: Int = 50
    let customMarkerHeight: Int = 70
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        overrideUserInterfaceStyle = .light
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        setUpNavigationController()
        setUpTapBarController()
        mapView.addSubview(chooseDataButton)
        mapView.addSubview(chooseMapTypeButton)
        checkIfUserLoggedIn()        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - Actions
    
    @IBAction func mapType(_ sender: Any) {
        chooseMapType(controller: MapViewController())
    }
    
    @IBAction func dataType(_ sender: Any) {
        self.chooseData(controller: MapViewController())
        
    }
    
    @IBAction func goToProfile() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileViewController
               let nc = UINavigationController(rootViewController: vc)
               self.present(nc, animated: true, completion: nil)
    }
    
    
    
    @IBAction func goToExplanation(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ExplanationVC") as! ExplanationViewController
        let nc = UINavigationController(rootViewController: vc)
        self.present(nc, animated: true, completion: nil)
    }
    
    
    // MARK: - Methods
    
    fileprivate func setUpNavigationController() {
        navigationController?.navigationBar.barTintColor = UIColor.systemBackground.withAlphaComponent(0.5)
        navigationController?.navigationBar.isTranslucent = true
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([.font : UIFont(name: "LeagueSpartan-Bold", size: 15)!, .foregroundColor : UIColor.red], for: .normal)
        navigationItem.leftBarButtonItem?.setTitleTextAttributes([.font : UIFont(name: "LeagueSpartan-Bold", size: 15)!, .foregroundColor : UIColor.label], for: .normal)
    }
    
    fileprivate func setUpTapBarController() {
        tabBarController?.tabBar.tintColor = UIColor.green
        tabBarController?.tabBar.unselectedItemTintColor = UIColor.lightGray
        tabBarController?.tabBar.barTintColor = UIColor.systemBackground
        
    }
    
    private func checkIfUserLoggedIn() {
        DispatchQueue.main.async {
            if AuthService.getCurrentUser() == nil {
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "loginVC") as! LoginViewController
                let nc = UINavigationController(rootViewController: vc)
                nc.modalPresentationStyle = .fullScreen
                self.present(nc, animated: true, completion: nil)
            }
        }
    }
    
    
    private func chooseData(controller: UIViewController) {
        let alert = UIAlertController(title: "Choisissez ce que vous voulez voir", message: "Sélectionnez une option", preferredStyle: .actionSheet)
        alert.addColorInTitleAndMessage(color: UIColor.systemBlue, titleFontSize: 20, messageFontSize: 15)
        alert.addAction(UIAlertAction(title: "Les spots publics", style: .default, handler: { (_) in
            self.mapView.clear()
            self.fetchPublicSpots()
            self.listenToPublicSpots()
        }))
        alert.addAction(UIAlertAction(title: "Ma collection privée", style: .default, handler: { (_) in
            self.mapView.clear()
            self.fetchPrivateSpots()
            self.listenToPrivateSpots()
        }))
        alert.addAction(UIAlertAction(title: "Mes favoris", style: .default, handler: { (_) in
            self.mapView.clear()
            self.listenToFavoriteSpots()
        }))
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: { (_) in
            print("User click Dismiss button")
        }))
        self.present(alert, animated: true, completion: {
        })
    }
    
    func chooseMapType(controller: UIViewController) {
        let alert = UIAlertController(title: "Modifier le type de carte", message: "Sélectionnez une option", preferredStyle: .actionSheet)
        
        alert.addColorInTitleAndMessage(color: UIColor.systemBlue, titleFontSize: 20, messageFontSize: 15)
        alert.addAction(UIAlertAction(title: "Basique", style: .default, handler: { (_) in
            self.mapView.mapType = .normal
        }))
        alert.addAction(UIAlertAction(title: "Satellite", style: .default, handler: { (_) in
            self.mapView.mapType = .satellite
        }))
        alert.addAction(UIAlertAction(title: "Hybride", style: .default, handler: { (_) in
            self.mapView.mapType = .hybrid
        }))
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: { (_) in
            print("User click Dismiss button")
        }))
        self.present(alert, animated: true, completion: {
        })
    }
    
    
    @objc private func gotoCreateAnnotation() {
        let createSpotVC = CreateSpotViewController()
        createSpotVC.delegate = self
        navigationController?.pushViewController(createSpotVC, animated: false)
    }
    
    private func fetchPrivateSpots() {
        let firestoreService = FirestoreService<Marker>()
        firestoreService.fetchCollection(endpoint: .spot) { [weak self] result in
            switch result {
            case .success(let markers):
                for marker in markers {
                    self?.displaySpot(marker)
                }
            case .failure(let error):
                print(error.localizedDescription)
                self?.presentAlert(with: "Erreur serveur")
            }
        }
    }
    
    private func listenToFavoriteSpots() {
        let firestoreService = FirestoreService<Marker>()
        firestoreService.listenCollection(endpoint: .favoriteCollection) { [weak self] result in
            switch result {
            case .success(let markers):
                for marker in markers {
                    self?.displaySpot(marker)
                }
            case .failure(let error):
                print(error.localizedDescription)
                self?.presentAlert(with: "Erreur serveur")
            }
        }
    }    
    
    private func fetchPublicSpots() {
        let firestoreService = FirestoreService<Marker>()
        firestoreService.fetchCollection(endpoint: .publicCollection) { [weak self] result in
            switch result {
            case .success(let markers):
                for marker in markers {
                    self?.displaySpot(marker)
                }
            case .failure(let error):
                print(error.localizedDescription)
                self?.presentAlert(with: "Erreur serveur")
            }
        }
    }
    
    @objc private func didTapSpot(spot: Spot) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailsVC") as! DetailsViewController
        let nc = UINavigationController(rootViewController: vc)
        vc.spot = spot
        self.present(nc, animated: true, completion: nil)
    }
    
    @objc private func buttonTapped(marker: GMSMarker) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailsVC") as! DetailsViewController
        let nc = UINavigationController(rootViewController: vc)
        vc.spot = marker as! Spot
        self.present(nc, animated: true, completion: nil)
    }
    
    private func listenToASpot(spot: Spot) {
        guard let spotUid = (spot.userData as! CustomData).uid else {return}
        let firestoreService = FirestoreService<Marker>()
        firestoreService.listenDocument(endpoint: .favorite(spotId: spotUid)) { [weak self] result in
            switch result {
            case .success(let successMessage):
                print(successMessage)
            case .failure(let error):
                print("Error updating document: \(error)")
                self?.presentAlert(with: "Erreur réseau")
            }
        }
    }
    
    private func displaySpot(_ marker: Marker) {
        guard let url = URL.init(string: marker.imageURL ) else {return}
        let mCustomData = CustomData(creationDate: marker.creationDate, uid: marker.identifier, ownerId: marker.ownerId, publicSpot: marker.publicSpot, creatorName: marker.creatorName)
        KingfisherManager.shared.retrieveImage(with: url, options: nil) { result in
            let image = try? result.get().image
            if let image = image {
                DispatchQueue.main.async {
                    let spot = Spot()
                    spot.position = CLLocationCoordinate2D(latitude: marker.coordinate.latitude, longitude: marker.coordinate.longitude)
                    spot.title = marker.name.capitalized
                    spot.snippet = marker.description
                    spot.userData = mCustomData
                    spot.imageURL = marker.imageURL
                    let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: self.customMarkerWidth, height: self.customMarkerHeight), image: image, borderColor: Colors.nicoDarkBlue.withAlphaComponent(0.8))
                    spot.iconView = customMarker
                    spot.map = self.mapView
                }
            }
        }
    }
    
    
    private func listenToPrivateSpots() {
        let firestoreService = FirestoreService<Marker>()
        firestoreService.listenCollection(endpoint: .spot) { [weak self] result in
            switch result {
            case .success(let markers):
                for marker in markers {
                    self?.displaySpot(marker)
                }
            case .failure(let error):
                print("Error updating document: \(error)")
                self?.presentAlert(with: "Erreur réseau")
            }
        }
    }
    
    private func listenToPublicSpots() {
        let firestoreService = FirestoreService<Marker>()
        firestoreService.listenCollection(endpoint: .publicCollection) { [weak self] result in
            switch result {
            case .success(let markers):
                for marker in markers {
                    
                    self?.displaySpot(marker)
                    
                }
            case .failure(let error):
                print("Error updating document: \(error)")
                self?.presentAlert(with: "Erreur réseau")
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

@available(iOS 13.0, *)
extension MapViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        guard status == .authorizedWhenInUse else {return}
        locationManager.startUpdatingLocation()
        mapView.isMyLocationEnabled = true
        mapView.settings.myLocationButton = true
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {return}
        mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
        locationManager.stopUpdatingLocation()
    }
}

// MARK: - GMSMapViewDelegate
@available(iOS 13.0, *)
extension MapViewController: GMSMapViewDelegate, AddSpotDelegate {
    
    func addSpotToMapView(marker: Spot) {
        //        marker.map = mapView
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "CreationVC") as! CreateSpotViewController
        let nc = UINavigationController(rootViewController: vc)
        let location = coordinate
        vc.location = location
        vc.delegate = self
        self.present(nc, animated: true, completion: nil)
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        guard let spot = marker as? Spot else {return}
        didTapSpot(spot: spot)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        return false
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: 200, height: 70))
        view.backgroundColor = UIColor.systemBackground
        view.layer.cornerRadius = 6
        view.layer.borderWidth = 3.0
        view.layer.borderColor = UIColor.systemBackground.cgColor
        
        let lbl1 = UILabel(frame: CGRect.init(x: 8, y: 8, width: view.frame.size.width - 16, height: 17))
        lbl1.font = UIFont(name: "LeagueSpartan-Bold", size: 15)
        lbl1.textColor = UIColor.label
        lbl1.text = marker.title
        view.addSubview(lbl1)
        let lbl2 = UILabel(frame: CGRect.init(x: lbl1.frame.origin.x, y: lbl1.frame.origin.y + lbl1.frame.size.height + 3, width: view.frame.size.width - 16, height: 15))
        lbl2.text = marker.snippet
        lbl2.font = UIFont(name: "GlacialIndifference-Regular", size: 14)
        lbl2.textColor = UIColor.label
        view.addSubview(lbl2)
        return view
    }
}





