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
            let color = isOn ? Colors.twitterBlue: .clear
            let title = isOn ? "Favori" : "Mettre en favori"
            let titleColor = isOn ? . white : Colors.twitterBlue
            
            setTitle(title, for: .normal)
            setTitleColor(titleColor, for: .normal)
            backgroundColor = color
        }
    }
    
    func initButton() {
        layer.borderWidth = 2.0
        layer.borderColor = Colors.twitterBlue.cgColor
        layer.cornerRadius = frame.size.height/2
        setTitleColor(Colors.twitterBlue, for: .normal)
    }
}
