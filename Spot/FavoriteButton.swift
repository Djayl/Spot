//
//  FavoriteButton.swift
//  Spot
//
//  Created by MacBook DS on 29/10/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit

class FavoriteButton: UIButton {
    

    var isOn = true {
        didSet {


            let color = !isOn ? Colors.twitterBlue: .clear
            let title = !isOn ? "Favori" : "Mettre en favori"
            let titleColor = !isOn ? . white : Colors.twitterBlue

            setTitle(title, for: .normal)
            setTitleColor(titleColor, for: .normal)
            backgroundColor = color
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        initButton()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initButton()
    }
    
    func initButton() {
        layer.borderWidth = 2.0
        layer.borderColor = Colors.twitterBlue.cgColor
        layer.cornerRadius = frame.size.height/2
        
        setTitleColor(Colors.twitterBlue, for: .normal)
//        addTarget(self, action: #selector(FavoriteButton.buttonPressed), for: .touchUpInside)
    }
    
    @objc func buttonPressed() {
        activateButton(bool: !isOn)
    }
    
    func activateButton(bool: Bool) {
        isOn = bool
        
        let color = bool ? Colors.twitterBlue: .clear
        let title = bool ? "Favori" : "Mettre en favori"
        let titleColor = bool ? . white : Colors.twitterBlue
        
        setTitle(title, for: .normal)
        setTitleColor(titleColor, for: .normal)
        backgroundColor = color
    }
}
