//
//  SpotTableViewCell.swift
//  Spot
//
//  Created by MacBook DS on 16/12/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class SpotTableViewCell: UITableViewCell {
    
    
        // MARK: - Outlets
        
        @IBOutlet weak var cellLabel: UILabel!
        @IBOutlet weak var cellImageView: UIImageView!
    
    

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

       
        // MARK: - Methods
        
        func configureCell(spot:Spot) {
            cellLabel.text = spot.name?.capitalized
            cellLabel.font = UIFont(name: "LeagueSpartan-Bold", size: 15)
            cellImageView.image = spot.image
            cellImageView.layer.cornerRadius = 15
            cellImageView.layer.borderWidth = 2
            cellImageView.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        }
    
}
