//
//  Profil.swift
//  Spot
//
//  Created by MacBook DS on 06/11/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import Foundation

struct Profil: Equatable {
    let identifier: String
    let email: String
    let userName: String
    let imageURL: String
    let equipment: String
    let age: String
    let description: String

    var dictionary: [String: Any] {
        return [
            "userId": identifier,
            "email": email,
            "userName": userName,
            "imageURL": imageURL,
            "equipment": equipment,
            "age": age,
            "description": description
        ]
    }
}

extension Profil: DocumentSerializableProtocol {
    init?(dictionary: [String: Any]) {
       guard let identifier = dictionary["userId"] as? String,
            let email = dictionary["email"] as? String,
            let userName = dictionary["userName"] as? String,
            let imageURL = dictionary["imageURL"] as? String,
            let equipment = dictionary["equipment"] as? String,
            let age = dictionary["age"] as? String,
        let description = dictionary["description"] as? String else {return nil}
            
        
        self.init(identifier: identifier, email: email, userName: userName, imageURL: imageURL, equipment: equipment, age: age, description: description)
    }
}
