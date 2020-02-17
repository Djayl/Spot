//
//  CustomCell.swift
//  Spot
//
//  Created by MacBook DS on 02/11/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import Foundation
import UIKit

@available(iOS 13.0, *)
class CustomCell: UITableViewCell {
    
    // MARK: - Outlets
    
    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var cellImageView: UIImageView!
   
    // MARK: - Methods
    
    func configureCell(annotation:CustomAnnotation) {
        cellLabel.text = annotation.title?.capitalized
        cellLabel.font = UIFont(name: "Quicksand-Bold", size: 15)
        cellImageView.image = annotation.image
        cellImageView.layer.cornerRadius = 15
        cellImageView.layer.borderWidth = 2
//        cellImageView.layer.borderColor = UIColor.secondarySystemBackground.cgColor
    }
}

