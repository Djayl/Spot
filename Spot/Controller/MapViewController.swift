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
import ProgressHUD

protocol AddSpotDelegate: class {
    func addSpotToMapView(marker: Spot)
}


@available(iOS 13.0, *)
class MapViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var chooseDataButton: CustomButton!
    @IBOutlet weak var chooseMapTypeButton: UIButton!
    @IBOutlet weak var refreshView: UIView!
    @IBOutlet weak var chooseView: UIView!
    @IBOutlet weak var chooseMapTypeView: UIView!
    
    // MARK: - Properties
    
    var sourceView: UIView?
    var userPosition: CLLocation?
    let locationManager = CLLocationManager()
    let customMarkerWidth: Int = 50
    let customMarkerHeight: Int = 70
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupNavigationBar()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.delegate = self
        setUpNavigationController()
        setUpTapBarController()
        mapView.addSubview(refreshView)
        mapView.addSubview(chooseView)
        mapView.addSubview(chooseMapTypeView)
        checkIfUserLoggedIn()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        fetchPublicSpots()
    }
    
    // MARK: - Actions
    
    @IBAction func mapType(_ sender: Any) {
        chooseMapType(controller: MapViewController())
    }
    
    @IBAction func dataType(_ sender: Any) {
        self.chooseData(controller: MapViewController())
        
    }
    
    @IBAction func goToProfile() {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "profileVC") as! ProfileViewController
        self.navigationController?.pushViewController(secondViewController, animated: true)
//        let vc = storyboard?.instantiateViewController(withIdentifier: "profileVC") as! ProfileViewController
//               let nc = UINavigationController(rootViewController: vc)
//               self.present(nc, animated: true, completion: nil)
    }
    
    
    
    @IBAction func goToExplanation(_ sender: Any) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ExplanationVC") as! ExplanationViewController
        self.navigationController?.pushViewController(secondViewController, animated: true)
        
//        let vc = storyboard?.instantiateViewController(withIdentifier: "ExplanationVC") as! ExplanationViewController
//        let nc = UINavigationController(rootViewController: vc)
//        self.present(nc, animated: true, completion: nil)
    }
    
    @IBAction func didTapRefresh(_ sender: Any) {
        ProgressHUD.showSuccess(NSLocalizedString("Spots publics à jour", comment: ""))
        self.mapView.clear()
        fetchPublicSpots()
    }
    
    @IBAction func didTapChoose(_ sender: Any) {
        chooseData(controller: MapViewController())
    }
    // MARK: - Methods
    
    fileprivate func setUpNavigationController() {
        navigationController?.navigationBar.barTintColor = UIColor.white.withAlphaComponent(0.9)
//        navigationController?.navigationBar.isTranslucent = true
//        navigationItem.rightBarButtonItem?.setTitleTextAttributes([.font : UIFont(name: "LeagueSpartan-Bold", size: 15)!, .foregroundColor : UIColor.red], for: .normal)
//        navigationItem.leftBarButtonItem?.setTitleTextAttributes([.font : UIFont(name: "LeagueSpartan-Bold", size: 15)!, .foregroundColor : UIColor.label], for: .normal)
    }
    
    fileprivate func setUpTapBarController() {
//        tabBarController?.tabBar.tintColor = UIColor.green
//        tabBarController?.tabBar.unselectedItemTintColor = UIColor.lightGray
        tabBarController?.tabBar.barTintColor = UIColor.white.withAlphaComponent(0.9)
        
    }
    
    fileprivate func setupViews() {
        refreshView.layer.cornerRadius = 10
        chooseView.layer.cornerRadius = 10
        chooseMapTypeView.layer.cornerRadius = 10
    }
   
  
    fileprivate func setupNavigationBar() {
        let logoContainer = UIView(frame: CGRect(x: 0, y: 0, width: 270, height: 30))
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 270, height: 30))
        imageView.contentMode = .scaleAspectFit
        let image = UIImage(named: "Spoteoshadow")
        imageView.image = image
        logoContainer.addSubview(imageView)
        navigationItem.titleView = logoContainer
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
    
    
     func chooseData(controller: UIViewController) {
        let alert = UIAlertController(title: "Choisissez ce que vous voulez voir", message: "Sélectionnez une option", preferredStyle: .actionSheet)
        alert.addColorInTitleAndMessage(color: UIColor.systemBlue, titleFontSize: 20, messageFontSize: 15)
        alert.addAction(UIAlertAction(title: "Les spots publics", style: .default, handler: { (_) in
            self.mapView.clear()
            ProgressHUD.showSuccess(NSLocalizedString("Spots publics à jour", comment: ""))
            self.fetchPublicSpots()
//            self.listenToPublicSpots()
        }))
        alert.addAction(UIAlertAction(title: "Ma collection privée", style: .default, handler: { (_) in
            self.mapView.clear()
            ProgressHUD.showSuccess(NSLocalizedString("Spots privés à jour", comment: ""))
            self.fetchPrivateSpots()
//            self.listenToPrivateSpots()
        }))
        alert.addAction(UIAlertAction(title: "Mes favoris", style: .default, handler: { (_) in
            self.mapView.clear()
            ProgressHUD.showSuccess(NSLocalizedString("Spots favoris à jour", comment: ""))
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
//        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailsVC") as! DetailsViewController
//        let nc = UINavigationController(rootViewController: vc)
//        vc.spot = spot
//        self.present(nc, animated: true, completion: nil)
        
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailsVC") as! DetailsViewController
        secondViewController.spot = spot
        self.navigationController?.pushViewController(secondViewController, animated: true)
//        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailsVC") as! DetailsViewController
//        let nc = UINavigationController(rootViewController: vc)
//        vc.spot = spot
//        self.present(nc, animated: true, completion: nil)
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
        let mCustomData = CustomData(creationDate: marker.creationDate, uid: marker.identifier, ownerId: marker.ownerId, publicSpot: marker.publicSpot, creatorName: marker.creatorName, imageID: marker.imageID)
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
                    let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: self.customMarkerWidth, height: self.customMarkerHeight), image: image, borderColor: Colors.customBlue.withAlphaComponent(0.8))
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
    
//    private struct Constants {
//           static let actionButtonSize = CGSize(width: 64, height: 64)
//       }
//
//    private let actionButton: UIButton = {
//           let button = UIButton(type: .custom)
//           button.translatesAutoresizingMaskIntoConstraints = false
//
//           button.backgroundColor = UIColor.darkGray
//           button.layer.cornerRadius = Constants.actionButtonSize.height/2
//
//           button.addTarget(self, action: #selector(actionButtonTapped(sender:)), for: .touchUpInside)
//
//           return button
//       }()
//
//    private func setupConstraints() {
//        actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        actionButton.widthAnchor.constraint(equalToConstant: Constants.actionButtonSize.width).isActive = true
//        actionButton.heightAnchor.constraint(equalToConstant: Constants.actionButtonSize.height).isActive = true
//        actionButton.bottomAnchor.constraint(equalTo: (tabBarController?.tabBar.safeAreaLayoutGuide.bottomAnchor)!).isActive = true
//    }
//
//     private func setupSubviews() {
//            view.addSubview(actionButton)
//        }
//
//     @objc private func actionButtonTapped(sender: UIButton) {
//            chooseData(controller: MapViewController())
//        }
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
//        let vc = storyboard?.instantiateViewController(withIdentifier: "CreationVC") as! CreateSpotViewController
//        let nc = UINavigationController(rootViewController: vc)
//        let location = coordinate
//        vc.location = location
//        vc.delegate = self
//        self.present(nc, animated: true, completion: nil)
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "CreationVC") as! CreateSpotViewController
        let location = coordinate
        secondViewController.location = location
        secondViewController.delegate = self
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        guard let spot = marker as? Spot else {return}
        didTapSpot(spot: spot)
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        
        return false
    }
    
    func mapView(_ mapView: GMSMapView, markerInfoWindow marker: GMSMarker) -> UIView? {
        let view = UIView(frame: CGRect.init(x: 0, y: 0, width: 170, height: 80))
        view.backgroundColor = Colors.customBlue.withAlphaComponent(0.9)
        view.layer.cornerRadius = 5
//        view.layer.borderWidth = 3.0
//        view.layer.borderColor = UIColor.systemBackground.cgColor
        
        let lbl1 = UILabel(frame: CGRect.init(x: 8, y: 8, width: view.frame.size.width - 16, height: 17))
        lbl1.font = UIFont(name: "Quicksand-Bold", size: 15)
        lbl1.textColor = UIColor.black
        lbl1.numberOfLines = 0
        lbl1.text = marker.title
        view.addSubview(lbl1)
        let lbl2 = UILabel(frame: CGRect.init(x: lbl1.frame.origin.x, y: lbl1.frame.origin.y + lbl1.frame.size.height + 3, width: view.frame.size.width - 16, height: 15))
        lbl2.text = marker.snippet
        lbl2.font = UIFont(name: "Quicksand-Regular", size: 15)
        lbl2.textColor = UIColor.black
        lbl2.numberOfLines = 0
        lbl2.contentMode = .scaleToFill
//        lbl2.lineBreakMode = .byWordWrapping
//        lbl2.adjustsFontSizeToFitWidth = false
        view.addSubview(lbl2)
        return view
    }
}




