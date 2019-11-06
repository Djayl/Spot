//
//  Marker.swift
//  Spot
//
//  Created by MacBook DS on 06/11/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import Foundation
import Firebase
import GoogleMaps

struct Marker {
    let identifier: String
    let name: String
    let description: String
    let coordinate: GeoPoint
    let imageURL: String
    let isFavorite: String
    let creationDate: Date
   
    
    var dictionary: [String: Any] {
        return [
            "id": identifier,
            "name": name,
            "description": description,
            "coordinate": GeoPoint(latitude: coordinate.latitude, longitude: coordinate.longitude),
            "imageURL": imageURL,
            "isFavorite": isFavorite,
            "creationDate": creationDate,
           
        ]
    }
}

extension Marker: DocumentSerializableProtocol {
    init?(dictionary: [String: Any]) {
        guard let identifier = dictionary["id"] as? String,
            let name = dictionary["name"] as? String,
            let description = dictionary["description"] as? String,
            let coordinate = dictionary["coordinate"] as? GeoPoint,
            let imageURL = dictionary["imageURL"] as? String,
            let isFavorite = dictionary["isFavorite"] as? String else { return nil}
        
        var date = Date()
        if let creationDate = dictionary["creationDate"] as? Timestamp {
            date = creationDate.dateValue()
            
        }
       
        self.init(identifier: identifier, name: name, description: description, coordinate: coordinate, imageURL: imageURL, isFavorite: isFavorite, creationDate: date)
    }
    
}

