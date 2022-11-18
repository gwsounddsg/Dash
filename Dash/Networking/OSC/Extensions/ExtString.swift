//
// Created by GW Rodriguez on 11/18/22.
// Copyright (c) 2022 GW Rodriguez. All rights reserved.
//

import Foundation

extension String: OSCType {
    public var data: Data {
        get {
            var data = self.data(using: .utf8)!

            for _ in 1...(4 - data.count%4) {
                var null = UInt8(0)
                data.append(&null, count: 1)
            }

            return data
        }
    }

    init(_ data: Data) {
        self = String(data: data, encoding: .utf8)!
    }


    func toBase32() -> Data {
        var data = self.data(using: .utf8)!
        var val: UInt8 = 0

        for _ in 1...(4 - (data.count % 4)) {
            data.append(&val, count: 1)
        }

        return data
    }
}