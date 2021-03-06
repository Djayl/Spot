//
//  ExplanationViewController.swift
//  Spot
//
//  Created by MacBook DS on 21/11/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit

class ExplanationViewController: UIViewController {

    // MARK: - Outlets
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var textLabel2: UILabel!
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        handleFirstLabel()
        handleSecondLabel()
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    // MARK: - Methods
    
    private func handleFirstLabel() {
        textLabel.font = UIFont(name: "Quicksand-Regular", size: 17)
        textLabel.text = "Pour créer un Spot, il suffit d'un appui long sur la carte à l'endroit souhaité ou d'entrer une adresse dans la barre de recherche. \nUne nouvelle page de création apparaitra dans laquelle vous pourrez:\n - Choisir votre image \n - Nommer votre Spot \n - Décrire votre Spot "
    }
    
    private func handleSecondLabel() {
        textLabel2.font = UIFont(name: "Quicksand-Regular", size: 17)
        textLabel2.text = "Une fois tous les champs renseignés, vous pourrez choisir de partager votre Spot ou de le conserver dans votre collection privée.\n\nSi vous choisissez de le garder pour vous, vous serez alors le seul à pouvoir le voir.\nSi vous préférez le partager, il deviendra public et l'ensemble des utilisateurs y aura accès."
    }

}
