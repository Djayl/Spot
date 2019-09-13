//
//  Spot.swift
//  Spot
//
//  Created by MacBook DS on 10/09/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import Foundation
import MapKit
import Firebase

class Spot: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var info: String
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, info: String) {
        
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.info = info
    }
}
