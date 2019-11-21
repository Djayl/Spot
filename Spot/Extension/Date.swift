//
//  Date.swift
//  Spot
//
//  Created by MacBook DS on 20/11/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import Foundation

extension Date {
    func asString(style: DateFormatter.Style) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = style
        return dateFormatter.string(from: self)
    }
}
