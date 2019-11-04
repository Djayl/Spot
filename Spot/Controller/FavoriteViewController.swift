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

struct Markers {
    var name: String?
}

class FavoriteViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var markers = [Spot]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
       
        tableView.reloadData()
   
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
     
                    let imageUrl = document.get("imageUrl")
                    let imageUrl2 = imageUrl
                    guard let url = URL.init(string: imageUrl2 as! String) else {return}
                    KingfisherManager.shared.retrieveImage(with: url, options: nil) { result in
                        
                        let image = try? result.get().image
                        
                        if let image = image {
                            DispatchQueue.main.async {
                                let marker = Spot()
                                marker.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                marker.name = title
                                print(title as Any)
                                marker.icon = image
                                //                                    self.markers.append(marker)
                                print(self.markers)
                                
                            }
                            
                        }
                        
                    }
                    
                }
            }
            
        }
    }
    
    func deleteSpot(spot: Spot) {
         let uid = Auth.auth().currentUser?.uid
                let spotUid = (spot.userData as! CustomData).uid
                let ref = FirestoreReferenceManager.referenceForUserPublicData(uid: uid!).collection("Spots").document(spotUid)
             
                    ref.updateData(["isFavorite": "No"]) { (error) in
                        if let error = error {
                            print(error.localizedDescription)
                        }
                        self.tableView.reloadData()
                        print("Succesfully UnFavorite")
                    }
    }
    
    func loadData() {
        guard let uid = Auth.auth().currentUser?.uid else {return}
        FirestoreReferenceManager.referenceForUserPublicData(uid: uid).collection("Spots").whereField("isFavorite", isEqualTo: "Yes").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                
                for document in querySnapshot!.documents {
                    if let title = document.data()["title"] as? String,
                    let imageUrl = document.data()["imageUrl"] as? String,
                    let coordinate = document.data()["coordinate"] as? GeoPoint,
                    let description = document.data()["description"] as? String,

                        let creationDate = document.data()["createdAt"] as? Timestamp,
                        let uid = document.data()["uid"] as? String,
                        let favorite = document.data()["isFavorite"] as? String
                    {
                        let position = coordinate
                        let lat = position.latitude
                        let lon = position.longitude
                        let spotFavorite = favorite
                        let date = creationDate.dateValue()
                        let spotUid = uid
                        let mCustomData = CustomData(creationDate: date, uid: spotUid, isFavorite: spotFavorite)
                        
                        print(title as Any)
                        guard let url = URL.init(string: imageUrl) else {return}
                        KingfisherManager.shared.retrieveImage(with: url, options: nil) { result in
                            let image = try? result.get().image
                            if let image = image {
                                DispatchQueue.main.async {
                                    
                                    let spot = Spot()
                                    spot.position = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                   
                                    spot.snippet = description
                                    spot.userData = mCustomData
                                    spot.name = title
                                    spot.title = title
                                    spot.image = image
                                    spot.imageURL = imageUrl
                                    self.markers.append(spot)
                                   
                                    print(self.markers.count)
                                   
                                        self.tableView.reloadData()
                                    
                                    
                                }
                                
                            }
//                                            self.tableView.reloadData()
                        }
                       
                    }
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
//            cell.layer.borderColor = UIColor.black.cgColor
//            cell.layer.borderWidth = 2
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
            deleteSpot(spot: markers[indexPath.row])
            markers.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            //            UserDefaults.standard.set(ingredients, forKey: "myIngredients")
            tableView.endUpdates()
            
            print("SUCCESSFULLY DELETED FROM FAVORITE TV")
            tableView.reloadData()
            
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Ajouter ici vos favoris"
        label.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
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
        
    }
    
}

extension Array where Element: Equatable {
    func removeDuplicates() -> Array {
        return reduce(into: []) { result, element in
            if !result.contains(element) {
                result.append(element)
            }
        }
    }
}

