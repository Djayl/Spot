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
        cellImageView.image = spot.image
    }
}

