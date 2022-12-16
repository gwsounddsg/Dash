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


    func getData() -> Data {
        var data = Data()

        // add address
        data.append(address.toBase32())

        // add types
        var types = ","
        if arguments.isEmpty {
            types += OSCTag.null.rawValue
        }
        else {
            for arg in arguments {
                types += arg!.tag.rawValue
            }
        }
        data.append(types.toBase32())

        // add arg(s)
        for arg in arguments {
            data.append(arg!.data)
        }

        return data
    }
}