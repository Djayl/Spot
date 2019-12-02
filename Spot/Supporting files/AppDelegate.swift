//
//  AppDelegate.swift
//  Spot
//
//  Created by MacBook DS on 10/09/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Firebase

let googleApiKey = "AIzaSyAr9KfQyhGZKpzXAHhd0_PHzzXQR4br6yA"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GMSServices.provideAPIKey(googleApiKey)
        GMSPlacesClient.provideAPIKey(googleApiKey)
        FirebaseApp.configure()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        window = UIWindow()
        self.window?.rootViewController = storyboard.instantiateInitialViewController()
        self.window?.makeKeyAndVisible()
        
        return true
    }




}

