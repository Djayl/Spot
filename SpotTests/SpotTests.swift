//
//  SpotTests.swift
//  SpotTests
//
//  Created by MacBook DS on 15/11/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import XCTest
import Firebase
@testable import Spot

class SpotTests: XCTestCase {
    
    let authService = AuthService()

    override func setUp() {
        authService.signIn(email: "unitTests@test.fr", password: "azerty") { (_, error) in
            if error != nil {
                print("Fail")
            }
        }
    }

    override func tearDown() {
        do {
            try authService.signOut()
        } catch let error {
            print(error.localizedDescription)
        }
    }
  

    func testFetchCollectionSuccessfully() {
        let firestoreServiceSpy = FirestoreServiceSpy<Marker>()

        let marker = Marker(identifier: "EB9CF9CA-73E6-460C-9641-A620FC311FD2", name: "test", description: "test", coordinate: GeoPoint(latitude: 2.0, longitude: 2.0) , imageURL: "test", ownerId: "test",publicSpot: true, creatorName: "test" ,creationDate: Date())
        let markers = [marker]
        
        let exp = expectation(description: "Wait for load completion")

        firestoreServiceSpy.fetchCollection(endpoint: .spot) { result in
            switch result {
            case .success(let receivedPrograms):
                XCTAssertEqual(receivedPrograms, markers)
            case .failure:
                XCTFail("Should be success, got \(result) instead")
            }
            exp.fulfill()
        }

        firestoreServiceSpy.fetchCollectionSuccessfullyWith(markers)

        wait(for: [exp], timeout: 1.0)
    }
    
    func testFetchCollectionWithOfflineError() {
        let firestoreServiceSpy = FirestoreServiceSpy<Marker>()
        
        let exp = expectation(description: "Wait for load completion")
        
        firestoreServiceSpy.fetchCollection(endpoint: .currentUser) { result in
            switch result {
            case .success:
                XCTFail("Should fail, got \(result) instead")
            case .failure(let receivedError):
                XCTAssertEqual(receivedError, .offline)
            }
            exp.fulfill()
        }
        
        firestoreServiceSpy.fetchCollectionWithOfflineError()
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func testFetchDocumentSuccessfully() {
        let firestoreServiceSpy = FirestoreServiceSpy<Profil>()
        let profil = Profil(identifier: "yblp54LyxzLYhFYqjP3e06AJxAv1", email: "unitTests@test.fr", userName: "Unit Tests")
        
        let exp = expectation(description: "Wait for load completion")
        
        firestoreServiceSpy.fetchDocument(endpoint: .currentUser) { result in
            switch result {
            case let .success(receivedProfil):
                XCTAssertEqual(receivedProfil, profil)
            case .failure(.offline):
                XCTFail("Should be success, got \(result) instead")
            }
            exp.fulfill()
        }
        firestoreServiceSpy.fetchDocumentSuccessfullyWith(profil)
        
        wait(for: [exp], timeout: 1.0)
    }
    
    func testFetchDocumentWithOfflineError() {
        let firestoreServiceSpy = FirestoreServiceSpy<Profil>()
        
        let exp = expectation(description: "Wait for load completion")
        
        firestoreServiceSpy.fetchDocument(endpoint: .currentUser) { result in
            switch result {
            case .success:
                XCTFail("Should fail, got \(result) instead")
            case .failure(let receivedError):
                XCTAssertEqual(receivedError, .offline)
            }
            exp.fulfill()
        }
        
        firestoreServiceSpy.fetchDocumentWithOfflineError()
        
        wait(for: [exp], timeout: 1.0)
    }
}




