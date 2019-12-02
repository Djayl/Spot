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
    
    // MARK: - Properties
    
    var gradient: CAGradientLayer?
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradient()
        handleFirstLabel()
        handleSecondLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Methods
    
    private func handleFirstLabel() {
        textLabel.layer.masksToBounds = true
        textLabel.layer.cornerRadius = 10
        textLabel.backgroundColor = Colors.nicoPurple
        textLabel.font = UIFont(name: "IndigoRegular-Regular", size: 15)
        textLabel.sizeToFit()
        textLabel.text = "Pour créer un Spot, il suffit d'un appui long sur la carte à l'endroit souhaité. \nUne nouvelle page de création apparaitra dans laquelle vous pourrez:\n\n - Choisir votre image \n - Nommer votre Spot \n - Décrire votre Spot "
    }
    
    private func handleSecondLabel() {
        textLabel2.layer.masksToBounds = true
        textLabel2.layer.cornerRadius = 10
        textLabel2.backgroundColor = Colors.nicoBlue
        textLabel2.font = UIFont(name: "IndigoRegular-Regular", size: 15)
        textLabel2.sizeToFit()
        textLabel2.text = "Une fois tous les champs renseignés, vous pourrez choisir de partager votre Spot ou de le conserver dans votre collection privée.\n\nSi vous choisissez de le garder pour vous, vous serez alors le seul à pouvoir le voir.\n\nSi vous préférez le partager, il deviendra public et l'ensemble des utilisateurs y aura accès."
    }

    private func addGradient() {
           gradient = CAGradientLayer()
           gradient?.colors = [Colors.skyBlue.cgColor, UIColor.white]
           gradient?.startPoint = CGPoint(x: 0, y: 0)
           gradient?.endPoint = CGPoint(x: 0, y:1)
           gradient?.frame = view.frame
           self.view.layer.insertSublayer(gradient!, at: 0)
       }
}
