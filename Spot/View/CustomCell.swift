//
//  CustomCell.swift
//  Spot
//
//  Created by MacBook DS on 02/11/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import Foundation
import UIKit

class CustomCell: UITableViewCell {
    
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
   
    
    func configureCell(spot:Spot) {
        
        cellLabel.text = spot.name?.capitalized
        cellLabel.font = UIFont(name: "IndigoRegular-Regular", size: 15)
        cellImageView.image = spot.image
        cellImageView.layer.cornerRadius = 15
        cellImageView.layer.borderWidth = 2
        cellImageView.layer.borderColor = Colors.skyBlue.cgColor
    }
}

