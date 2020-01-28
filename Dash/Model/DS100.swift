// ===================================================
// Created by:  GW Rodriguez
// Date:        12/24/19
// Copyright:   Copyright © 2019 GW Rodriguez. All rights reserved.
// ===================================================

import Foundation





struct DS100: Equatable {
    let mapping: String
    let input: String
    let x: Float
    let y: Float
    let spread: Float
    
    
    init(_ mapping: String, input: String, x: Float, y: Float, spread: Float) {
        self.mapping = mapping
        self.input = input
        self.x = x
        self.y = y
        
        if spread < 0.0 {
            self.spread = 0.0
        }
        else if spread > 1.0 {
            self.spread = 1.0
        }
        else {
            self.spread = spread
        }
    }
    
    
    func coordinate() -> String {
        return "/dbaudio1/coordinatemapping/source_position_xy/\(mapping)/\(input)"
    }
    
    
    func sourceSpread() -> String {
        return "/dbaudio1/positioning/source_spread/\(input)"
    }
    
    
    func coordinateX() -> String {
        return "/dbaudio1/coordinatemapping/source_position_x/\(mapping)/\(input)"
    }
    
    
    func coordinateY() -> String {
        return "/dbaudio1/coordinatemapping/source_position_y/\(mapping)/\(input)"
    }
}
