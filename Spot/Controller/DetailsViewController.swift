//
//  DetailsViewController.swift
//  GoogleMapTest
//
//  Created by MacBook DS on 02/10/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class DetailsViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var button: UIButton!
    
    
    var passedData = Spot()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getImage()
        label.text = passedData.title
        print(label.text as Any)

    }
    
    func getImage() {
        guard let urlString = passedData.imageURL else {return}
        
        guard let url = URL(string: urlString) else {return}
        
        KingfisherManager.shared.retrieveImage(with: url, options: nil) { result in

        let image = try? result.get().image
        
        if let image = image {
            self.imageView.image = image
    }
    
    
        }
    }
    
    @IBAction func remove(_ sender: Any) {
        passedData.map = nil
        goToMapView()
    }
   
    
    @objc func goToMapView() {
          self.dismiss(animated: true, completion: nil)
      }
}
