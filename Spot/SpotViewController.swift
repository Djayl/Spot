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

protocol AddSpotDelegate: class {
    func addSpotToMapView(annotation: Spot)
}

class SpotViewController: UIViewController, AddSpotDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var localizationButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    var latitudeInit: Double = 48.853506
    var longitudeInit: Double = 2.348784
    var coordinateInit :  CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitudeInit, longitude: longitudeInit)
    }
    
    let locationManager = CLLocationManager()
    var userPosition: CLLocation?
//    var annotation: Spot?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        localizationButton.layer.cornerRadius = 10
        setup()
        setupLocationManager()
        
        
    }
    
    func addSpotToMapView(annotation: Spot) {
        self.mapView.addAnnotation(annotation)
    }
    
    @IBAction func addMark(_ sender: Any) {
//        createAnnotation()
//        performSegue(withIdentifier: "createSegue", sender: nil)
    }
    
    @IBAction func getPosition(_ sender: Any) {
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
    

    

}

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
        guard let annotation = annotation as? Spot else { return nil }
        let identifier = "spot"
        var view: MKMarkerAnnotationView
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)
            as? MKMarkerAnnotationView {
            dequeuedView.annotation = annotation
            view = dequeuedView
        } else {
            view = MKMarkerAnnotationView(annotation: annotation,reuseIdentifier: identifier)
            view.canShowCallout = true
            view.calloutOffset = CGPoint(x: -5, y: 5)
            view.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            let reviewButton = UIButton(type: .detailDisclosure)
            view.rightCalloutAccessoryView = reviewButton
//            reviewButton.addTarget(self, action: #selector(self.addReview), for: .touchUpInside)
            
        }
        return view
    }
    
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
