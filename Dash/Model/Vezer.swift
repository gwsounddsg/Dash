//
// Created by GW Rodriguez on 1/21/20.
// Copyright (c) 2020 GW Rodriguez. All rights reserved.
//

import Foundation





struct Vezer {
    
    let name: String
    let x: Double
    let y: Double
    
    
    init(_ name: String, _ x: Double, _ y: Double) {
        self.name = name
        self.x = x
        self.y = y
    }
    
    
    func addy() -> String {
        return "/vezer/\(name)"
    }
}