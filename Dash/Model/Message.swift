// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/7/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import Foundation
import SwiftOSC


typealias DashData = OSCType





struct Message {
    let address: String
    let values: [DashData]
    
    init(_ address: String, _ values: [DashData]) {
        self.address = address
        self.values = values
    }
}
