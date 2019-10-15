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
    var myImage: UIImage?
    var spots = [Spot]()
    var spotView = SpotView()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        setupLocationManager()
        queryData()
//        DispatchQueue.main.async {
//            self.queryData { (spots) in
//            print(spots)
//            self.mapView.addAnnotations(spots)
//        }
//        }
//        mapView.reloadInputViews()
 
    }
    
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        DispatchQueue.main.async {
//            self.queryData { (spots) in
//                   print(spots)
//                    for spot in spots {
//                    self.mapView.removeAnnotation(spot)
//                   self.mapView.addAnnotation(spot)
//                    }
//               }
//        }
//    }
    
    private func downloadImage(at url: URL, completion: @escaping (UIImage?) -> Void) {
        
        let ref = Storage.storage().reference(forURL: url.absoluteString)
       
      let megaByte = Int64(1 * 1024 * 1024)
      
      ref.getData(maxSize: megaByte) { data, error in
        
        guard let imageData = data else {
          completion(nil)
          return
        }
        
        completion(UIImage(data: imageData))
      }
    
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    // APPELER LA METHODE DOWNLOADIMAGE DANS SPOTVIEW
    
//
    func queryData() {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        FirestoreReferenceManager.referenceForUserPublicData(uid: uid).collection("Spots").getDocuments { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                
                for document in querySnapshot!.documents {
                 
               
                    if  let coordinate = document.get("coordinate") {
                        let point = coordinate as! GeoPoint
                        let lat = point.latitude
                        let lon = point.longitude
                        let title = document.get("title") as? String
                        print(title as Any)
                        let imageUrl = document.get("imageUrl")
                        let imageUrl2 = imageUrl
//                        guard let url = URL.init(string: imageUrl2 as! String) else {
//                            return
//                        }
                        
                    if let url = URL(string: imageUrl2 as! String) {
                        
                        
//                        let url = URL(string: imageUrl2)
//                        let resource = ImageResource(downloadURL: url)
                     
                    
//                    KingfisherManager.shared.retrieveImage(with: url, options: [.cacheMemoryOnly]) { result in
//
//                        let image = try? result.get().image
//
//                        if let image = image {
//                            DispatchQueue.main.async {
                             
                    self.downloadImage(at: url) { [weak self] image in
                                   guard let self = self else {
                                    print(url)
                                     return
                                   }
                        
                                   guard let image = image else {
                                     return
                                   }
                        
                                     let annotation = Spot(title: title!, subtitle: "", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), info: "", image: image)
                                   self.mapView.addAnnotation(annotation)
                                 }
                        
 
                    }
//                                }
                            
//                            }
                            
                        }
            }
                }
            }
    }
}
    

        

    
//    func getImage() {
//        let imageView = UIImageView()
//        getImageUrl { (url) in
//
//        imageView.pin_setImage(from: url)  { result in
//
//            guard let image = result.image else { return}
//            print(url)
//            print(image)
//
//            }
//        }
//    }
    
//    func loadAnnotations() {
//        for item in spots {
//            DispatchQueue.main.async {
//                
//                let request = NSMutableURLRequest(url: URL(string: item.imageUrl)!)
//                request.httpMethod = "GET"
//                let session = URLSession(configuration: URLSessionConfiguration.default)
//                let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
//                    if error == nil {
//                        let annotation = Spot(title: item.title!, subtitle: "", coordinate: CLLocationCoordinate2D(latitude: item.coordinate.latitude, longitude: item.coordinate.longitude), info: "", image: UIImage(data: data!)!, imageUrl: "")
//                        print(annotation.coordinate.latitude)
//                        print(annotation.coordinate.longitude)
//                        DispatchQueue.main.async {
//                            self.mapView.addAnnotation(annotation)
//                        }
//                    }
//                    
//                }
//                dataTask.resume()
//            }
//        }
//        
//    }
    
//    func getImageUrl(completion: @escaping (_ url: URL?)->()) {
//        guard let uid = Auth.auth().currentUser?.uid else {return}
//        let query = FirestoreReferenceManager.referenceForUserPublicData(uid: uid).collection("Spots")
//            
//        query.getDocuments { (snapshot, err) in
//            if let err = err {
//                self.presentAlert(with: err.localizedDescription)
//                return
//            }
//            
//            for document in snapshot!.documents {
//                
//                let urlString = document.get("imageUrl") as? String
//                
//                let url = URL(string: urlString!)
//              completion(url)
//    }
//        }
//        
//    }

//        func queryData2() {
//            guard let uid = Auth.auth().currentUser?.uid else {return}
//            let query = FirestoreReferenceManager.referenceForUserPublicData(uid: uid).collection("Spots")
//
//            query.getDocuments { (snapshot, err) in
//                if let err = err {
//                    self.presentAlert(with: err.localizedDescription)
//                    return
//                }
//
//                for document in snapshot!.documents {
//
//                    let urlString = document.get("imageUrl") as? String
//
//                    let point = document.get("coordinate") as! GeoPoint
//
//                    let url = URL(string: urlString!)
//
//                let lat = point.latitude
//                let long = point.longitude
//                let title = document.get("title") as? String
//                    let annotation = Spot(title: title!, subtitle: "", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long), info: "", image: urlString!)
////                let resource = ImageResource(downloadURL: url!)
////                    ImageService.getImage(withURL: url!) { (image) in
////                        let annotation = Spot(title: title!, subtitle: "", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long), info: "", image: image!)
//                    self.mapView.addAnnotation(annotation)
////                    }
////                KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil) { result in
////                    switch result {
////                    case .success(let value):
////
////                        let annotation = Spot(title: title!, subtitle: "", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long), info: "", image: value.image)
////
////                        print(annotation)
////                        self.mapView.addAnnotation(annotation)
////
////
////                        print("Image: \(value.image). Got from: \(value.cacheType)")
////                    case .failure(let error):
////                        print("Error: \(error)")
////                    }
////                }
//                }
//            }
//        }
//    }
    
//    func loadAnnotations() {
//
//        let uid = Auth.auth().currentUser?.uid
//        FirestoreReferenceManager.referenceForUserPublicData(uid: uid!).collection("Spots").getDocuments { (querySnapshot, err) in
//            if let err = err {
//                print("Error getting documents: \(err)")
//            } else {
//                for document in querySnapshot!.documents {
//                    DispatchQueue.main.async {
//
//                    if let coordinate = document.get("coordinate") {
//                        let point = coordinate as! GeoPoint
//                        let lat = point.latitude
//                        let lon = point.longitude
//                        let title = document.get("title") as? String
//                        print(title as Any)
//                        let imageUrl = document.get("imageUrl") as? String
//
//            DispatchQueue.main.async {
//
//                let request = NSMutableURLRequest(url: URL(string: imageUrl!)!)
//                request.httpMethod = "GET"
//                let session = URLSession(configuration: URLSessionConfiguration.default)
//                let dataTask = session.dataTask(with: request as URLRequest) { (data, response, error) in
//                    if error == nil {
//
//                        let annotation = Spot(title: title!, subtitle: "", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon), info: "", image: UIImage(data: data!)!)
//                        DispatchQueue.main.async {
//                            self.mapView.addAnnotation(annotation)
//                        }
//                    }
//                }
//
//                dataTask.resume()
//            }
//                        }
//    }
//                    }
//}
//
//        }
//    }

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
    
//    func mapViewDidChangeVisibleRegion(_ mapView: MKMapView) {
//            queryData { (spots) in
//
//                        for spot in spots {
////                        self.mapView.removeAnnotation(spot)
//                            self.mapView.addAnnotation(spot)
//                        }
//                   }
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
//
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
//        // Don't want to show a custom image if the annotation is the user's location.
//        guard !(annotation is MKUserLocation) else {
//            return nil
//        }
//
//        // Better to make this class property
//        let annotationIdentifier = "AnnotationIdentifier"
//
//        var annotationView: MKAnnotationView?
//        if let dequeuedAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: annotationIdentifier) {
//            annotationView = dequeuedAnnotationView
//            annotationView?.annotation = annotation
//        }
//        else {
//            let av = MKAnnotationView(annotation: annotation, reuseIdentifier: annotationIdentifier)
//            av.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//            annotationView = av
//        }
//
//        if let annotationView = annotationView {
//            // Configure your annotation view here
//            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35, height: 42))
//            imageView.image = myImage
//            annotationView.addSubview(imageView)
//            annotationView.canShowCallout = true
//
//        }
//
//        return annotationView
//    }
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard let annotation = annotation as? Spot else {
//            return nil
//        }
//
//        let reuseId = "Pin"
//        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId)
//        if pinView == nil {
//            pinView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
//            pinView?.canShowCallout = true
//            getImageUrl { (url) in
//                print(url as Any)
//            let data = NSData(contentsOf: url!)
//            pinView?.image = UIImage(data: data! as Data)
//            }
//        }
//        else {
//            pinView?.annotation = annotation
//        }
//
//        return pinView
//    }
    
//        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//            guard let annotation = annotation as? Spot else { return nil }
//            let identifier = "spot"
//            var view: MKMarkerAnnotationView
//            if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
//                as? MKMarkerAnnotationView {
//                dequeuedView.annotation = annotation
//                view = dequeuedView
//            } else {
//                view = MKMarkerAnnotationView(annotation: annotation,reuseIdentifier: identifier)
//                view.canShowCallout = true
//                view.calloutOffset = CGPoint(x: -5, y: 5)
//                view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//                let reviewButton = UIButton(type: .detailDisclosure)
//                view.rightCalloutAccessoryView = reviewButton
//                getImageUrl { (url) in
//                    let data = NSData(contentsOf: url!)
//                    view.image = UIImage(data: data! as Data)!
//                }
//    //            reviewButton.addTarget(self, action: #selector(self.addReview), for: .touchUpInside)
//
//            }
//            return view
//        }
    
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
