//
//  CollectionViewCell.swift
//  Spot
//
//  Created by MacBook DS on 23/12/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(spot:Spot) {
        imageView.layer.cornerRadius = 5
        label.font = UIFont(name: "Quicksand-Regular", size: 14)
        imageView.clipsToBounds = true
        label.text = spot.title?.capitalized
        imageView.image = spot.image
    }
}
