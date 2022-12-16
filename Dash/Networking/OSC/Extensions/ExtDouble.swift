//
// Created by GW Rodriguez on 12/16/22.
// Copyright (c) 2022 GW Rodriguez. All rights reserved.
//

import Foundation

extension Double: OSCType {
    public var tag: OSCTag {
        get { return .float }
    }

    public var data: Data {
        let bytes: [UInt8] = withUnsafeBytes(of: Float(self.bitPattern.bigEndian), Array.init)
        return Data(bytes)
    }
}