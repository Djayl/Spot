//
//  Array.swift
//  Spot
//
//  Created by MacBook DS on 19/11/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit

extension Array where Element: Hashable {
    func removingDuplicates() -> [Element] {
        var addedDict = [Element: Bool]()
        
        return filter {
            addedDict.updateValue(true, forKey: $0) == nil
        }
    }
    
    mutating func removeDuplicates() {
        self = self.removingDuplicates()
    }
}
