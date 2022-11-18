//
// Created by GW Rodriguez on 11/16/22.
// Copyright (c) 2022 GW Rodriguez. All rights reserved.
//

import Foundation

extension Data {
    func toString() -> String? {
        return String(data: self, encoding: .utf8)
    }


    func toInt32() -> Int32 {
        var int = Int32();
        let buffer = UnsafeMutableBufferPointer(start: &int, count: 1)
        _ = self.copyBytes(to: buffer)
        return int.byteSwapped
    }
}