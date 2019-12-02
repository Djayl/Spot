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

class Spot: GMSMarker{
    var name: String?
    var summary: String?
    var image: UIImage?
    var coordinate: CLLocationCoordinate2D?
    var imageURL: String?
}

class CustomData{
    var creationDate: Date?
    var uid: String?
    var ownerId: String?
    var publicSpot: Bool?
    var creatorName: String?
    init(creationDate: Date, uid: String, ownerId: String, publicSpot: Bool, creatorName: String) {
        self.creationDate = creationDate
        self.uid = uid
        self.ownerId = ownerId
        self.publicSpot = publicSpot
        self.creatorName = creatorName
    }
}
