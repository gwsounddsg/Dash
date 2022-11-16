//
// Created by GW Rodriguez on 11/16/22.
// Copyright (c) 2022 GW Rodriguez. All rights reserved.
//

import Foundation


func OSCParse(_ rawData: Data) throws -> OSCMessage {
    // get address

    // get arguments

    // build OSCMessage and Return
    return OSCMessage()
}


private func getAddress(_ rawData: Data) -> String {
    var address = ""
    var data = rawData

    let addressEnd = data.firstIndex(of: 0x00)!
    guard let addressString = data.subdata(in: 0..<addressEnd).toString() else {return address}

    return address
}