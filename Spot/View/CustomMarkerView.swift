//
//  CustomMarkerView.swift
//  GoogleMapTest
//
//  Created by MacBook DS on 02/10/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import Foundation
import UIKit

class CustomMarkerView: UIView {
    
    // MARK: - Properties
    
    var img: UIImage!
    var borderColor: UIColor!
    
    init(frame: CGRect, image: UIImage, borderColor: UIColor) {
        super.init(frame: frame)
        self.img = image
        self.borderColor = borderColor
        self.tag = tag
        setupViews()
    }
    
    // MARK: - Methods
    
    func setupViews() {
        let imgView = UIImageView(image: img)
        imgView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        imgView.layer.cornerRadius = 15
        imgView.layer.borderColor = borderColor?.cgColor
        imgView.layer.borderWidth = 2
        imgView.clipsToBounds = true
        let lbl = UILabel(frame: CGRect(x: 0, y: 45, width: 50, height: 10))
        lbl.text = "▾"
        lbl.font = UIFont.systemFont(ofSize: 24)
        lbl.textColor = borderColor
        lbl.textAlignment = .center
        self.addSubview(imgView)
        self.addSubview(lbl)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

