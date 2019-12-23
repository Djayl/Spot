//
//  MainCell.swift
//  Spot
//
//  Created by MacBook DS on 22/12/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit

class MainCell: UICollectionViewCell {
    
    @IBOutlet weak var spotImageView: UIImageView!
    @IBOutlet weak var spotLabel: UILabel!
    

           
            // MARK: - Methods
            
            func configureCell(spot:Spot) {
                spotImageView.layer.cornerRadius = 5
                spotLabel.font = UIFont(name: "LeagueSpartan-Bold", size: 15)
                spotImageView.clipsToBounds = true
                spotLabel.text = spot.title?.capitalized
                spotImageView.image = spot.image
            }
}
