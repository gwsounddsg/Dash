//
// Created by GW Rodriguez on 1/21/20.
// Copyright (c) 2020 GW Rodriguez. All rights reserved.
//

import Foundation





struct Vezer: Equatable {
    
    let name: String
    let x: Double
    let y: Double
    
    
    init(_ name: String, _ x: Double, _ y: Double) {
        self.name = name
        self.x = x
        self.y = y
    }
    
    
    func addy() -> (x: String, y: String) {
        let prefix = "/trackable/\(name)/"
        return (x: prefix + "x", y: prefix + "y")
    }
}