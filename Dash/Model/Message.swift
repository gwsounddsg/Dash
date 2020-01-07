// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/7/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import Foundation





struct Message {
    let address: String
    let values: [Float]
    
    init(_ address: String, _ values: [Float]) {
        self.address = address
        self.values = values
    }
}
