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
    
    func height(width: CGFloat, font: UIFont) -> CGFloat {
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        let rect = self.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(rect.height)
    }
    
    func width(height: CGFloat, font: UIFont) -> CGFloat {
        let size = CGSize(width: .greatestFiniteMagnitude, height: height)
        let rect = self.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(rect.width)
    }
    
    func width(width: CGFloat, font: UIFont) -> CGFloat {
        let size = CGSize(width: width, height: .greatestFiniteMagnitude)
        let rect = self.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        return ceil(rect.width)
    }
}
