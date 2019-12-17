//
//  SpotCreatorProfileViewController.swift
//  Spot
//
//  Created by MacBook DS on 13/12/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit
import Kingfisher
import GoogleMaps

@available(iOS 13.0, *)
class SpotCreatorProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var creatorEquipmentLabel: UILabel!
    @IBOutlet weak var creatorDescriptionLabel: UILabel!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var userId = ""
    var markers = [Spot]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
        creatorDescriptionLabel.sizeToFit()
         tableView.register(UINib(nibName: "SpotTableViewCell", bundle: nil),forCellReuseIdentifier: "SpotTableViewCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        listenProfilInformation()
        listenUserCollection()
    }
    
    private func setupImageView() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }
    
    private func updateScreenWithProfil(_ profil: Profil) {
        creatorNameLabel.text = "\(profil.userName.capitalized)"
        creatorDescriptionLabel.text = profil.description
        creatorEquipmentLabel.text = profil.equipment.capitalized
        ageLabel.text = "\(profil.age) ans"
    }
    
    private func getImage(_ profil: Profil) {
        let urlString = profil.imageURL
        guard let url = URL(string: urlString) else {return}
        KingfisherManager.shared.retrieveImage(with: url, options: nil) { result in
            let image = try? result.get().image
            if let image = image {
                self.profileImageView.image = image
            }
        }
    }
    
    private func listenProfilInformation() {
        let firestoreService = FirestoreService<Profil>()
        firestoreService.listenDocument(endpoint: .particularUser(userId: userId)) { [weak self] result in
            switch result {
            case .success(let profil):
                self?.updateScreenWithProfil(profil)
                self?.getImage(profil)
            case .failure(let error):
                print(error.localizedDescription)
                self?.presentAlert(with: "Erreur réseau")
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
        
        private func listenUserCollection() {
            let firestoreService = FirestoreService<Marker>()
            firestoreService.listenCollection(endpoint: .particularUserCollection(userId: userId)) { [weak self] result in
                switch result {
                case .success(let markers):
                    for marker in markers {
                        self?.markers.removeAll()
                        if marker.publicSpot == true {
                        self?.displaySpot(marker)
                            print(marker.name)
                    }
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
            
        @objc private func didTapSpot(spot: Spot) {
            let vc = storyboard?.instantiateViewController(withIdentifier: "DetailsVC") as! DetailsViewController
            let nc = UINavigationController(rootViewController: vc)
            vc.spot = spot
            self.present(nc, animated: true, completion: nil)
        }
    }

    // MARK: - Table View delegate and data source

    
@available(iOS 13.0, *)
extension SpotCreatorProfileViewController: UITableViewDataSource, UITableViewDelegate {
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection    section: Int) -> Int {
            return markers.count
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 100
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "SpotTableViewCell") as? SpotTableViewCell {
                cell.configureCell(spot: markers[indexPath.row])
                cell.contentView.layer.cornerRadius = 10
                return cell
            }
            return UITableViewCell()
        }
        
        func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
        
//        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle,
//                       forRowAt indexPath: IndexPath) {
//            if editingStyle == .delete {
//                removeFav(spot: markers[indexPath.row])
//                markers.remove(at: indexPath.row)
//                tableView.deleteRows(at: [indexPath], with: .automatic)
//            }
//        }
        
        func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
            let label = UILabel()
            label.text = "Ajoutez ici vos favoris"
            label.font = UIFont(name: "LeagueSpartan-Bold", size: 20)
            label.textAlignment = .center
            label.textColor = .label
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



    
    

