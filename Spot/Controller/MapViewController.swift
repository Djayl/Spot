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
   
    @IBOutlet weak var chooseDataButton: CustomButton!
    
    
    var sourceView: UIView?
    
    var spots = [Spot]()
    
        var resultsViewController: GMSAutocompleteResultsViewController?
        var searchController: UISearchController?
        var userPosition: CLLocation?
        private let locationManager = CLLocationManager()
        
        let customMarkerWidth: Int = 50
        let customMarkerHeight: Int = 70
        
        
        override func viewDidLoad() {
            super.viewDidLoad()
//            navigationController?.hideNavigationItemBackground()
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            mapView.delegate = self
            setUpNavigationController()
            setUpTapBarController()

            mapView.addSubview(chooseDataButton)
            mapView.reloadInputViews()

//            mapView.addSubview(maptypeButton)
//            setupSearchBar()
          
//            resultsViewController?.delegate = self
//            getData()
               checkIfUserLoggedIn()
            
        }
    
    fileprivate func setUpNavigationController() {
//        navigationController?.hideNavigationItemBackground()
        navigationController?.navigationBar.barTintColor = Colors.skyBlue
        navigationController?.navigationBar.tintColor = Colors.coolRed
        navigationItem.rightBarButtonItem?.setTitleTextAttributes([.font : UIFont(name: "IndigoRegular-Regular", size: 15)!, .foregroundColor : Colors.coolRed], for: .normal)
    }
    
    fileprivate func setUpTapBarController() {
        tabBarController?.tabBar.tintColor = UIColor.yellow
        tabBarController?.tabBar.unselectedItemTintColor = UIColor.green
        tabBarController?.tabBar.barTintColor = Colors.skyBlue
        
    }
//       override func viewWillDisappear(_ animated: Bool) {
//            super.viewWillDisappear(true)
//        // Show the Navigation Bar
//                self.navigationController?.setNavigationBarHidden(false, animated: false)
//       
//            }
    
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
        
        @IBAction func mapType(_ sender: Any) {
            chooseMapType(controller: MapViewController())
        }
    
    @IBAction func dataType(_ sender: Any) {
        chooseData(controller: MapViewController())
    }
    

        
    func chooseData(controller: UIViewController) {
        let alert = UIAlertController(title: "Choisissez ce que vous voulez voir", message: "Sélectionnez une option", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Juste mes Spots", style: .default, handler: { (_) in
            self.mapView.clear()
            self.getData()
        }))
        alert.addAction(UIAlertAction(title: "Juste mes favoris", style: .default, handler: { (_) in
            self.mapView.clear()
            self.getFavoriteSpots()
        }))
        alert.addAction(UIAlertAction(title: "Tous les Spots", style: .default, handler: { (_) in
            self.mapView.clear()
            self.getMySpots()
        }))
        alert.addAction(UIAlertAction(title: "Annuler", style: .cancel, handler: { (_) in
            print("User click Dismiss button")
        }))
        self.present(alert, animated: true, completion: {
        })
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
                        let description = document.get("description") as? String
                        let creationDate = document.get("createdAt") as? Timestamp
                        let uid = document.get("uid") as? String
                        let favorite = document.get("isFavorite") as? String
                        guard let spotFavorite = favorite else {return}
                        guard let date = creationDate?.dateValue() else {return}
                        guard let spotUid = uid else {return}
                        let mCustomData = CustomData(creationDate: date, uid: spotUid, isFavorite: spotFavorite)
                        let imageUrl = document.get("imageUrl")
                        let imageUrl2 = imageUrl
                        guard let url = URL.init(string: imageUrl2 as! String) else {return}
                        KingfisherManager.shared.retrieveImage(with: url, options: nil) { result in
                            
                            let image = try? result.get().image
                            
                            if let image = image {
                                DispatchQueue.main.async {
                                    let marker = Spot()
                                    marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                    marker.title = title?.capitalized
                                    marker.snippet = description
                                    
                                    marker.userData = mCustomData
                                    marker.imageURL = imageUrl2 as? String
                                    let customMarker = CustomMarkerView(frame: CGRect(x: 0, y: 0, width: self.customMarkerWidth, height: self.customMarkerHeight), image: image, borderColor: Colors.skyBlue.withAlphaComponent(0.8))
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
    
    func getFavoriteSpots() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        FirestoreReferenceManager.referenceForUserPublicData(uid: uid).collection("Spots").whereField("isFavorite", isEqualTo: "Yes").getDocuments { (querySnapshot, error) in
                 if let error = error {
                     print("Error getting documents: \(error)")
                 } else {
                     for document in querySnapshot!.documents {
                         
                         let coordinate = document.get("coordinate")
                         let point = coordinate as! GeoPoint
                         let lat = point.latitude
                         let lon = point.longitude
                         let title = document.get("title") as? String
                         let description = document.get("description") as? String
                         let creationDate = document.get("createdAt") as? Timestamp
                         let uid = document.get("uid") as? String
                        let favorite = document.get("isFavorite") as? String
                        guard let spotFavorite = favorite else {return}
                        guard let spotUid = uid else {return}
                         guard let date = creationDate?.dateValue() else {return}
                        let mCustomData = CustomData(creationDate: date, uid: spotUid, isFavorite: spotFavorite)
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
                                     marker.snippet = description
                                     marker.userData = mCustomData
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
    
    func getMySpots() {
        
        FirestoreReferenceManager.root.collection("publicSpot").getDocuments { (querySnapshot, error) in
                 if let error = error {
                     print("Error getting documents: \(error)")
                 } else {
                     for document in querySnapshot!.documents {
                         
                         let coordinate = document.get("coordinate")
                         let point = coordinate as! GeoPoint
                         let lat = point.latitude
                         let lon = point.longitude
                         let title = document.get("title") as? String
                         let description = document.get("description") as? String
                         let creationDate = document.get("createdAt") as? Timestamp
                         let uid = document.get("uid") as? String
                        let favorite = document.get("isFavorite") as? String
                        guard let spotFavorite = favorite else {return}
                        guard let spotUid = uid else {return}
                         guard let date = creationDate?.dateValue() else {return}
                        let mCustomData = CustomData(creationDate: date, uid: spotUid, isFavorite: spotFavorite)
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
                                     marker.snippet = description
                                     marker.userData = mCustomData
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
    

    
  func getReadableDate(timeStamp: TimeInterval) -> String? {
      let date = Date(timeIntervalSince1970: timeStamp)
      let dateFormatter = DateFormatter()
      
      if Calendar.current.isDateInTomorrow(date) {
          return "Tomorrow"
      } else if Calendar.current.isDateInYesterday(date) {
          return "Yesterday"
      } else if dateFallsInCurrentWeek(date: date) {
          if Calendar.current.isDateInToday(date) {
              dateFormatter.dateFormat = "h:mm a"
              return dateFormatter.string(from: date)
          } else {
              dateFormatter.dateFormat = "EEEE"
              return dateFormatter.string(from: date)
          }
      } else {
          dateFormatter.dateFormat = "MMM d, yyyy"
          return dateFormatter.string(from: date)
      }
  }

  func dateFallsInCurrentWeek(date: Date) -> Bool {
      let currentWeek = Calendar.current.component(Calendar.Component.weekOfYear, from: Date())
      let datesWeek = Calendar.current.component(Calendar.Component.weekOfYear, from: date)
      return (currentWeek == datesWeek)
  }


        @objc func didTapSpot(spot: Spot) {
            let vc = storyboard?.instantiateViewController(withIdentifier: "DetailsVC") as! DetailsViewController
            let nc = UINavigationController(rootViewController: vc)

            vc.spot = spot
            
            self.present(nc, animated: true, completion: nil)

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
    
    @IBAction func reloadMap(_ sender: Any) {
        
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
           
            
            didTapSpot(spot: spot)
//            performSegue(withIdentifier: "detailsSegue", sender: self)
//            print(spot!.name as Any)
//            didTapSpot(spot: spot)
//            nextTapped(spot: spot)
            }
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let update = GMSCameraUpdate.zoomIn()
        mapView.animate(with: update)
        return false
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

 

