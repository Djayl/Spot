//
//  FirebaseServiceSpy.swift
//  SpotTests
//
//  Created by MacBook DS on 23/11/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//
//import XCTest
//import Foundation
//import Firebase
//@testable import Spot
//
//enum MoviesError: Error {
//    case offline
//}
//enum Issue {
//    case success(ImageData)
//    case failure(MoviesError)
//}
//
//struct ImageData: Equatable {
//    let name: String
//}
//
//
//class FirebaseServiceSpy {
//    
//    var message: ((Issue) -> Void)?
//    
//    func uploadImageData(result: @escaping (Issue) -> Void) {
//        message = result
//    }
//    func completeGetmoviesSuccessfullyWith(image: ImageData) {
//        message?(.success(image))
//    }
//    func completeGetMoviesWithOfflineError() {
//        message?(.failure(.offline))
//    }
//}
//
//class FirebaseServiceTests: XCTestCase {
//    
//
//func testuploadImageDataSuccess() {
//    let image = ImageData(name: "test")
//    
//    let sut = FirebaseServiceSpy()
//    
//    let exp = expectation(description: "wait for load completion")
//    
//    sut.uploadImageData { result in
//        switch result {
//        case let .success(receivedMovies):
//            XCTAssertEqual(receivedMovies, image)
//        case .failure(.offline):
//            XCTFail("Should be success), got \(result) instead")
//        }
//        exp.fulfill()
//    }
//    sut.completeGetmoviesSuccessfullyWith(image: image)
//    
//    wait(for: [exp], timeout: 1.0)
//}
//
//}
