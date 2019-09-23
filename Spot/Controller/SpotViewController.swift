//
//  ViewController.swift
//  Spot
//
//  Created by MacBook DS on 10/09/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import Firebase
import Kingfisher

protocol AddSpotDelegate: class {
    func addSpotToMapView(annotation: Spot)
}

class SpotViewController: UIViewController, AddSpotDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var addButton: CustomButton!
    
    var latitudeInit: Double = 48.853506
    var longitudeInit: Double = 2.348784
    var coordinateInit :  CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitudeInit, longitude: longitudeInit)
    }
    
    let locationManager = CLLocationManager()
    var userPosition: CLLocation?
    //    var annotation: Spot?
    var myImage: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        setupLocationManager()
        queryData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func addSpotToMapView(annotation: Spot) {
        self.mapView.addAnnotation(annotation)
    }
    
    @IBAction func addMark(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "CreateAnnotationAddress") as! CreateSpotAddressViewController
        let nc = UINavigationController(rootViewController: vc)
        vc.delegate = self
        self.present(nc, animated: true, completion: nil)
    }
    
    @IBAction func getPosition() {
        print("getPosition")
        if userPosition != nil {
            setupMap(coordonnees: userPosition!.coordinate, myLat: 1, myLong: 1)
        } else {
            print("nil dans getPosition")
        }
    }
    
    
    @objc func longTap(sender: UIGestureRecognizer){
        if sender.state == .began {
            let locationInView = sender.location(in: mapView)
            let locationOnMap = mapView.convert(locationInView, toCoordinateFrom: mapView)
            let location = CLLocation(latitude: locationOnMap.latitude, longitude: locationOnMap.longitude)
            let vc = storyboard?.instantiateViewController(withIdentifier: "CreateAnnotation") as! CreateSpotViewController
            let nc = UINavigationController(rootViewController: vc)
            //            vc.location.append(location)
            //            vc.location = locationOnMap
            vc.delegate = self
            vc.location = location
            self.present(nc, animated: true, completion: nil)
        }
    }
    
    @IBAction func logOut() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let initial = storyboard.instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = initial
    }
    
    
    
    //    func createAnnotation() {
    //        guard let coordinate = userPosition?.coordinate else {
    //            return
    //        }
    //
    //        let annotation = Spot(title: "annotation created", subtitle: "", coordinate: coordinate, info: "")
    //        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
    //        let createVC = CreateSpotViewController()
    //        createVC.delegate = self
    //        createVC.location.append(location)
    //        print(coordinate)
    //        mapView.addAnnotation(annotation)
    //        navigationController?.pushViewController(createVC, animated: true)
    //    }
    
    //    func addAnnotation(location: CLLocationCoordinate2D){
    //        let annotation = Spot(title: "titre", subtitle: "", coordinate: location, info: "")
    //
    //        //        annotation.coordinate = location
    //        //        annotation.title = "Titre"
    //        //        annotation.subtitle = "Sous titre"
    //        //        performSegue(withIdentifier: "createSpotSegue", sender: nil)
    //        self.mapView.addAnnotation(annotation)
    //    }
    
    @objc func gotoCreateAnnotation() {
        let createSpotVC = CreateSpotViewController()
        createSpotVC.delegate = self
        
        navigationController?.pushViewController(createSpotVC, animated: false)
    }
    //
    func queryData() {
        let uid = Auth.auth().currentUser?.uid
        FirestoreReferenceManager.referenceForUserPublicData(uid: uid!).collection("Spots").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                for document in querySnapshot!.documents {
                    if let coordinate = document.get("coordinate") {
                        let point = coordinate as! GeoPoint
                        let lat = point.latitude
                        let lon = point.longitude
                        let title = document.get("title") as? String
                        print(title as Any)
                        let imageUrl = document.get("imageUrl") as? String
                        let url = URL(string: imageUrl!)
                        let resource = ImageResource(downloadURL: url!)
                        
                        KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result in
                            switch result {
                            case .success(let value):
                                let annotation = Spot(title: title!, subtitle: "", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), info: "", image: value.image)
                                print(annotation)
                                self.mapView.addAnnotation(annotation)
                                print("Image: \(value.image). Got from: \(value.cacheType)")
                            case .failure(let error):
                                print("Error: \(error)")
                            }
                        }
                        //                            self.downloadImage { (image) in
                        
                        
                        
                        //                            }
                        
                        
                        //                            let image = self.myImage?.image
                        //                            let annotation = Spot(title: (title as? String)!, subtitle: "", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), info: "", image: image!)
                        //
                        //                            self.mapView.addAnnotation(annotation)
                        //                        print(lat, lon) //here you can let coor = CLLocation(latitude: longitude:)
                    }
                }
            }
        }
    }
    
    //    func downloadImage() -> UIImage {
    //        guard let uid = Auth.auth().currentUser?.uid else {
    //            presentAlert(with: "Erreur 1")
    //            return
    //        }
    //
    //        FirestoreReferenceManager.referenceForUserPublicData(uid: uid).collection("Spots").getDocuments { (querySnapshot, error) in
    //            if let error = error {
    //                print(error.localizedDescription)
    //            } else {
    //                for document in querySnapshot!.documents {
    //                   let documentUid = document.documentID
    //                    print(documentUid)
    //                    let query = FirestoreReferenceManager.referenceForUserPublicData(uid: uid).collection("Spots").whereField(MyKeys.uid, isEqualTo: documentUid)
    //                        //            let query = Firestore.firestore().collection(MyKeys.imagesCollections).whereField(MyKeys.uid, isEqualTo: uid)
    //
    //                        query.getDocuments { (snapshot, err) in
    //                            if let err = err {
    //                                self.presentAlert(with: err.localizedDescription)
    //                                return
    //                            }
    //                            guard let snapshot = snapshot,
    //                                let data = snapshot.documents.first?.data(),
    //                                let urlString = data[MyKeys.imageUrl] as? String,
    //                                let url = URL(string: urlString) else {
    //                                    self.presentAlert(with: "Erreur 2")
    //                                    return
    //                            }
    //                            let resource = ImageResource(downloadURL: url)
    //                            print(url)
    //                            KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result in
    //                                   switch result {
    //                                   case .success(let value):
    //
    //                                       print("Image: \(value.image). Got from: \(value.cacheType)")
    //                                   case .failure(let error):
    //                                       print("Error: \(error)")
    //
    ////                            self.myImage?.kf.setImage(with: resource, completionHandler: { (result) in
    ////                                switch result {
    ////
    ////                                case .success(_):
    ////                                    completion(self.myImage!.image!)
    ////                                    self.presentAlert(with: "BIG SUCCESS")
    ////                                case .failure(_):
    ////                                    self.presentAlert(with: "BIG ERREUR")
    ////                                }
    ////
    ////                            })
    //                        }
    //                    }
    //
    //                }
    //            }
    //
    ////        func getImage() {
    ////
    ////        logoRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
    ////          if let error = error {
    ////            print("Error \(error)")
    ////          } else {
    ////            let logoImage = UIImage(data: data!)
    ////          }
    ////        }
    ////        }
    //        }
    //        }
    
    //        func downloadImage(with url : URL) -> UIImage? {
    ////            guard let url = URL.init(string: urlString) else {
    ////                return
    ////            }
    //            let resource = ImageResource(downloadURL: url)
    //
    //            KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result in
    //                switch result {
    //                case .success(let value):
    //
    //                    print("Image: \(value.image). Got from: \(value.cacheType)")
    //                case .failure(let error):
    //                    print("Error: \(error)")
    //                }
    //            }
    //        }
}


//    func downloadImage() {
//        guard let uid = UserDefaults.standard.value(forKey: MyKeys.uid) else {
//            presentAlert(with: "Il semble y avoir un problème")
//            return
//        }
//        let userUid = Auth.auth().currentUser?.uid
//        let query = FirestoreReferenceManager.referenceForUserPublicData(uid: userUid!).collection("Spots").whereField(MyKeys.uid, isEqualTo: uid)
//        query.getDocuments { (snapshot, err) in
//            if let err = err {
//                self.presentAlert(with: err.localizedDescription)
//                return
//            }
//            guard let snapshot = snapshot,
//                let data = snapshot.documents.first?.data(),
//                let urlString = data[MyKeys.imageUrl] as? String,
//                let url = URL(string: urlString) else {
//                    self.presentAlert(with: "Il semble y avoir un problème")
//                    return
//            }
//            let resource = ImageResource(downloadURL: url)
//            self.myImage?.kf.setImage(with: resource, completionHandler: { (result) in
//                switch result {
//                    
//                case .success(_):
//                   
//                    self.presentAlert(with: "BIG SUCCESS")
//                case .failure(_):
//                    self.presentAlert(with: "BIG ERREUR")
//                }
//            })
//        }
//    }




extension SpotViewController: MKMapViewDelegate {
    
    //    func addAnnotationToMapView(annotation: Spot) {
    //        self.mapView.addAnnotation(annotation)
    //    }
    
    func setup() {
        setupMap(coordonnees: coordinateInit, myLat: 3, myLong: 3)
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.isRotateEnabled = true
        let longTapGesture = UILongPressGestureRecognizer(target: self, action: #selector(longTap))
        mapView.addGestureRecognizer(longTapGesture)
        let capitalArea = MKCircle(center: coordinateInit, radius: 5000) // rayon de 5 km
        mapView.addOverlay(capitalArea)
        
    }
    
    // appellé par le bouton "localise moi"
    func setupMap(coordonnees: CLLocationCoordinate2D, myLat: Double, myLong: Double) {
        let span = MKCoordinateSpan(latitudeDelta: myLat , longitudeDelta: myLong)
        let region = MKCoordinateRegion(center: coordonnees, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "reuseID"
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        if let anno = annotation as? Spot {
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
            if annotationView == nil {
                annotationView = SpotView(controller: self, annotation: anno, reuseIdentifier: reuseIdentifier)
                
                return annotationView
            } else {
                return annotationView
            }
        }
        return nil
    }
    
    
    //    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    //        guard let annotation = annotation as? Spot else { return nil }
    //        let identifier = "spot"
    //        var view: MKMarkerAnnotationView
    //        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
    //            as? MKMarkerAnnotationView {
    //            dequeuedView.annotation = annotation
    //            view = dequeuedView
    //        } else {
    //            view = MKMarkerAnnotationView(annotation: annotation,reuseIdentifier: identifier)
    //            view.canShowCallout = true
    //            view.calloutOffset = CGPoint(x: -5, y: 5)
    //            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    //            let reviewButton = UIButton(type: .detailDisclosure)
    //            view.rightCalloutAccessoryView = reviewButton
    ////            reviewButton.addTarget(self, action: #selector(self.addReview), for: .touchUpInside)
    //
    //        }
    //        return view
    //    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let spot = view.annotation as? Spot else { return }
        let placeName = spot.title
        let placeInfo = spot.info
        
        let ac = UIAlertController(title: placeName, message: placeInfo, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    
}

extension SpotViewController: CLLocationManagerDelegate {
    
    func setupLocationManager() {
        locationManager.delegate = self
        locationManager.startUpdatingHeading()
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if locations.count > 0 {
            if let maPosition = locations.last {
                userPosition = maPosition
            }
        }
    }
    
}
