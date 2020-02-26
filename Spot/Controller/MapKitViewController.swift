//
//  MapKitViewController.swift
//  Spot
//
//  Created by MacBook DS on 15/02/2020.
//  Copyright © 2020 Djilali Sakkar. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Kingfisher
import FirebaseFirestore
import ProgressHUD

@available(iOS 13.0, *)
class MapKitViewController: UIViewController, UISearchBarDelegate {
    
    // MARK: - Outlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var chooseMapTypeButton: UIButton!
    @IBOutlet weak var refreshView: UIView!
    @IBOutlet weak var chooseView: UIView!
    @IBOutlet weak var chooseMapTypeView: UIView!
    @IBOutlet weak var localizationView: UIView!
    
    // MARK: - Properties
    
    var resultSearchController: UISearchController? = nil
    var selectedPin: MKPlacemark? = nil
    private var myAnnotation = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: 0.00, longitude: 0.00))
    private let locationManager = CLLocationManager()
    private var userPosition: CLLocation?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkIfUserLoggedIn()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
        setupViews()
        setupNavigationBar()
        setUpTapBarController()
        setUpNavigationController()
        setupSearchbar()
        
        mapView.delegate = self
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        mapView.addGestureRecognizer(longTapGesture)
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "AnnotationIdentifier")
        fetchPublicSpots()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        NotificationCenter.default.addObserver(self, selector: #selector(fetchSpots), name: Notification.Name("showSpots"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fetchMySpot), name: Notification.Name("showMySpot"), object: nil)
    }
    
    // MARK: - Actions
    
    @IBAction func didTapMapType(_ sender: Any) {
        chooseMapType(controller: MapKitViewController())
    }
    
    @IBAction func didTapRefresh(_ sender: Any) {
        ProgressHUD.showSuccess(NSLocalizedString("Spots publics à jour", comment: ""))
        self.mapView.removeAnnotations(mapView.annotations)
        fetchPublicSpots()
    }
    
    @IBAction func didTapChooseData(_ sender: Any) {
        chooseData(controller: MapKitViewController())
    }
    
    @IBAction func goToProfile() {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "profileVC") as! ProfileViewController
        self.navigationController?.pushViewController(secondViewController, animated: true)
        
    }
    
    @IBAction func goToExplanation(_ sender: Any) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "ExplanationVC") as! ExplanationViewController
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    @IBAction func didTapLocalization(_ sender: Any) {
        if CLLocationManager.authorizationStatus() == .notDetermined || CLLocationManager.authorizationStatus() == .denied {
            showAlert(title: "", message: "Pour obtenir votre position, merci d'activer la géolocalisation.")
            
        }
        if userPosition != nil {
            setupMap(coordonnees: userPosition!.coordinate)
        }
        
    }
    
    // MARK: - Methods
    
    fileprivate func setupSearchbar() {
        let locationSearchTable = storyboard!.instantiateViewController(withIdentifier: "LocationSearchTable") as! LocationSearchTable
        resultSearchController = UISearchController(searchResultsController: locationSearchTable)
        resultSearchController?.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultSearchController!.searchBar
        searchBar.set(textColor: .systemBlue)
        
        searchBar.placeholder = "Créer un Spot avec une adresse"
        searchBarView.addSubview(searchBar)
        
        locationSearchTable.mapView = mapView
        locationSearchTable.handleMapSearchDelegate = self
        resultSearchController?.hidesNavigationBarDuringPresentation = false
        resultSearchController?.obscuresBackgroundDuringPresentation = true
        definesPresentationContext = true
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
    
    private func setupMap(coordonnees: CLLocationCoordinate2D) {
        //        let span = MKCoordinateSpan(latitudeDelta: myLat , longitudeDelta: myLong)
        //        let region = MKCoordinateRegion(center: coordonnees, span: span)
        //        mapView.setRegion(region, animated: true)
        let span = MKCoordinateSpan.init(latitudeDelta: 0.01, longitudeDelta:
            0.01)
        let coordinate = coordonnees // provide you lat and long
        let region = MKCoordinateRegion.init(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func setMapFocus(centerCoordinate: CLLocationCoordinate2D, radiusInKm radius: CLLocationDistance)
    {
        let diameter = radius * 2000
        let region: MKCoordinateRegion = MKCoordinateRegion(center: centerCoordinate, latitudinalMeters: diameter, longitudinalMeters: diameter)
        self.mapView.setRegion(region, animated: false)
    }
    
    fileprivate func setupViews() {
        refreshView.layer.cornerRadius = 10
        chooseView.layer.cornerRadius = 10
        chooseMapTypeView.layer.cornerRadius = 10
        localizationView.layer.cornerRadius = 10
    }
    
    func chooseMapType(controller: UIViewController) {
        let alert = UIAlertController(title: "Modifier le type de carte", message: "Sélectionnez une option", preferredStyle: .actionSheet)
        
        alert.addColorInTitleAndMessage(color: UIColor.systemBlue, titleFontSize: 20, messageFontSize: 15)
        alert.addAction(UIAlertAction(title: "Basique", style: .default, handler: { (_) in
            self.mapView.mapType = .standard
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
    
    func chooseData(controller: UIViewController) {
        let alert = UIAlertController(title: "Choisissez ce que vous voulez voir", message: "Sélectionnez une option", preferredStyle: .actionSheet)
        alert.addColorInTitleAndMessage(color: UIColor.systemBlue, titleFontSize: 20, messageFontSize: 15)
        alert.addAction(UIAlertAction(title: "Les spots publics", style: .default, handler: { (_) in
            self.mapView.removeAnnotations(self.mapView.annotations)
            ProgressHUD.showSuccess(NSLocalizedString("Spots publics à jour", comment: ""))
            self.fetchPublicSpots()
            //            self.listenToPublicSpots()
        }))
        alert.addAction(UIAlertAction(title: "Ma collection privée", style: .default, handler: { (_) in
            self.mapView.removeAnnotations(self.mapView.annotations)
            ProgressHUD.showSuccess(NSLocalizedString("Spots privés à jour", comment: ""))
            self.fetchPrivateSpots()
            //                        self.listenToPrivateSpots()
        }))
        alert.addAction(UIAlertAction(title: "Mes favoris", style: .default, handler: { (_) in
            self.mapView.removeAnnotations(self.mapView.annotations)
            ProgressHUD.showSuccess(NSLocalizedString("Spots favoris à jour", comment: ""))
            self.fetchFavoriteSpots()
        }))
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: { (_) in
            print("User click Dismiss button")
        }))
        self.present(alert, animated: true, completion: {
        })
    }
    
    private func displayAllOffices(_ marker: Marker) {
        let latitude = marker.coordinate.latitude
        let longitude = marker.coordinate.longitude
        let annotation = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        annotation.creationDate = marker.creationDate
        annotation.creatorName = marker.creatorName
        annotation.imageID = marker.imageID
        annotation.ownerId = marker.ownerId
        annotation.publicSpot = marker.publicSpot
        
        annotation.uid = marker.identifier
        annotation.imageURL = marker.imageURL
        annotation.subtitle = marker.description
        annotation.title = marker.name
        mapView.addAnnotation(annotation)
    }
    
    private func fetchPublicSpots() {
        let firestoreService = FirestoreService<Marker>()
        firestoreService.fetchCollection(endpoint: .publicCollection) { [weak self] result in
            switch result {
            case .success(let markers):
                for marker in markers {
                    self?.displayAllOffices(marker)
                }
            case .failure(let error):
                print(error.localizedDescription)
                self?.presentAlert(with: "Erreur serveur")
            }
        }
    }
    
    private func fetchPrivateSpots() {
        let firestoreService = FirestoreService<Marker>()
        firestoreService.fetchCollection(endpoint: .spot) { [weak self] result in
            switch result {
            case .success(let markers):
                for marker in markers {
                    self?.displayAllOffices(marker)
                }
            case .failure(let error):
                print(error.localizedDescription)
                self?.presentAlert(with: "Erreur serveur")
            }
        }
    }
    
    private func fetchFavoriteSpots() {
        let firestoreService = FirestoreService<Marker>()
        firestoreService.fetchCollection(endpoint: .favoriteCollection) { [weak self] result in
            switch result {
            case .success(let markers):
                for marker in markers {
                    self?.displayAllOffices(marker)
                }
            case .failure(let error):
                print(error.localizedDescription)
                self?.presentAlert(with: "Erreur serveur")
            }
        }
    }
    
    @objc private func didTapSpot(annotation: CustomAnnotation) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "SpotDetailsVC") as! SpotDetailsViewController
        secondViewController.annotation = annotation
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
    
    @objc func longTap(sender: UIGestureRecognizer){
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            let location = CLLocation(latitude: locationOnMap.latitude, longitude: locationOnMap.longitude)
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "SpotCreationVC") as! SpotCreationViewController
            secondViewController.newLocation = location
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
    }
    
    @objc func fetchSpots (notification: NSNotification){
        removeAllAnnotations()
        fetchPublicSpots()
    }
    
    @objc func fetchMySpot (notification: NSNotification){
        removeAllAnnotations()
        fetchPrivateSpots()
    }
    
    private func removeAllAnnotations() {
        for annotation in self.mapView.annotations {
            self.mapView.removeAnnotation(annotation)
        }
    }
    
    fileprivate func setUpNavigationController() {
        navigationController?.navigationBar.barTintColor = UIColor.white.withAlphaComponent(0.9)
        
    }
    
    fileprivate func setUpTapBarController() {
        
        tabBarController?.tabBar.barTintColor = UIColor.white.withAlphaComponent(0.9)
        
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
    
    
}

// MARK: - Location Manager Delegate

@available(iOS 13.0, *)
extension MapKitViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            if let maPosition = locations.last {
                userPosition = maPosition
            }
        }
    }
}

// MARK: - Mapview Delegate

@available(iOS 13.0, *)
extension MapKitViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //  Don't want to show a custom image if the annotation is the user's location.
        if (annotation is MKUserLocation) {
            return nil
        } else {
            let annotationIdentifier = "AnnotationIdentifier"
            let nibName = "MyAnnotationView"
            let viewFromNib = Bundle.main.loadNibNamed(nibName, owner: self, options: nil)?.first as! MyAnnotationView
            var annotationView: MyAnnotationView?
            // if there is a view to be dequeued, use it for the annotation
            if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) as? MyAnnotationView {
                if dequeuedAnnotationView.subviews.isEmpty {
                    dequeuedAnnotationView.addSubview(viewFromNib)
                }
                annotationView = dequeuedAnnotationView
                annotationView?.annotation = annotation
            } else {
                // if no views to dequeue, create an Annotation View
                let av = MyAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
                av.addSubview(viewFromNib)
                annotationView = av     // extend scope to be able to return at the end of the func
            }
            // after we manage to create or dequeue the av, configure it
            if let annotation = annotation as? CustomAnnotation {
                if let annotationView = annotationView, annotation.isKind(of: CustomAnnotation.self) {
                    setupAnnotationView(annotationView: annotationView, annotation: annotation)
                }
            }
            
            if let annotation = annotation as? CustomAnnotation {
                if annotation == myAnnotation {
                    if let annotationView = annotationView, annotation.isKind(of: CustomAnnotation.self) {
                        setupAddressAnnotation(annotationView: annotationView, annotation: myAnnotation)
                    }
                }
            }
            return annotationView
        }
    }
    
    
    private func setupAnnotationView(annotationView: MKAnnotationView, annotation: CustomAnnotation) {
        annotationView.canShowCallout = true
        annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        annotationView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        
        let customView = annotationView.subviews.first as! MyAnnotationView
        
        guard let imageUrl = annotation.imageURL else {return}
        let url = URL(string: imageUrl)
        DispatchQueue.main.async {
            customView.imageView.kf.setImage(with: url)
        }
        customView.imageView.clipsToBounds = true
        customView.layer.cornerRadius = 5
        customView.backgroundColor = .white
        customView.frame = annotationView.frame
        customView.clipsToBounds = true
        customView.layer.borderColor = Colors.blueBalloon.cgColor
        customView.layer.borderWidth = 2
    }
    
    private func setupAddressAnnotation(annotationView: MKAnnotationView, annotation: CustomAnnotation) {
        annotationView.canShowCallout = true
        
        annotationView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let button = UIButton(type: .detailDisclosure)
        annotationView.rightCalloutAccessoryView = button
        button.setImage(UIImage(named: "Spot"), for: .normal)
        let customView = annotationView.subviews.first as! MyAnnotationView
        customView.imageView.image = UIImage(named: "Spot")
        customView.layer.cornerRadius = 5
        customView.backgroundColor = .white
        customView.frame = annotationView.frame
        customView.clipsToBounds = true
        customView.layer.borderColor = Colors.coolYellow.cgColor
        customView.layer.borderWidth = 2
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? CustomAnnotation else { return }
        if annotation != myAnnotation {
            didTapSpot(annotation: annotation)
        } else {
            let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "SpotCreationVC") as! SpotCreationViewController
            let latitude = annotation.coordinate.latitude
            let longitude = annotation.coordinate.longitude
            let location = CLLocation(latitude: latitude, longitude: longitude)
            secondViewController.newLocation = location
            self.navigationController?.pushViewController(secondViewController, animated: true)
        }
    }
}

// MARK: - HandleMapSearch Protocol

protocol HandleMapSearch {
    func passCoordinate(placemark: MKPlacemark)
}

@available(iOS 13.0, *)
extension MapKitViewController: HandleMapSearch {
    func passCoordinate(placemark: MKPlacemark) {
        selectedPin = placemark
        
        mapView.removeAnnotations(mapView.annotations)
        let annotation = CustomAnnotation(coordinate: placemark.coordinate)
        
        myAnnotation = annotation
        print(myAnnotation.coordinate as Any)
        
        annotation.title = "Créer mon Spot"
        mapView.addAnnotation(annotation)
        setupMap(coordonnees: placemark.coordinate)        
    }
    
}
