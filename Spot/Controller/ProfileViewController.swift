//
//  ProfileViewController.swift
//  Spot
//
//  Created by MacBook DS on 10/12/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit
import Kingfisher
import GoogleMaps

@available(iOS 13.0, *)
class ProfileViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var equipmentLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var modifyButton: CustomButton!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var markers = [Spot]()

    override func viewDidLoad() {
        super.viewDidLoad()
        descriptionLabel.sizeToFit()
        setupImageView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        listenProfilInformation()
        fetchUserCollection()
        listenUserCollection()
    }
    
   
    @IBAction func goToCreateProfile(_ sender: Any) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "createProfileVC") as! CreateProfileViewController
               let nc = UINavigationController(rootViewController: vc)
               self.present(nc, animated: true, completion: nil)
    }
    
    @IBAction func logOut() {
        presentAlertWithAction(message: "Êtes-vous sûr de vouloir vous déconnecter?") {
            let authService = AuthService()
            do {
                try authService.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let initial = storyboard.instantiateInitialViewController()
            UIApplication.shared.keyWindow?.rootViewController = initial
        }
    }
    
    private func setupImageView() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }
    
    fileprivate func setupView() {
//        descriptionLabel.text = "Décrivez-vous"
//        descriptionLabel.font = UIFont(name: "GlacialIndifference-Regular", size: 15)
        descriptionLabel.layer.cornerRadius = 5
        profileImageView.isUserInteractionEnabled = true
        profileImageView.layer.cornerRadius = 10
        profileImageView.layer.masksToBounds = true
    }
    
    private func updateScreenWithProfil(_ profil: Profil) {
        usernameLabel.text = "\(profil.userName.capitalized)"
        descriptionLabel.text = profil.description
        equipmentLabel.text = profil.equipment.capitalized
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
        firestoreService.listenDocument(endpoint: .currentUser) { [weak self] result in
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
    
    @objc private func didTapSpot(spot: Spot) {
              let vc = storyboard?.instantiateViewController(withIdentifier: "DetailsVC") as! DetailsViewController
              let nc = UINavigationController(rootViewController: vc)
              vc.spot = spot
              self.present(nc, animated: true, completion: nil)
          }
      
      
      private func displaySpot(_ marker: Marker) {
              let name = marker.name
              guard let url = URL.init(string: marker.imageURL ) else {return}
              let mCustomData = CustomData(creationDate: marker.creationDate, uid: marker.identifier, ownerId: marker.ownerId, publicSpot: marker.publicSpot, creatorName: marker.creatorName)
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
    
    private func fetchUserCollection() {
                 let firestoreService = FirestoreService<Marker>()
                 firestoreService.fetchCollection(endpoint: .spot) { [weak self] result in
                     switch result {
                     case .success(let markers):
                         for marker in markers {
                             self?.markers.removeAll()
                             self?.displaySpot(marker)
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
          
          private func listenUserCollection() {
              let firestoreService = FirestoreService<Marker>()
              firestoreService.listenCollection(endpoint: .spot) { [weak self] result in
                  switch result {
                  case .success(let markers):
                      for marker in markers {
                          self?.markers.removeAll()
                          self?.displaySpot(marker)
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return markers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SpotCell", for: indexPath) as? SpotCollectionViewCell {
            cell.configureCell(spot: markers[indexPath.item])
            cell.contentView.layer.cornerRadius = 5
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      didTapSpot(spot: markers[indexPath.item])
    }
}
