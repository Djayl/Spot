//
//  UINavigationBar.swift
//  Spot
//
//  Created by MacBook DS on 26/01/2020.
//  Copyright © 2020 Djilali Sakkar. All rights reserved.
//

import UIKit

extension UINavigationBar {
    func changeFont() {
        self.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name:"Quicksand-Bold", size: 21)!]
    }
}
