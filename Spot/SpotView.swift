//
//  SpotView.swift
//  Spot
//
//  Created by MacBook DS on 16/09/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import Foundation
import MapKit


class SpotView: MKAnnotationView {
    
    var controller: SpotViewController?
    
    init(controller: SpotViewController, annotation: MKAnnotation?, reuseIdentifier: String?) {
        self.controller = controller
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupAnnotation()
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupAnnotation()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupAnnotation()
    }
    
    func setupAnnotation() {
        image = UIImage(named: "map-marker")
        canShowCallout = true
        calloutOffset = CGPoint(x: -5, y: 5)
        rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        detailCalloutAccessoryView = setupCenter()
    }
    
    
    func setupCenter() -> UIView? {
        guard let anno = annotation as? Spot else { return nil}
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 125, height: 125))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.widthAnchor.constraint(equalToConstant: 125).isActive = true
        view.heightAnchor.constraint(equalToConstant: 125).isActive = true
        
        let imageView = UIImageView(frame: view.bounds)
        imageView.image = anno.image
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        view.addSubview(imageView)
        
        return view
    }
    
    
}
