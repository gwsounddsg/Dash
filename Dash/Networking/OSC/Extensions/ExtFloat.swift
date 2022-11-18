//
// Created by GW Rodriguez on 11/18/22.
// Copyright (c) 2022 GW Rodriguez. All rights reserved.
//

import Foundation

extension Float: OSCType {
    public var tag: OSCTag = .float
    public var data: Data {
        get {
            let bytes: [UInt8] = withUnsafeBytes(of: self.bitPattern.bigEndian, Array.init)
            return Data(bytes)
        }
    }

    init(_ data: Data) {
        self = Float(bitPattern: UInt32(bigEndian: data.withUnsafeBytes { $0.load(as: UInt32.self) }))
    }
}