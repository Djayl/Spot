//
//  String.swift
//  Spot
//
//  Created by MacBook DS on 19/11/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import UIKit

extension String {
    func toNoSmartQuotes() -> String {
        let userInput: String = self
        return userInput.folding(options: .diacriticInsensitive, locale: .current)
    }
        func isEmptyOrWhitespace() -> Bool {
            if(self.isEmpty) {
                return true
            }
            return (self.trimmingCharacters(in: NSCharacterSet.whitespaces) == "")
        }
}
