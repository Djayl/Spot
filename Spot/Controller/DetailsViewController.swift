//
//  DetailsViewController.swift
//  Spot
//
//  Created by MacBook DS on 02/10/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher
import GoogleMaps

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pictureTakerName: UILabel!
    @IBOutlet weak var spotTitle: UILabel!
    @IBOutlet weak var spotDescription: UILabel!
    @IBOutlet weak var spotDate: UILabel!
    @IBOutlet weak var spotCoordinate: UILabel!
    
    
    var spot = Spot()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSpot()
        getImage()
        reverseGeocodeCoordinate(spot.position)
        //        spotTitle.text = spot.title
        
        //        setupAvatarImageView()
      
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))

        self.imageView.addGestureRecognizer(tapGestureRecognizer)
        self.imageView.isUserInteractionEnabled = true
        
    }
    
    func getUserName() {
        
    }
    
    func getSpot() {
        guard let name = spot.title else {return}
        spotTitle.text = name.uppercased()
        guard let summary = spot.summary else {return}
        spotDescription.text = summary
//        let lat = spot.position.latitude
//        let lon = spot.position.longitude
//        print(lat)
//        print(lon)
//        spotCoordinate.text = "\(lat)"
    }
    
    func getImage() {
        
        guard let urlString = spot.imageURL else {return}
        
        guard let url = URL(string: urlString) else {return}
        
        KingfisherManager.shared.retrieveImage(with: url, options: nil) { result in
            
            let image = try? result.get().image
            
            if let image = image {
                self.imageView.image = image
            }
      
        }
    }
    
    func reverseGeocodeCoordinate(_ coordinate: CLLocationCoordinate2D) {
       
          let geocoder = GMSGeocoder()
       
        geocoder.reverseGeocodeCoordinate(coordinate) { response, error in
            guard let address = response?.firstResult(), let lines = address.lines else {
              return
            }
    
            self.spotCoordinate.text = lines.joined(separator: "\n")
              
          }
        }
    
        @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .white
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }

    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
  
    
    
    @IBAction func remove(_ sender: Any) {
        spot.map = nil
        goToMapView()
    }
    
    
    @objc func goToMapView() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension UIImageView{
    
    func makeRounded() {
        self.layer.cornerRadius = self.frame.size.width / 2
        self.clipsToBounds = true
    }
    
}
