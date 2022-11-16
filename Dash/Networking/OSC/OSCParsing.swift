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


private func getAddress(_ data: Data) -> String {
    let addressEnd = data.firstIndex(of: 0x00)!
    guard let address = data.subdata(in: 0..<addressEnd).toString() else {return ""}

    return address
}


private func isAddressValid(_ address: String) -> Bool {
    if address == "" {return false}
    if address.first != "/" {return false}
    if address.range(of: "/{3,}", options: .regularExpression) != nil {return false} // check for double "//"
    if address.range(of: "\\s", options: .regularExpression) != nil {return false} // no spaces

    // '[' must be close, no invalid characters inside
    if address.range(of: "\\[(?![^\\[\\{\\},?\\*/]+\\])", options: .regularExpression) != nil {return false}

    var open = address.components(separatedBy: "[").count
    var close = address.components(separatedBy: "]").count
    if open != close {return false}

    //{ must be closed, no invalid characters inside
    if address.range(of: "\\{(?![^\\{\\[\\]?\\*/]+\\})", options: .regularExpression) != nil {return false}

    open = address.components(separatedBy: "{").count
    close = address.components(separatedBy: "}").count
    if open != close {return false}

    //"," only inside {}
    if address.range(of: ",(?![^\\{\\[\\]?\\*/]+\\})", options: .regularExpression) != nil {return false}
    if address.range(of: ",(?<!\\{[^\\{\\[\\]?\\*/]+)", options: .regularExpression) != nil {return false}

    return true
}