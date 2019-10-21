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

class DetailsViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pictureTakerName: UILabel!
    @IBOutlet weak var pictureTakerAvatar: UIImageView!
    @IBOutlet weak var spotTitle: UILabel!
    @IBOutlet weak var spotDescription: UILabel!
    @IBOutlet weak var spotDate: UILabel!
    @IBOutlet weak var spotCoordinate: UILabel!
    
    
    var spot = Spot()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSpot()
        setupAvatarImageView()
        
        

    }
    
    func getSpot() {
        guard let name = spot.name else {return}
        spotTitle.text = name
        guard let description = spot.summary else {return}
        spotDescription.text = description
        guard let coordinate = spot.coordinate else {return}
        spotCoordinate.text = "\(coordinate)"
        guard let urlString = spot.imageURL else {return}
        
        guard let url = URL(string: urlString) else {return}
        
        KingfisherManager.shared.retrieveImage(with: url, options: nil) { result in

        let image = try? result.get().image
        
        if let image = image {
            self.imageView.image = image
    }
    
    
        }
    }
    
    private func setupAvatarImageView() {
        pictureTakerAvatar.layer.cornerRadius = (pictureTakerAvatar.frame.size.width ) / 2
        pictureTakerAvatar.clipsToBounds = true
        pictureTakerAvatar.layer.borderWidth = 3.0
        pictureTakerAvatar.layer.borderColor = UIColor.white.cgColor
    }
    
    @IBAction func remove(_ sender: Any) {
        spot.map = nil
        goToMapView()
    }
   
    
    @objc func goToMapView() {
          self.dismiss(animated: true, completion: nil)
      }
}
