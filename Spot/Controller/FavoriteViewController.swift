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
    
    @IBOutlet weak var tableView: UITableView! { didSet{ tableView.tableFooterView = UIView() } }
    
    var markers = [Spot]()
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        tableView.reloadData()
        tableView.dataSource = self
        tableView.delegate = self
        
//        tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        markers.removeAll()
//        fetchPrivateSpots()
//        fetchSpotsFromPublic()
        listenToPrivateSpots()
//        listenToPublicSpots()
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        for markers in markers {
//            listener(spot: markers)
//        }
    }
    
    private func fetchPrivateSpots() {
        let firestoreService = FirestoreService<Marker>()
        firestoreService.fetchCollection(endpoint: .spot) { [weak self] result in
            switch result {
            case .success(let markers):
                for marker in markers {
                    if marker.isFavorite == true {
                        self?.displaySpot(marker)
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
    
    private func displaySpot(_ marker: Marker) {
        let name = marker.name
        guard let url = URL.init(string: marker.imageURL ) else {return}
        let mCustomData = CustomData(creationDate: marker.creationDate, uid: marker.identifier, isFavorite: marker.isFavorite, publicSpot: marker.publicSpot, creatorName: marker.creatorName)
        KingfisherManager.shared.retrieveImage(with: url, options: nil) { result in
            let image = try? result.get().image
            if let image = image {
                DispatchQueue.main.async {
                    let spot = Spot()
                    spot.position = CLLocationCoordinate2D(latitude: marker.coordinate.latitude, longitude: marker.coordinate.longitude)
                    spot.name = name
                    spot.title = name
                    spot.snippet = marker.description
                    spot.userData = mCustomData
                    spot.imageURL = marker.imageURL
                    spot.image = image
                    self.markers.append(spot)
                    print(self.markers.count as Any)
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func fetchSpotsFromPublic() {
        let firestoreService = FirestoreService<Marker>()
        firestoreService.fetchCollection(endpoint: .publicCollection) { [weak self] result in
            switch result {
            case .success(let markers):
                for marker in markers {
                    if marker.isFavorite == true {
                        self?.displaySpot(marker)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
                self?.presentAlert(with: "Erreur serveur")
            }
        }
    }
    
    private func listenToPrivateSpots() {
        let firestoreService = FirestoreService<Marker>()
        firestoreService.listenCollection(endpoint: .spot) { [weak self] result in
            switch result {
            case .success(let markers):
                for marker in markers {
                    if marker.isFavorite == true {
                    self?.displaySpot(marker)
                    }
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
                    if marker.isFavorite == true {
                    self?.displaySpot(marker)
                    }
                }
            case .failure(let error):
                print("Error updating document: \(error)")
                self?.presentAlert(with: "Erreur réseau")
            }
        }
    }
        
    private func listener(spot: Spot) {
        guard let spotUid = (spot.userData as! CustomData).uid else {return}
        let firestoreService = FirestoreService<Marker>()
        firestoreService.listenDocument(endpoint: .favorite(spotId: spotUid)) { [weak self] result in
            switch result {
            case .success(let marker):
                (spot.userData as! CustomData).isFavorite = marker.isFavorite
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
//            checkFavorite(spot: markers[indexPath.row])
            listener(spot: markers[indexPath.row])
            print((markers[indexPath.row].userData as! CustomData).isFavorite as Any)
            markers.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
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


