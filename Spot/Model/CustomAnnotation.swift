//
//  CustomAnnotation.swift
//  Spot
//
//  Created by MacBook DS on 15/02/2020.
//  Copyright © 2020 Djilali Sakkar. All rights reserved.
//

import UIKit
import MapKit

class CustomAnnotation: NSObject, MKAnnotation {
    
    @objc dynamic var coordinate: CLLocationCoordinate2D
    var creationDate: Date?
    var uid: String?
    var ownerId: String?
    var publicSpot: Bool?
    var creatorName: String?
    var imageID: String?
    var title: String?
    var subtitle: String?
    var image: UIImage?
    var imageURL: String?
    
    
    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
        super.init()
    }
}
