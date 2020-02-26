//
//  AuthenticationService.swift
//  Spot
//
//  Created by MacBook DS on 30/10/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import Foundation
import Firebase

final public class AuthService {
    
    static func getCurrentUser() -> User? {
        let currentUser = Auth.auth().currentUser
        
        if let currentUser = currentUser {
            return currentUser
        } else {
            return nil
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping AuthDataResultCallback) {
        Auth.auth().createUser(withEmail: email, password: password, completion: completion)
    }
    
    func signIn(email: String, password: String, completion: @escaping AuthDataResultCallback) {
        Auth.auth().signIn(withEmail: email, password: password, completion: completion)
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    
    func resetPassword(email: String, completion: @escaping AuthDataResultCallback) {
        Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func resetMyPassword(email: String, onSucess: @escaping () -> Void, onError: @escaping (_ errorMessage: String) -> Void ) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error == nil {
                onSucess()
            } else {
                onError(error!.localizedDescription)
            }
        }
    }
  
}
