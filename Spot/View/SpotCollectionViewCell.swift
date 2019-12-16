//
//  SpotCollectionViewCell.swift
//  Spot
//
//  Created by MacBook DS on 16/12/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class SpotCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var spotImageView: UIImageView!
    @IBOutlet weak var spotNameLabel: UILabel!
    
    // MARK: - Methods
       
       func configureCell(spot:Spot) {
           spotNameLabel.text = spot.name?.capitalized
           spotNameLabel.font = UIFont(name: "LeagueSpartan-Bold", size: 15)
           spotImageView.image = spot.image
           spotImageView.layer.cornerRadius = 15
           spotImageView.layer.borderWidth = 2
           spotImageView.layer.borderColor = UIColor.secondarySystemBackground.cgColor
       }
}
