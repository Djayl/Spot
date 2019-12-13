//
//  SpotCreatorProfileViewController.swift
//  Spot
//
//  Created by MacBook DS on 13/12/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit
import Kingfisher

class SpotCreatorProfileViewController: UIViewController {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var creatorNameLabel: UILabel!
    @IBOutlet weak var creatorEquipmentLabel: UILabel!
    @IBOutlet weak var creatorDescriptionLabel: UILabel!
    
    var profil: Profil?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        listenProfilInformation()
    }
    
    private func setupImageView() {
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
    }
    
    private func updateScreenWithProfil(_ profil: Profil) {
        creatorNameLabel.text = profil.userName.capitalized
        creatorDescriptionLabel.text = profil.description
        creatorEquipmentLabel.text = profil.equipment
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
    
    
}
