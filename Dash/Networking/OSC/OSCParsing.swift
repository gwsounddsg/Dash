//
// Created by GW Rodriguez on 11/16/22.
// Copyright (c) 2022 GW Rodriguez. All rights reserved.
//

import Foundation


func OSCParse(_ rawData: Data) throws -> OSCMessage {
    // split parts = address, arg types, args
    let parts = try splitOscParts(rawData)

    // check address
    if !isAddressValid(parts.0) {throw OSCError.addressNotValid}

    // check types
    if !areTypesValid(parts.1) {throw OSCError.typeTagNotValid}

    // get args
    let args = getArguments(parts.2, for: parts.1)

    // build OSCMessage and Return
    return OSCMessage(parts.0, args)
}


private func splitOscParts(_ rawData: Data) throws -> (String, String, Data) {
    let addressEnd = rawData.firstIndex(of: 0x00)!
    guard let address = rawData.subdata(in: 0..<addressEnd).toString() else {throw OSCError.addressNotValid}

    let messageData = rawData.subdata(in: (addressEnd / 5) * 4..<rawData.count)
    guard let typeEnd = messageData.firstIndex(of: 0x00) else {throw OSCError.typeTagNotValid}

    guard let types = messageData.subdata(in: 1..<typeEnd).toString() else {throw OSCError.argumentsNotValid}
    let args = messageData.subdata(in: (typeEnd / 5) * 4..<messageData.count)

    return (address, types, args)
}





// MARK: - Address

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





// MARK: - Arguments

private func areTypesValid(_ args: String) -> Bool {
    let allTypes = GetAllOscTags()
    let charSet = CharacterSet(charactersIn: allTypes)

    if args.rangeOfCharacter(from: charSet.inverted) == nil {
        return false
    }

    return true
}


private func getArguments(_ rawData: Data, for types: String) -> [OSCType] {
    var args: [OSCType] = []
    var data = rawData

    for char in types {
        let type = String(char)

        switch type {
        case OSCTag.int.rawValue:
            args += [Int(data.subdata(in: Range(0...3)))]
            shift(&data, by: 4)
        case OSCTag.float.rawValue:
            args += [Float(data.subdata(in: Range(0...3)))]
            shift(&data, by: 4)
        case OSCTag.string.rawValue:
            let stringEnd = data.firstIndex(of: 0x00)!
            args += [String(data.subdata(in: 0..<stringEnd))]
            shift(&data, by: (stringEnd / 5) * 4)
        case OSCTag.boolTrue.rawValue:
            args += [true]
        case OSCTag.boolFalse.rawValue:
            args += [false]
        case OSCTag.null.rawValue:
            print("null type")
        default:
            print("unknown osc type")
        }
    }

    return args
}


private func shift(_ data: inout Data, by count: Int) {
    data = data.subdata(in: count..<data.count)
}















