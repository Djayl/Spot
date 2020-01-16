//
//  FavoriteViewController.swift
//  Spot
//
//  Created by MacBook DS on 01/11/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit
import GoogleMaps
import Kingfisher
import ProgressHUD


@available(iOS 13.0, *)
class FavoriteViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var tableView: UITableView! { didSet{ tableView.tableFooterView = UIView() } }
    
    // MARK: - Properties
    
    var markers = [Spot]()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor.white
        tabBarController?.tabBar.isHidden = false
        fetchFavoriteSpots()
//        listenFavoriteCollection()
        print(markers.count)
        tableView.register(UINib(nibName: "SpotTableViewCell", bundle: nil),forCellReuseIdentifier: "SpotTableViewCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // MARK: - Methods
    
    fileprivate func setUpTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor.white
    }
    
    private func fetchFavoriteSpots() {
        let firestoreService = FirestoreService<Marker>()
        firestoreService.fetchCollectionUnordered(endpoint: .favoriteCollection) { [weak self] result in
            switch result {
            case .success(let markers):
                self?.markers.removeAll()
                for marker in markers {
                    self?.displaySpot(marker)
                }
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
                self?.presentAlert(with: "Erreur serveur")
            }
        }
    }
    
    private func displaySpot(_ marker: Marker) {
        let name = marker.name
        guard let url = URL.init(string: marker.imageURL ) else {return}
        let mCustomData = CustomData(creationDate: marker.creationDate, uid: marker.identifier, ownerId: marker.ownerId, publicSpot: marker.publicSpot, creatorName: marker.creatorName, imageID: marker.imageID)
        KingfisherManager.shared.retrieveImage(with: url, options: nil) { result in
            let image = try? result.get().image
            if let image = image {
                let spot = Spot()
                spot.position = CLLocationCoordinate2D(latitude: marker.coordinate.latitude, longitude: marker.coordinate.longitude)
                spot.name = name
                spot.title = name
                spot.snippet = marker.description
                spot.userData = mCustomData
                spot.imageURL = marker.imageURL
                spot.image = image
                self.markers.append(spot)
                
            }
        }
    }
    
    private func listenFavoriteCollection() {
        let firestoreService = FirestoreService<Marker>()
        firestoreService.listenCollection(endpoint: .favoriteCollection) { [weak self] result in
            switch result {
            case .success(let markers):
                self?.markers.removeAll()
                for marker in markers {
                    self?.displaySpot(marker)
                }
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print(error.localizedDescription)
                self?.presentAlert(with: "Erreur serveur")
            }
        }
    }
    
    private func removeFav(spot: Spot) {
        guard let spotUid = (spot.userData as! CustomData).uid else {return}
        deleteFavoriteFromFirestore(identifier: spotUid)
    }
    
    private func deleteFavoriteFromFirestore(identifier: String) {
        let firestoreService = FirestoreService<Marker>()
        firestoreService.deleteDocumentData(endpoint: .favoriteCollection, identifier: identifier) { [weak self] result in
            switch result {
            case .success(let successMessage):
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                print(self?.markers as Any)
                print(successMessage)
            case .failure(let error):
                print("Error deleting document: \(error)")
                self?.presentAlert(with: "Problème réseau")
            }
        }
    }
    
    @objc private func didTapSpot(spot: Spot) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "DetailsVC") as! DetailsViewController
        secondViewController.spot = spot
        self.navigationController?.pushViewController(secondViewController, animated: true)
        
    }
}

// MARK: - Table View delegate and data source

@available(iOS 13.0, *)
extension FavoriteViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection    section: Int) -> Int {
        return markers.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SpotTableViewCell") as? SpotTableViewCell {
            cell.configureCell(spot: markers[indexPath.row])
            //            cell.contentView.layer.cornerRadius = 10
            cell.backgroundColor = UIColor.white
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
            removeFav(spot: markers[indexPath.row])
            markers.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        label.text = "Ajoutez ici vos favoris"
        label.font = UIFont(name: "Quicksand-Bold", size: 20)
        label.textAlignment = .center
        label.textColor = .black
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


