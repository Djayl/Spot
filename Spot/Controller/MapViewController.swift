//
//  MapViewController.swift
//  Spot
//
//  Created by MacBook DS on 21/10/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Firebase
import Kingfisher

protocol AddSpotDelegate: class {
    func addSpotToMapView(marker: Spot)
}

@available(iOS 13.0, *)
class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    var sourceView: UIView?
        
        var resultsViewController: GMSAutocompleteResultsViewController?
        var searchController: UISearchController?
        var userPosition: CLLocation?
        private let locationManager = CLLocationManager()
        
        let customMarkerWidth: Int = 50
        let customMarkerHeight: Int = 70
        var spots = [Spot]()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            mapView.delegate = self
//            mapView.addSubview(maptypeButton)
//            setupSearchBar()
            
            resultsViewController?.delegate = self
            getData()
            
        }
    
        override func viewWillDisappear(_ animated: Bool) {
            self.navigationController?.isNavigationBarHidden = false
        }
        
        @IBAction func mapType(_ sender: Any) {
            chooseMapType(controller: MapViewController())
        }
        
        
        func chooseMapType(controller: UIViewController) {
            let alert = UIAlertController(title: "Modifier le type de carte", message: "Sélectionnez une option", preferredStyle: .actionSheet)
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
        
        
        @objc func gotoCreateAnnotation() {
            let createSpotVC = CreateSpotViewController()
            createSpotVC.delegate = self
            navigationController?.pushViewController(createSpotVC, animated: false)
        }

        
//        func setupSearchBar() {
//                resultsViewController = GMSAutocompleteResultsViewController()
//                searchController = UISearchController(searchResultsController: resultsViewController)
//                searchController?.searchResultsUpdater = resultsViewController
//            
//            var searchBar = UISearchBar(frame: CGRect(x: 0, y: 20, width: UIScreen.main.bounds.width, height: 44))
//            searchBar = searchController!.searchBar
//                  searchBar.searchBarStyle = .default
//                  view.addSubview(searchBar)
//
//                  searchBar.placeholder = "Ajouter un Spot avec une addresse"
//                  searchBar.set(textColor: .brown)
//            searchBar.setTextField(color: UIColor.systemIndigo.withAlphaComponent(0.3))
//                  searchBar.setPlaceholder(textColor: .white)
//                  searchBar.setSearchImage(color: .blue)
//                  searchBar.setClearButton(color: .red)
//                navigationItem.titleView = searchController?.searchBar
//                definesPresentationContext = true
//                searchController?.hidesNavigationBarDuringPresentation = false
//            
//              }
        
        
        func getData() {
            guard let uid = Auth.auth().currentUser?.uid else {return}
            FirestoreReferenceManager.referenceForUserPublicData(uid: uid).collection("Spots").getDocuments { (querySnapshot, error) in
                if let error = error {
                    print("Error getting documents: \(error)")
                } else {
                    for document in querySnapshot!.documents {
                        
                        let coordinate = document.get("coordinate")
                        let point = coordinate as! GeoPoint
                        let lat = point.latitude
                        let lon = point.longitude
                        let title = document.get("title") as? String
                        let imageUrl = document.get("imageUrl")
                        let imageUrl2 = imageUrl
                        guard let url = URL.init(string: imageUrl2 as! String) else {return}
                        KingfisherManager.shared.retrieveImage(with: url, options: nil) { result in
                            
                            let image = try? result.get().image
                            
                            if let image = image {
                                DispatchQueue.main.async {
                                    let marker = Spot()
                                    marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                    marker.title = title
                                    marker.imageURL = imageUrl2 as? String
                                    let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: self.customMarkerWidth, height: self.customMarkerHeight), image: image, borderColor: UIColor.systemIndigo.withAlphaComponent(0.8))
                                    marker.iconView = customMarker
                                    marker.map = self.mapView
                                    self.spots.append(marker)
                                    
                                }
                                
                            }
                            
                        }
                    }
                }
            }
        }
//@objc func nextTapped(spot: Spot) {
//        // the name for UIStoryboard is the file name of the storyboard without the .storyboard extension
//        let displayVC : DetailsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailsVC") as! DetailsViewController
//        displayVC.spot = spot
//
//        self.present(displayVC, animated: true, completion: nil)
//    }

        @objc func didTapSpot(spot: Spot) {
            let vc = storyboard?.instantiateViewController(withIdentifier: "DetailsVC") as! DetailsViewController
            let nc = UINavigationController(rootViewController: vc)

            vc.spot = spot
            self.present(nc, animated: true, completion: nil)

        }
        
    }
    // MARK: - CLLocationManagerDelegate
    //1
@available(iOS 13.0, *)
extension MapViewController: GMSAutocompleteResultsViewControllerDelegate {
        func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didAutocompleteWith place: GMSPlace) {
            // 1
            let markerPosition = place.coordinate
            let camera = GMSCameraPosition.camera(withTarget: markerPosition, zoom: 20)
            //        let mapView = GMSMapView.map(withFrame: .zero, camera: camera)
            mapView.animate(to: camera)
            searchController?.isActive = false
            let vc = storyboard?.instantiateViewController(withIdentifier: "CreationVC") as! CreateSpotViewController
            let nc = UINavigationController(rootViewController: vc)
            let location = place.coordinate
            vc.location = location
            vc.delegate = self
            self.present(nc, animated: true, completion: nil)
            //        let marker = GMSMarker()
            //        marker.position = place.coordinate
            //        marker.title = place.name
            //        marker.snippet = place.formattedAddress
            //        marker.map = mapView
            
        }
        
        func resultsController(_ resultsController: GMSAutocompleteResultsViewController, didFailAutocompleteWithError error: Error) {
            print("Error: \(error.localizedDescription)")
        }
    }

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

        //      func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        //
        //                let vc = storyboard?.instantiateViewController(withIdentifier: "CreationVC") as! CreationSpotViewController
        //                let nc = UINavigationController(rootViewController: vc)
        //
        //        vc.spot = marker as? Spot
        //        vc.delegate = self
        //
        //                self.present(nc, animated: true, completion: nil)
        //        return false
        //      }
        
        func mapView(_ mapView: GMSMapView, didLongPressInfoWindowOf marker: GMSMarker) {
            
        }
        
        
        func addSpotToMapView(marker: Spot) {
            
            marker.map = mapView
            
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
            print(marker.title as Any)
            didTapSpot(spot: spot)
//            nextTapped(spot: spot)
          
        }
    }

    //extension MapViewController: UIPopoverPresentationControllerDelegate{
    //  func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
    //    return .none
    //  }
    //  func popoverPresentationControllerShouldDismissPopover(_ popoverPresentationController: UIPopoverPresentationController) -> Bool {
    //    sourceView?.removeFromSuperview()
    //    sourceView = nil
    //    return true
    //  }
    //
    //}

    //extension MapViewController: CreationSpotViewControllerDelegate{
    //    func addSpotToMapView(marker: Spot) {
    //         marker.map = self.mapView
    //    }
    //}
    //extension MapViewController: CreationDelegate {
    //    func update(_ spot: Spot) {
    //        self.update(spot)
    //    }
    //}


 

