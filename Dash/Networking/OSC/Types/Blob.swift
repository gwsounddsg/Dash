//
// Created by GW Rodriguez on 11/18/22.
// Copyright (c) 2022 GW Rodriguez. All rights reserved.
//

import Foundation

public typealias Blob = Data


extension Blob: OSCType {
    public var tag: OSCTag {
        get { return .blob }
    }


    public var data: Data {
        get {
            let length = UInt32(self.count)
            var data = Data()

            data.append(length.data)
            data.append(self)

            while data.count % 4 != 0 {
                var null = UInt8(0)
                data.append(&null, count: 1)
            }

            return data
        }
    }


    init(_ data: Data) {
        self = data
    }
}