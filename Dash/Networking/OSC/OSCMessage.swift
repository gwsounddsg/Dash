//
// Created by GW Rodriguez on 11/16/22.
// Copyright (c) 2022 GW Rodriguez. All rights reserved.
//

import Foundation

public struct OSCMessage {
    public var address: String = ""
    public var arguments: [OSCType?] = []

    init() {}

    init(_ address: String, _ arguments: [OSCType]) {
        self.address = address
        self.arguments = arguments
    }
}