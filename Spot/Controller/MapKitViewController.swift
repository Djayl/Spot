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

@available(iOS 13.0, *)
class MapKitViewController: UIViewController {

    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: "AnnotationIdentifier")
        fetchPublicSpots()
    }
    
    private func displayAllOffices(_ marker: Marker) {
        let latitude = marker.coordinate.latitude
        let longitude = marker.coordinate.longitude
        let identifier = marker.identifier
        let imageURL = marker.imageURL
        let name = marker.name
        let summary = marker.description
        let creationDate = marker.creationDate
        let creatorName = marker.creatorName
        let imageId = marker.imageID
        let publicSpot = marker.publicSpot
        let ownerId = marker.ownerId
        let annotation = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
        annotation.creationDate = creationDate
        annotation.creatorName = creatorName
        annotation.imageID = imageId
        annotation.ownerId = ownerId
        annotation.publicSpot = publicSpot
       
        annotation.uid = identifier
        annotation.imageURL = imageURL
        annotation.subtitle = summary
        annotation.title = name
        mapView.addAnnotation(annotation)
    }
    
    func fetchPublicSpots() {
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
    
    @objc private func didTapSpot(annotation: CustomAnnotation) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "SpotDetailsVC") as! SpotDetailsViewController
        secondViewController.annotation = annotation
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
}

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
                annotationView.canShowCallout = true
                annotationView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
                annotationView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
                
                let customView = annotationView.subviews.first as! MyAnnotationView
                let url = URL(string: annotation.imageURL!)
                customView.imageView.kf.setImage(with: url)
                customView.imageView.clipsToBounds = true
                customView.layer.cornerRadius = 5
                customView.backgroundColor = .white
                customView.frame = annotationView.frame
                customView.clipsToBounds = true
                customView.layer.borderColor = Colors.blueBalloon.cgColor
                customView.layer.borderWidth = 2
               
                
            }
        }
        return annotationView
    }
}
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation as? CustomAnnotation else { return }
        didTapSpot(annotation: annotation)
//        guard let identifier = annotation.uid else {return}
//        guard let name = annotation.title else {return}
//        guard let description = annotation.subtitle else {return}
//        guard let imageURL = annotation.imageURL else {return}
//        guard let ownerId = annotation.ownerId else {return}
//        guard let publicSpot = annotation.publicSpot else {return}
//        guard let creatorName = annotation.creatorName else {return}
//        guard let creationDate = annotation.creationDate else {return}
//        guard let imageID = annotation.imageID else {return}
//
//        let latitude = Double(annotation.coordinate.latitude)
//        let longitude = Double(annotation.coordinate.longitude)
//
//
//        let marker = Marker(identifier: identifier, name: name, description: description, coordinate: GeoPoint(latitude: latitude, longitude: longitude), imageURL: imageURL, ownerId: ownerId, publicSpot: publicSpot, creatorName: creatorName, creationDate: creationDate, imageID: imageID)
//
//        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "SpotDetailsVC") as! SpotDetailsViewController
//        secondViewController.annotation = marker
//        print("did tap disclosure")
//        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
}
