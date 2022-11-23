//
// Created by GW Rodriguez on 11/18/22.
// Copyright (c) 2022 GW Rodriguez. All rights reserved.
//

import Foundation

extension Int: OSCType {
    public var tag: OSCTag {
        get { return .int }
    }

    public var data: Data {
        get {
            let bytes: [UInt8] = withUnsafeBytes(of: Int32(self).bigEndian, Array.init)
            return Data(bytes)
        }
    }

    init (_ data: Data) {
        self = Int(data.withUnsafeBytes { $0.load(fromByteOffset: 0, as: Int32.self).bigEndian })
    }
}