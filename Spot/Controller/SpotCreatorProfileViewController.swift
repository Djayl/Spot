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
    
    // MARK: - Outlets
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var creatorEquipmentLabel: UILabel!
    @IBOutlet weak var creatorDescriptionTextView: UITextView!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties

    var userId = ""
    var markers = [Spot]()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.dataSource = self
        collectionView.delegate = self
        setupImageView()
        textViewDidChange(creatorDescriptionTextView)
        collectionView.register(UINib.init(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "collectionCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        listenProfilInformation()
        listenUserCollection()
    }
    
    // MARK: - Methods
    
    private func setupImageView() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }
    
    private func updateScreenWithProfil(_ profil: Profil) {
        creatorNameLabel.text = "\(profil.userName.capitalized)"
        creatorDescriptionTextView.text = profil.description
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
                    self.collectionView.reloadData()
                }
            }
        }
        
        private func listenUserCollection() {
            let firestoreService = FirestoreService<Marker>()
            firestoreService.listenCollection(endpoint: .particularUserCollection(userId: userId)) { [weak self] result in
                switch result {
                case .success(let markers):
                    self?.markers.removeAll()
                    for marker in markers {
                        if marker.publicSpot == true {
                        self?.displaySpot(marker)
                            print(marker.name)
                    }
                    }
                    DispatchQueue.main.async {
                        self?.collectionView.reloadData()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                    self?.presentAlert(with: "Erreur serveur")
                }
            }
        }
            
        @objc private func didTapSpot(spot: Spot) {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "DetailsVC") as! DetailsViewController
            vc.spot = spot
            navigationController?.pushViewController(vc, animated: true)
        }
  
    }

    // MARK: - Table View delegate and data source

    @available(iOS 13.0, *)
    extension SpotCreatorProfileViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return markers.count
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as? CollectionViewCell {
                cell.configureCell(spot: markers[indexPath.row])
                cell.contentView.frame = cell.bounds
                return cell
            }
            return UICollectionViewCell()
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return CGSize(width: collectionView.frame.height / 6 * 5, height: collectionView.frame.height / 6 * 5)
        }
        
        func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            didTapSpot(spot: markers[indexPath.row])
        }
    }

@available(iOS 13.0, *)
extension SpotCreatorProfileViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
}


    
    

