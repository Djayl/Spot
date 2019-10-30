//
//  FirebaseReferenceManager.swift
//  Spot
//
//  Created by MacBook DS on 17/09/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import Firebase

struct FirestoreReferenceManager {
    
    static let environment = "dev"
    static let db = Firestore.firestore()
    static let root = db.collection(environment).document(environment)
    
    static func referenceForUserPublicData(uid: String) -> DocumentReference {
        return root
            .collection(FirebaseKeys.CollectionPath.users)
            .document(uid)
            .collection(FirebaseKeys.CollectionPath.publicData)
            .document(FirebaseKeys.CollectionPath.publicData)
        
    }
}
