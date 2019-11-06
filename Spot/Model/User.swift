//
//  User.swift
//  Spot
//
//  Created by MacBook DS on 10/09/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//
//
//import Foundation
//
//struct User {
//    let name: String
//    let imageURL: String
//    
//    var dictionary: [String: Any] {
//        return [
//            "name": name,
//            "imageURL": imageURL
//        ]
//    }
//}
//
//extension User: DocumentSerializableProtocol {
//    init?(dictionary: [String: Any]) {
//        guard let name = dictionary["name"] as? String,
//            let imageURL = dictionary["imageURL"] as? String else { return nil }
//        
//        self.init(name: name, imageURL: imageURL )
//    }
//}
