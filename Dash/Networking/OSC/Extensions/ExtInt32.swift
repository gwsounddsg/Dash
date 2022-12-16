//
// Created by GW Rodriguez on 12/16/22.
// Copyright (c) 2022 GW Rodriguez. All rights reserved.
//

import Foundation

extension Int32 {
    func toData() -> Data {
        var int = self.bigEndian
        let buffer = UnsafeBufferPointer(start: &int, count: 1)
        return Data(buffer: buffer)
    }
}