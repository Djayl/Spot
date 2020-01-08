//
//  FavoriteButton.swift
//  Spot
//
//  Created by MacBook DS on 29/10/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit

class FavoriteButton: UIButton {
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initButton()
    }
    
    // MARK: - Methods
    
    var isOn = false {
        didSet {
            let color = isOn ? Colors.customBlue: .clear
            let title = isOn ? "Favori" : "Mettre en favori"
            let titleColor = isOn ? . white : Colors.customBlue
            
            setTitle(title, for: .normal)
            setTitleColor(titleColor, for: .normal)
            backgroundColor = color
            
        }
    }
    
    func initButton() {
        titleLabel?.font = UIFont(name: "Quicksand", size: 15)
        layer.borderWidth = 2.0
        layer.borderColor = Colors.customBlue.cgColor
        layer.cornerRadius = frame.size.height/2
        setTitleColor(Colors.customBlue, for: .normal)
    }
}
