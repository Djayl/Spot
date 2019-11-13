//
//  FirestoreService.swift
//  Spot
//
//  Created by MacBook DS on 06/11/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import Foundation
import FirebaseFirestore

public enum FirestoreError: Error {
    case offline
}

public protocol FirestoreRequest {
    associatedtype FirestoreObject: DocumentSerializableProtocol
    typealias FirestoreCollectionResult<FirestoreObject: DocumentSerializableProtocol> = Result<[FirestoreObject], FirestoreError>
    typealias FirestoreDocumentResult<FirestoreObject: DocumentSerializableProtocol> = Result<FirestoreObject, FirestoreError>
    typealias FirestoreUpdateResult = Result<String, FirestoreError>
    
    func fetchCollection(endpoint: Endpoint, result: @escaping (FirestoreCollectionResult<FirestoreObject>) -> Void)
    func fetchDocument(endpoint: Endpoint, result: @escaping (FirestoreDocumentResult<FirestoreObject>) -> Void)
    func saveData(endpoint: Endpoint, identifier: String, data: [String: Any], result: @escaping (FirestoreUpdateResult) -> Void)
    func deleteDocumentData(endpoint: Endpoint, identifier: String, result: @escaping (FirestoreUpdateResult) -> Void)
    func updateData(endpoint: Endpoint, data: [String: Any], result: @escaping (FirestoreUpdateResult) -> Void)
}

final public class FirestoreService<FirestoreObject: DocumentSerializableProtocol>: FirestoreRequest {
    
    // MARK: - Properties
    
    private var dataBase = Firestore.firestore()
    private var collection: CollectionReference?
    private var document: DocumentReference?
    
    // MARK: - Init
    
    init() {
        let settings = dataBase.settings
//        settings.areTimestampsInSnapshotsEnabled = true
        dataBase.settings = settings
    }
    
    // MARK: - Methods
    
    /// Fetch an array of Firestore Object from a collection in Firestore BDD and parse it into a Swift object
    ///
    /// - Parameter endpoint: The endpoint where to fetch collection in Firestore BDD
    /// - Parameter result: A result type to make action when it's success or failure
    public func fetchCollection(endpoint: Endpoint, result: @escaping (FirestoreCollectionResult<FirestoreObject>) -> Void) {
        collection = dataBase.collection(endpoint.path)
        collection?.order(by: "creationDate", descending: true).getDocuments(completion: { (querySnapshot, error) in
            if error != nil {
                result(.failure(.offline))
            }
            
            guard let objectData = querySnapshot else {
                result(.failure(.offline))
                return
            }
            let object = objectData.documents.compactMap({FirestoreObject(dictionary: $0.data())})
            result(.success(object))
        })
    }
    
    public func fetchCoco(endpoint: Endpoint, result: @escaping (FirestoreCollectionResult<FirestoreObject>) -> Void) {
        collection = dataBase.collection(endpoint.path)
        collection?.addSnapshotListener({ (querySnapshot, error) in
            if error != nil {
                result(.failure(.offline))
            }
            guard let objectData = querySnapshot else {
                result(.failure(.offline))
                return
            }
  
            let object = objectData.documents.compactMap({FirestoreObject(dictionary: $0.data())})
            result(.success(object))
        })
    }
    
    /// Fetch a Firestore Object from a document in Firestore BDD and parse it into a Swift object
    ///
    /// - Parameter endpoint: The endpoint where to fetch document in Firestore BDD
    /// - Parameter result: A result type to make action when it's success or failure
    public func fetchDocument(endpoint: Endpoint, result: @escaping (FirestoreDocumentResult<FirestoreObject>) -> Void) {
        document = dataBase.document(endpoint.path)
        document?.getDocument(completion: { (documentSnapshot, error) in
            if error != nil {
                result(.failure(.offline))
            }
            
            guard let objectData = documentSnapshot, objectData.exists else {
                result(.failure(.offline))
                return
            }
            guard let object = objectData.data().map({FirestoreObject(dictionary: $0)}) as? FirestoreObject else { return }
            result(.success(object))
        })
    }
    
    /// Save data in a Firestore Document
    ///
    /// - Parameter endpoint: The endpoint where to save document in Firestore BDD
    /// - Parameter result: A result type to make action when it's success or failure
    public func saveData(endpoint: Endpoint, identifier: String, data: [String: Any], result: @escaping (FirestoreUpdateResult) -> Void) {
        collection = dataBase.collection(endpoint.path)
        collection?.document(identifier).setData(data, completion: { (error) in
            if let error = error {
                print("Error adding document: \(error)")
                result(.failure(.offline))
            } else {
                result(.success("Document added with success"))
            }
        })
    }
    
    /// Delete document in a Firestore BDD
    ///
    /// - Parameter endpoint: The endpoint where to delete document in Firestore BDD
    /// - Parameter result: A result type to make action when it's success or failure
    public func deleteDocumentData(endpoint: Endpoint, identifier: String, result: @escaping (FirestoreUpdateResult) -> Void) {
        collection = dataBase.collection(endpoint.path)
        collection?.document(identifier).delete(completion: { error in
            if let error = error {
                print("Error deleting document: \(error)")
                result(.failure(.offline))
            } else {
                result(.success("Document deleted with success"))
            }
        })
    }
    
    /// Update document in a Firestore BDD
    ///
    /// - Parameter endpoint: The endpoint where to update document in Firestore BDD
    /// - Parameter result: A result type to make action when it's success or failure
    public func updateData(endpoint: Endpoint, data: [String: Any], result: @escaping (FirestoreUpdateResult) -> Void) {
        document = dataBase.document(endpoint.path)
        document?.updateData(data, completion: { error in
            if let error = error {
                print("Error updating document: \(error)")
                result(.failure(.offline))
            } else {
                result(.success("Document updated with success"))
            }
        })
    }
}
