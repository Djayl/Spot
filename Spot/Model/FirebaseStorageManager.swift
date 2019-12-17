//
//  FirebaseService.swift
//  Spot
//
//  Created by MacBook DS on 21/11/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import FirebaseFirestore
import Firebase
import FirebaseStorage

class FirebaseStorageManager {
    
    // MARK: - Methods
    
    public func uploadFile(localFile: URL, serverFileName: String, completionHandler: @escaping (_ isSuccess: Bool, _ url: String?) -> Void) {
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        // Create a reference to the file you want to upload
        let directory = "imagesFolder/"
        let fileRef = storageRef.child(directory + serverFileName)
        
        _ = fileRef.putFile(from: localFile, metadata: nil) { metadata, error in
            fileRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    completionHandler(false, nil)
                    return
                }
                // File Uploaded Successfully
                completionHandler(true, downloadURL.absoluteString)
            }
        }
    }
    
    public func uploadImageData(data: Data, serverFileName: String, completionHandler: @escaping (_ isSuccess: Bool, _ url: String?) -> Void) {
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        // Create a reference to the file you want to upload
        let directory = "imagesFolder/"
        let fileRef = storageRef.child(directory + serverFileName)
        
        _ = fileRef.putData(data, metadata: nil) { metadata, error in
            fileRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    completionHandler(false, nil)
                    return
                }
                // File Uploaded Successfully
                completionHandler(true, downloadURL.absoluteString)
            }
        }
    }
    
    public func deleteImageData(serverFileName: String) {
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        // Create a reference to the file you want to upload
        let directory = "imagesFolder/"
        let fileRef = storageRef.child(directory + serverFileName)
        
        fileRef.delete { (error) in
            if let error = error {
                print("Error removing document: \(error)")
            } else {
                print("Document successfully removed!")
            }
        }
    }
}


