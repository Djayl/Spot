//
//  DocumentSerializableProtocol.swift
//  Spot
//
//  Created by MacBook DS on 06/11/2019.
//  Copyright © 2019 Djilali Sakkar. All rights reserved.
//

import Foundation


public protocol DocumentSerializableProtocol {
    init?(dictionary: [String: Any])
}
