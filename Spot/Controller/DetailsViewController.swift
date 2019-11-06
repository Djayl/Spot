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

class DetailsViewController: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var pictureTakerName: UILabel!
    @IBOutlet weak var spotTitle: UILabel!
    @IBOutlet weak var spotDescription: UILabel!
    @IBOutlet weak var spotDate: UILabel!
    @IBOutlet weak var spotCoordinate: UILabel!
    @IBOutlet weak var favoriteButton: FavoriteButton!
    
    
    var gradient: CAGradientLayer?
    var spot = Spot()
    var newImageView = UIImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getSpotDetails()
        getImage()
        reverseGeocodeCoordinate(spot.position)
        addGradient()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(_:)))
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.imageView.addGestureRecognizer(tapGestureRecognizer)
        self.imageView.isUserInteractionEnabled = true
        spotDescription.setUpLabel()
        spotDate.setUpLabel()
        spotCoordinate.setUpLabel()
        spotTitle.setUpLabel()
        handleFavoriteButton()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        getImage()
    }
    
           override func viewWillAppear(_ animated: Bool) {
                super.viewWillAppear(true)
            // Show the Navigation Bar
                    self.navigationController?.setNavigationBarHidden(true, animated: false)

                }
    
    
    
    //    override func viewWillAppear(_ animated: Bool) {
    //        super.viewWillAppear(true)
    //        getImage()
    //    }
    
    func getUserName() {
        
    }
    @IBAction func putSpotToFavorite(_ sender: Any) {
        addToFavorite()
    }
    
    @objc func scaleImage(_ sender: UIPinchGestureRecognizer) {
        if let view = sender.view {
            
            switch sender.state {
            case .changed:
                let pinchCenter = CGPoint(x: sender.location(in: view).x - view.bounds.midX,
                                          y: sender.location(in: view).y - view.bounds.midY)
                let transform = view.transform.translatedBy(x: pinchCenter.x, y: pinchCenter.y)
                    .scaledBy(x: sender.scale, y: sender.scale)
                    .translatedBy(x: -pinchCenter.x, y: -pinchCenter.y)
                newImageView.transform = transform
                sender.scale = 1
            case .ended:
                // Nice animation to scale down when releasing the pinch.
                // OPTIONAL
                UIView.animate(withDuration: 0.2, animations: {
                    view.transform = CGAffineTransform.identity
                })
            default:
                return
            }

        }
        //        if sender.state == .ended || sender.state == .changed {
        //
        //               let currentScale = sender.view!.frame.size.width / sender.view!.bounds.size.width
        //               var newScale = currentScale*sender.scale
        //
        //               if newScale < 1 {
        //                   newScale = 1
        //               }
        //               if newScale > 7 {
        //                   newScale = 7
        //               }
        //
        //               let transform = CGAffineTransform(scaleX: newScale, y: newScale)
        //
        //               self.newImageView.transform = transform
        //               sender.scale = 1
        //
        //           }
    }
    
    
    //    private func getDate() {
    //        guard let uid = Auth.auth().currentUser?.uid else {return}
    //        FirestoreReferenceManager.referenceForUserPublicData(uid: uid).collection("Spots").getDocuments { (querySnapshot, error) in
    //            if let error = error {
    //                print("Error getting documents: \(error)")
    //            } else {
    //                for document in querySnapshot!.documents {
    //                    let creationDate = document.get("createdAt") as? String
    //                    self.spotDate.text = creationDate
    //    }
    //            }
    //        }
    //    }
    
    fileprivate func handleFavoriteButton() {
        let favorite = (spot.userData as! CustomData).isFavorite
        print(favorite)
        
        if favorite == "Yes" {
            favoriteButton.isOn = false
        } else {
            favoriteButton.isOn = true
        }
    }
    
    func getSpotDetails() {
        
        
        guard let name = spot.title else {return}
        spotTitle.text = name.uppercased().toNoSmartQuotes()
        
        guard let description = spot.snippet, description.isEmpty == false else {
            spotDescription.text = "Aucune description n'a été rédigée pour ce Spot"
            return }
        spotDescription.text = description
        let date  = (spot.userData as! CustomData).creationDate
        spotDate.text = date.asString(style: .short)
        
        //        handleFavoriteButton()
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
    
    private func addToFavorite() {
        let uid = Auth.auth().currentUser?.uid
        let spotUid = (spot.userData as! CustomData).uid
        let ref = FirestoreReferenceManager.referenceForUserPublicData(uid: uid!).collection("Spots").document(spotUid)
        
//        switch favoriteButton.isOn {
        favoriteButton.isOn.toggle()
//        case true:
//            favoriteButton.isOn = false
        if favoriteButton.isOn {
            ref.updateData(["isFavorite": "No"]) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                print("Succesfully UnFavorite")
            }
            } else {
//            }
//        case false:
//            favoriteButton.isOn = true
            ref.updateData(["isFavorite": "Yes"]) { (error) in
                if let error = error {
                    print(error.localizedDescription)
                }
                print("Succesfully favorite")
            }
            }
//        }
    
    }
    
    
    @objc func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as! UIImageView
        newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .white
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(scaleImage(_:)))
        newImageView.addGestureRecognizer(pinch)
//        self.view.addSubview(newImageView)
        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            self.view.addSubview(self.newImageView)
        }, completion: nil)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        UIView.transition(with: self.view, duration: 0.25, options: [.transitionCrossDissolve], animations: {
            sender.view?.removeFromSuperview()
        }, completion: nil)

    }
    
     func addGradient() {
            gradient = CAGradientLayer()
    //        let startColor = UIColor(red: 3/255, green: 196/255, blue: 190/255, alpha: 1)
    //        let endColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        gradient?.colors = [Colors.skyBlue.cgColor, UIColor.white]
            gradient?.startPoint = CGPoint(x: 0, y: 0)
            gradient?.endPoint = CGPoint(x: 0, y:1)
            gradient?.frame = view.frame
            self.view.layer.insertSublayer(gradient!, at: 0)
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

extension UILabel {
    func setUpLabel() {
        layer.cornerRadius = 10
        self.clipsToBounds = true
    }
}

extension Date {
    func asString(style: DateFormatter.Style) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = style
        return dateFormatter.string(from: self)
    }
}
