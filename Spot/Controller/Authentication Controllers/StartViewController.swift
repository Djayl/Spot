//
//  StartViewController.swift
//  Spot
//
//  Created by MacBook DS on 17/09/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit
import Firebase

class StartViewController: UIViewController {

    @IBOutlet weak var loginButton: CustomButton!
    @IBOutlet weak var signupButton: CustomButton!
    
    var gradient: CAGradientLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addGradient()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if Auth.auth().currentUser != nil {
            self.performSegue(withIdentifier: "alreadyLoggedIn", sender: nil)
        }
    }
    
    func addGradient() {
        gradient = CAGradientLayer()
//        let startColor = UIColor(red: 3/255, green: 196/255, blue: 190/255, alpha: 1)
//        let endColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        gradient?.colors = [UIColor.blue.cgColor,UIColor.cyan.cgColor]
        gradient?.startPoint = CGPoint(x: 0, y: 0)
        gradient?.endPoint = CGPoint(x: 0, y:1)
        gradient?.frame = view.frame
        self.view.layer.insertSublayer(gradient!, at: 0)
    }
 
    func addActionToButtons() {
        loginButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
    }
    
    @objc func buttonTapped() {
        loginButton.shake()
    }
}
