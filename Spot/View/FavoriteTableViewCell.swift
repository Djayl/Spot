//
//  FavoriteTableViewCell.swift
//  Spot
//
//  Created by MacBook DS on 01/11/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit
import Kingfisher
import GoogleMaps
import Firebase

class FavoriteTableViewCell: UITableViewCell {

    @IBOutlet weak var favoriteImage: UIImageView!
    @IBOutlet weak var favoriteTitle: UILabel!
    @IBOutlet weak var favoriteAddress: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    var favoriteSpot: Spot? {
        didSet {
            favoriteTitle.text = favoriteSpot?.name
            
        }
    }
    
}
