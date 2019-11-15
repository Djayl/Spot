//
//  FavoriteViewController.swift
//  Spot
//
//  Created by MacBook DS on 01/11/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit
import Firebase
import GoogleMaps
import Kingfisher


@available(iOS 13.0, *)
class FavoriteViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var markers = [Spot]()
    let map = MapViewController()

    override func viewDidLoad() {
        super.viewDidLoad()
//        markers.removeDuplicates()
//        fetchSpots()
        
        tableView.reloadData()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        markers.removeAll()
//        markers.removeDuplicates()
        markers.removeAll()
        fetchSpots()
        fetchSpotsFromPublic()
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
      for markers in markers {
             listener(spot: markers)
             }
    }

    
    func deleteSpotFromFavorites(spot: Spot) {
        let uid = Auth.auth().currentUser?.uid
        guard let spotUid = (spot.userData as! CustomData).uid else {return}
        let ref = FirestoreReferenceManager.referenceForUserPublicData(uid: uid!).collection("Spots").document(spotUid)
        
        ref.updateData(["isFavorite": "No"]) { (error) in
            if let error = error {
                print(error.localizedDescription)
            }
            self.tableView.reloadData()
            print("Succesfully UnFavorite")
        }
    }
    
    private func fetchSpots() {
        
        let firestoreService = FirestoreService<Marker>()
        firestoreService.fetchCollection(endpoint: .spot) { [weak self] result in
            switch result {
            case .success(let firestorePrograms):
                for markers in firestorePrograms {
                    if markers.isFavorite == true {
                    let name = markers.name
                    guard let url = URL.init(string: markers.imageURL ) else {return}
                        let mCustomData = CustomData(creationDate: markers.creationDate, uid: markers.identifier, isFavorite: markers.isFavorite, publicSpot: markers.publicSpot)
                    KingfisherManager.shared.retrieveImage(with: url, options: nil) { result in
                        let image = try? result.get().image
                        if let image = image {
                            DispatchQueue.main.async {
                                let marker = Spot()
                                marker.position = CLLocationCoordinate2D(latitude: markers.coordinate.latitude, longitude: markers.coordinate.longitude)
                                marker.name = name
                                marker.title = name
                                marker.snippet = markers.description
                                marker.userData = mCustomData
                                marker.imageURL = markers.imageURL
                                marker.image = image
                            
                                self?.markers.append(marker)
                            
                                print(self?.markers.count as Any)
                               
                                   
                                    self?.tableView.reloadData()
                               
//                                self?.tableView.reloadData()
                            }
                        }
                    }
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
                self?.presentAlert(with: "Erreur serveur")
            }
        }
    }
    
    private func checkFavorite(spot: Spot) {
        let vc = DetailsViewController()
        if spot == vc.spot {
            (vc.spot.userData as! CustomData).isFavorite = false
        }
    }
    
      private func fetchSpotsFromPublic() {
          
          let firestoreService = FirestoreService<Marker>()
          firestoreService.fetchCollection(endpoint: .publicCollection) { [weak self] result in
              switch result {
              case .success(let firestorePrograms):
                  for markers in firestorePrograms {
                      if markers.isFavorite == true {
                      let name = markers.name
                      guard let url = URL.init(string: markers.imageURL ) else {return}
                          let mCustomData = CustomData(creationDate: markers.creationDate, uid: markers.identifier, isFavorite: markers.isFavorite, publicSpot: markers.publicSpot)
                      KingfisherManager.shared.retrieveImage(with: url, options: nil) { result in
                          let image = try? result.get().image
                          if let image = image {
                              DispatchQueue.main.async {
                                  let marker = Spot()
                                  marker.position = CLLocationCoordinate2D(latitude: markers.coordinate.latitude, longitude: markers.coordinate.longitude)
                                  marker.name = name
                                  marker.title = name
                                  marker.snippet = markers.description
                                  marker.userData = mCustomData
                                  marker.imageURL = markers.imageURL
                                  marker.image = image
                              
                                  self?.markers.append(marker)
                              
                                  print(self?.markers.count as Any)
                                 
                                     
                                      self?.tableView.reloadData()
                                 
  //                                self?.tableView.reloadData()
                              }
                          }
                      }
                      }
                  }
              case .failure(let error):
                  print(error.localizedDescription)
                  self?.presentAlert(with: "Erreur serveur")
              }
          }
      }
    
//    func loadData() {
//        guard let uid = Auth.auth().currentUser?.uid else {return}
//        FirestoreReferenceManager.referenceForUserPublicData(uid: uid).collection("Spots").whereField("isFavorite", isEqualTo: "Yes").getDocuments { (querySnapshot, error) in
//            if let error = error {
//                print("Error getting documents: \(error)")
//            } else {
//                for document in querySnapshot!.documents {
//                    if let title = document.data()["title"] as? String,
//                        let imageUrl = document.data()["imageUrl"] as? String,
//                        let coordinate = document.data()["coordinate"] as? GeoPoint,
//                        let description = document.data()["description"] as? String,
//                        let creationDate = document.data()["createdAt"] as? Timestamp,
//                        let uid = document.data()["uid"] as? String,
//                        let favorite = document.data()["isFavorite"] as? String
//                    {
//                        let position = coordinate
//                        let lat = position.latitude
//                        let lon = position.longitude
//                        let spotFavorite = favorite
//                        let date = creationDate.dateValue()
//                        let spotUid = uid
//                        let mCustomData = CustomData(creationDate: date, uid: spotUid, isFavorite: spotFavorite)
//                        print(title as Any)
//                        guard let url = URL.init(string: imageUrl) else {return}
//                        KingfisherManager.shared.retrieveImage(with: url, options: nil) { result in
//                            let image = try? result.get().image
//                            if let image = image {
//                                DispatchQueue.main.async {
//                                    let spot = Spot()
//                                    spot.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
//                                    spot.snippet = description
//                                    spot.userData = mCustomData
//                                    spot.name = title
//                                    spot.title = title
//                                    spot.image = image
//                                    spot.imageURL = imageUrl
//                                    self.markers.append(spot)
//                                    print(self.markers.count)
//                                    self.tableView.reloadData()
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
//    private func updateFavorite(_ marker: Marker, spot: Spot){
//            (spot.userData as! CustomData).isFavorite = marker.isFavorite
//           }
        
    private func listener(spot: Spot) {
            guard let spotUid = (spot.userData as! CustomData).uid else {return}
            let firestoreService = FirestoreService<Marker>()
            firestoreService.listenDocument(endpoint: .favorite(spotId: spotUid)) { [weak self] result in
                switch result {
                            case .success(let marker):
                                (spot.userData as! CustomData).isFavorite = marker.isFavorite
                //                (self?.spot.userData as! CustomData).isFavorite = true
    //                            print(successMessage)
                            case .failure(let error):
                                print("Error updating document: \(error)")
                                self?.presentAlert(with: "Erreur réseau")
                            }
            }
        }
   
    private func removeSpotFromFavorite(spot: Spot) {
        
        guard let spotUid = (spot.userData as! CustomData).uid else {return}
        
        let firestoreService = FirestoreService<Marker>()
        let data = ["isFavorite": false]
        if (spot.userData as! CustomData).publicSpot == false {
            //                DispatchQueue.main.async {
            
            
            firestoreService.updateData(endpoint: .favorite(spotId: spotUid), data: data) { [weak self] result in
                switch result {
                case .success(let successMessage):
                    
                    (spot.userData as! CustomData).isFavorite = false
                    
                    print(successMessage)
                case .failure(let error):
                    print("Error updating document: \(error)")
                    self?.presentAlert(with: "Erreur réseau")
                }
            }
            //            }
        } else {
            
            firestoreService.updateData(endpoint: .publicSpot(spotId: spotUid), data: data) { [weak self] result in
                switch result {
                case .success(let successMessage):
                    
                    (spot.userData as! CustomData).isFavorite = false
                    
                    print(successMessage)
                case .failure(let error):
                    print("Error updating document: \(error)")
                    self?.presentAlert(with: "Erreur réseau")
                }
            }
        }
    }
    
    @objc func didTapSpot(spot: Spot) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailsVC") as! DetailsViewController
        let nc = UINavigationController(rootViewController: vc)
        vc.spot = spot
        self.present(nc, animated: true, completion: nil)
    }
    
}
@available(iOS 13.0, *)
extension FavoriteViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection    section: Int) -> Int {
        print(markers.count)
        return markers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCellIdentifier") as? CustomCell {
            cell.configureCell(spot: markers[indexPath.row])
            cell.contentView.layer.cornerRadius = 10
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeSpotFromFavorite(spot: markers[indexPath.row])
            print("row deleted")
            checkFavorite(spot: markers[indexPath.row])
            listener(spot: markers[indexPath.row])
            print((markers[indexPath.row].userData as! CustomData).isFavorite as Any)
            markers.remove(at: indexPath.row)
            
           
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            print("SUCCESSFULLY DELETED FROM FAVORITE TV")
//            tableView.reloadData()
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Ajoutez ici vos favoris"
        label.font = UIFont(name: "IndigoRegular-Regular", size: 20)
        label.textAlignment = .center
        label.textColor = .darkGray
        return label
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return markers.isEmpty ? 200 : 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        didTapSpot(spot: markers[indexPath.row])
        listener(spot: markers[indexPath.row])
    }
}

//extension Array where Element: Equatable {
//    func removeDuplicates() -> Array {
//        return reduce(into: []) { result, element in
//            if !result.contains(element) {
//                result.append(element)
//            }
//        }
//    }
//}

