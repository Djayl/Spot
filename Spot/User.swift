//
//  User.swift
//  Spot
//
//  Created by MacBook DS on 10/09/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import Firebase

class User: NSObject, MKAnnotation {
    let uid: String
    var name: String
    var location: GeoPoint?
    var spot = [Spot]()
    
    
    init(uid: String, name: String) {
        self.uid = uid
        self.name = name
    }
    
    var title: String? {
        return name
    }
    
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D.init(latitude: location?.latitude ?? 0,
                                           longitude: location?.longitude ?? 0)
    }
    
}
