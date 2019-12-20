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
class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var equipmentLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var modifyButton: CustomButton!
    @IBOutlet weak var ageLabel: UILabel!
    @IBOutlet weak var tableView: UITableView! { didSet{ tableView.tableFooterView = UIView() } }
    
    
    var markers = [Spot]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        textViewDidChange(<#T##textView: UITextView##UITextView#>)
        setUpTableView()
        descriptionLabel.sizeToFit()
        setupImageView()
        tableView.register(UINib(nibName: "SpotTableViewCell", bundle: nil),forCellReuseIdentifier: "SpotTableViewCell")
//        listenUserCollection()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        listenProfilInformation()
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
    
    fileprivate func setUpTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
    }
    
    private func setupImageView() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }
    
    fileprivate func setupView() {
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
//        let vc = storyboard?.instantiateViewController(withIdentifier: "DetailsVC") as! DetailsViewController
//        let nc = UINavigationController(rootViewController: vc)
//        vc.spot = spot
//        self.present(nc, animated: true, completion: nil)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "DetailsVC") as! DetailsViewController
        vc.spot = spot
        navigationController?.pushViewController(vc, animated: true)
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
                self.tableView.reloadData()
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
                self?.markers.removeAll()
                for marker in markers {
                    self?.displaySpot(marker)
                    print(marker.name)
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
    
    private func removeImageFromFirebase(spot: Spot) {
        let firebaseStorageManager = FirebaseStorageManager()
        guard let imageID = (spot.userData as? CustomData)?.imageID else {return}
        firebaseStorageManager.deleteImageData(serverFileName: imageID)
    }
    
    private func removeFav(spot: Spot) {
        guard let spotUid = (spot.userData as! CustomData).uid else {return}
        deletePrivateSpotFromFirestore(identifier: spotUid)
        deletePublicSpotFromFirestore(identifier: spotUid)
        removeImageFromFirebase(spot: spot)
    }
    
    private func deletePrivateSpotFromFirestore(identifier: String) {
        let firestoreService = FirestoreService<Marker>()
        firestoreService.deleteDocumentData(endpoint: .spot, identifier: identifier) { [weak self] result in
            switch result {
            case .success(let successMessage):
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                print(successMessage)
            case .failure(let error):
                print("Error deleting document: \(error)")
                self?.presentAlert(with: "Problème réseau")
            }
        }
    }
    
    private func deletePublicSpotFromFirestore(identifier: String) {
        let firestoreService = FirestoreService<Marker>()
        firestoreService.deleteDocumentData(endpoint: .publicCollection, identifier: identifier) { [weak self] result in
            switch result {
            case .success(let successMessage):
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
                print(successMessage)
            case .failure(let error):
                print("Error deleting document: \(error)")
                self?.presentAlert(with: "Problème réseau")
            }
        }
    }
    
}

// MARK: - Table View delegate and data source

@available(iOS 13.0, *)
extension ProfileViewController: UITableViewDataSource, UITableViewDelegate {
    
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
        label.text = "Vous n'avez pas de Spots"
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

@available(iOS 13.0, *)
extension ProfileViewController: UITextViewDelegate {
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
