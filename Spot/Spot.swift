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
//    var imageUrl: String
    var image: UIImage
//    var imageView: UIImageView
    
    init(title: String, subtitle: String, coordinate: CLLocationCoordinate2D, info: String, image: UIImage) {
        
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.info = info
        self.image = image
//        self.imageUrl = imageUrl
//        self.imageView = imageView
       
        super.init()
    }
    
  
}
