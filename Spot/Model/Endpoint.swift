//
//  Endpoint.swift
//  Spot
//
//  Created by MacBook DS on 06/11/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import Foundation

public enum Endpoint {
    case user
    case currentUser
    case spot
    case publicCollection
    case publicSpot(spotId: String)
    case favorite(spotId: String)
    case favoriteCollection
    case favoriteSpot(spotId: String)
    case particularUser(userId: String)
    case particularUserCollection(userId: String)
    case privateSpot(spotId: String)
}

extension Endpoint {
    var userId: String {
        guard let currentUser = AuthService.getCurrentUser() else {
            return "unknown user"
        }
        return currentUser.uid
    }
    
    var path: String {
        switch self {
        case .user:
            return "users"
        case .currentUser:
            return "users/\(userId)"
        case .spot:
            return "users/\(userId)/spots"
        case .publicCollection:
            return "spots"
        case let .favorite(spotId):
            return "users/\(userId)/favorites/\(spotId)"
        case let .publicSpot(spotId):
            return "spots/\(spotId)"
        case .favoriteCollection:
            return "users/\(userId)/favorites"
        case let .favoriteSpot(spotId):
            return "users/\(userId)/favorites/\(spotId)"
        case let .particularUser(userId):
            return "users/\(userId)"
        case let .particularUserCollection(userId):
            return "users/\(userId)/spots"
        case let .privateSpot(spotId):
        return "users/\(userId)/spots/\(spotId)"
        }
    }
}
