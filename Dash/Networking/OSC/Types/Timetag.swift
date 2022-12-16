//
// Created by GW Rodriguez on 12/16/22.
// Copyright (c) 2022 GW Rodriguez. All rights reserved.
//

import Foundation

public typealias Timetag = UInt64



extension Timetag: OSCType {
    public var tag: OSCTag {
        get { return .time }
    }


    public var data: Data {
        get {
            var int = self.bigEndian
            let buffer = UnsafeBufferPointer(start: &int, count: 1)
            return Data(buffer: buffer)
        }
    }


    public var secondsSince1900: Double {
        get {
            return Double(self / 0x1_0000_0000)
        }
    }


    public var secondsSinceNow: Double {
        get {
            if self > 0 {
                return Double((self - Date().oscTime) / 0x1_0000_0000)
            }
            else {
                return 0.0
            }
        }
    }


    public init(secondsSince1900 seconds: Double) {
        self = Date().oscTime
        self += UInt64(seconds * 0x1_0000_0000)
    }


    public init(secondsSinceNow seconds: Double) {
        self = UInt64(seconds * 0x1_0000_0000)
    }
}