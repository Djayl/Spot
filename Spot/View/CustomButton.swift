//
//  CustomButton.swift
//  Spot
//
//  Created by MacBook DS on 19/09/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class CustomButton: UIButton {
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupButton()
    }
    
    // MARK: - Methods
    
    func setupButton() {
        setShadow()
        setTitleColor(UIColor.label, for: .normal)
        backgroundColor      = UIColor.systemBackground
        titleLabel?.font     = UIFont(name: "Quicksand-Bold", size: 17)
        layer.cornerRadius   = 25
        layer.borderWidth    = 3.0
        layer.borderColor    = UIColor.tertiarySystemBackground.cgColor
    }
    
    private func setShadow() {
        layer.shadowColor   = Colors.nicoDarkPurple.cgColor
        layer.shadowOffset  = CGSize(width: 0.0, height: 6.0)
        layer.shadowRadius  = 8
        layer.shadowOpacity = 0.5
        clipsToBounds       = true
        layer.masksToBounds = false
    }
    
    func shake() {
        let shake           = CABasicAnimation(keyPath: "position")
        shake.duration      = 0.1
        shake.repeatCount   = 2
        shake.autoreverses  = true
        
        let fromPoint       = CGPoint(x: center.x - 8, y: center.y)
        let fromValue       = NSValue(cgPoint: fromPoint)
        
        let toPoint         = CGPoint(x: center.x + 8, y: center.y)
        let toValue         = NSValue(cgPoint: toPoint)
        
        shake.fromValue     = fromValue
        shake.toValue       = toValue
        
        layer.add(shake, forKey: "position")
    }
}
