//
//  CollectionViewController.swift
//  Spot
//
//  Created by MacBook DS on 23/12/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit
import Kingfisher
import MapKit

@available(iOS 13.0, *)
class ProfileViewController: UIViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var equipmentLabel: UILabel!
    @IBOutlet weak var modifyButton: CustomButton!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    
    // MARK: - Properties
    
    var markers = [CustomAnnotation]()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.black,
             NSAttributedString.Key.font: UIFont(name: "Quicksand-Bold", size: 21)!]
        self.navigationItem.title = "Profil"
        listenProfilInformation()
//        listenUserCollection()
        collectionView.dataSource = self
        collectionView.delegate = self
        textViewDidChange(descriptionTextView)
        setupImageView()
        collectionView.register(UINib.init(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "collectionCell")
        descriptionTextView.backgroundColor = UIColor.white
        setDeleteButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchUserCollection()
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = true
        //        listenProfilInformation()
        //        listenUserCollection()
    }
    
    // MARK: - Actions
    
    @IBAction func goToCreateProfile(_ sender: Any) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "createProfileVC") as! CreateProfileViewController
        self.navigationController?.pushViewController(secondViewController, animated: true)
        
    }
    
    
    // MARK: - Methods
    
    //    fileprivate func setBackground() {
    //        let backgroundImage = UIImageView(frame: UIScreen.main.bounds)
    //        backgroundImage.image = UIImage(named: "Spoteoshadow")
    //        backgroundImage.alpha = 0.2
    //        backgroundImage.contentMode = UIView.ContentMode.scaleAspectFit
    //        self.view.insertSubview(backgroundImage, at: 0)
    //        backgroundImage.center = view.center
    //    }
    
    @objc private func logOut() {
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
    
    private func setDeleteButton() {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "exit"), for: .normal)
        button.sizeToFit()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: button)
        button.addTarget(self, action: #selector(logOut), for: .touchUpInside)
    }
    
    private func setupImageView() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }
    
    fileprivate func setupView() {
        profileImageView.isUserInteractionEnabled = true
        profileImageView.layer.cornerRadius = 10
        profileImageView.layer.masksToBounds = true
    }
    
    private func updateScreenWithProfil(_ profil: Profil) {
        usernameLabel.text = "\(profil.userName.capitalized)"
        descriptionTextView.text = profil.description
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
    
//    private func displaySpot(_ marker: Marker) {
//        let name = marker.name
//        guard let url = URL.init(string: marker.imageURL ) else {return}
//        let mCustomData = CustomData(creationDate: marker.creationDate, uid: marker.identifier, ownerId: marker.ownerId, publicSpot: marker.publicSpot, creatorName: marker.creatorName, imageID: marker.imageID)
//        KingfisherManager.shared.retrieveImage(with: url, options: nil) { result in
//            let image = try? result.get().image
//            if let image = image {
//                let spot = Spot()
//                spot.position = CLLocationCoordinate2D(latitude: marker.coordinate.latitude, longitude: marker.coordinate.longitude)
//                spot.name = name
//                spot.title = name
//                spot.snippet = marker.description
//                spot.userData = mCustomData
//                spot.imageURL = marker.imageURL
//                spot.image = image
//                self.markers.append(spot)
//                self.collectionView.reloadData()
//            }
//        }
//    }
    
    private func displayAnnotation(_ marker: Marker) {
           let name = marker.name
           let latitude = marker.coordinate.latitude
           let longitude = marker.coordinate.longitude
           let identifier = marker.identifier
           let imageURL = marker.imageURL
           let summary = marker.description
           let creationDate = marker.creationDate
           let creatorName = marker.creatorName
           let imageId = marker.imageID
           let publicSpot = marker.publicSpot
           let ownerId = marker.ownerId
           
           guard let url = URL.init(string: marker.imageURL ) else {return}
          
           KingfisherManager.shared.retrieveImage(with: url, options: nil) { result in
               let image = try? result.get().image
               if let image = image {
                   let annotation = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                  annotation.creationDate = creationDate
                    annotation.creatorName = creatorName
                    annotation.imageID = imageId
                    annotation.ownerId = ownerId
                    annotation.publicSpot = publicSpot
                    annotation.uid = identifier
                    annotation.subtitle = summary
                    annotation.title = name
                    annotation.image = image
                   annotation.imageURL = imageURL
                   self.markers.append(annotation)
                   self.collectionView.reloadData()
               }
           }
       }
    
    private func listenUserCollection() {
        let firestoreService = FirestoreService<Marker>()
        firestoreService.listenCollection(endpoint: .spot) { [weak self] result in
            switch result {
            case .success(let markers):
                self?.markers.removeAll()
                for marker in markers {
                    self?.displayAnnotation(marker)
                    print(marker.name)
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
    
    private func fetchUserCollection() {
           let firestoreService = FirestoreService<Marker>()
           firestoreService.fetchCollection(endpoint: .spot) { [weak self] result in
               switch result {
               case .success(let markers):
                   self?.markers.removeAll()
                   for marker in markers {
                       self?.displayAnnotation(marker)
                       print(marker.name)
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
    
    @objc private func didTapSpot(annotation: CustomAnnotation) {
        let secondViewController = self.storyboard?.instantiateViewController(withIdentifier: "SpotDetailsVC") as! SpotDetailsViewController
        secondViewController.annotation = annotation
        self.navigationController?.pushViewController(secondViewController, animated: true)
    }
}

// MARK: - Table View delegate and data source

@available(iOS 13.0, *)
extension ProfileViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return markers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as? CollectionViewCell {
            cell.configureCell(annotation: markers[indexPath.row])
            cell.contentView.frame = cell.bounds
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height / 6 * 5, height: collectionView.frame.height / 6 * 5)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didTapSpot(annotation: markers[indexPath.row])
    }
}

@available(iOS 13.0, *)
extension ProfileViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textView.delegate = self
        let size = CGSize(width: view.frame.width, height: .infinity)
        let estimatedSize = textView.sizeThatFits(size)
        textView.constraints.forEach { (constraint) in
            if constraint.firstAttribute == .height {
                constraint.constant = estimatedSize.height
            }
        }
    }
}
