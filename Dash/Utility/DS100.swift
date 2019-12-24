// ===================================================
// Created by:  GW Rodriguez
// Date:        12/24/19
// Copyright:   Copyright © 2019 GW Rodriguez. All rights reserved.
// ===================================================

import Foundation





struct DS100 {
    let mapping: String
    let input: String
    let x: Double
    let y: Double
    
    
    init(_ mapping: String, input: String, x: Double, y: Double) {
        self.mapping = mapping
        self.input = input
        self.x = x
        self.y = y
    }
    
    func addy() -> String {
        return "\(mapping)/\(input)"
    }
}
