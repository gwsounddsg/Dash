//
// Created by GW Rodriguez on 11/18/22.
// Copyright (c) 2022 GW Rodriguez. All rights reserved.
//

import Foundation

extension UInt32 {
    var data: Data {
        var int = self
        return Data(bytes: &int, count: MemoryLayout<UInt32>.size)
    }
}