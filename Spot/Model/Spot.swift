//
//  Spot.swift
//  Spot
//
//  Created by MacBook DS on 10/09/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import Foundation
import GoogleMaps
import Firebase

class Spot: GMSMarker {
    var name: String?
    var summary: String?
    var image: UIImage?
    var coordinate: CLLocationCoordinate2D?
    var imageURL: String?
   

//  var description: String? {
//    return summary ?? "Aucune description n'a été rédigé pour ce Spot"
//  }
    
}

class CustomData{
    var creationDate: Date
    var uid: String
    var isFavorite: String
    init(creationDate: Date, uid: String, isFavorite: String) {
        self.creationDate = creationDate
        self.uid = uid
        self.isFavorite = isFavorite
    }
}
