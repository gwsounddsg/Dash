//
// Created by GW Rodriguez on 12/16/22.
// Copyright (c) 2022 GW Rodriguez. All rights reserved.
//

import Foundation


public struct OSCBundle: OSCElement {
    public var timeTag: Timetag
    public var elements: [OSCElement] = []
    public static let bundleID = "#bundle\0".data

    public var data: Data {
        get {
            var data = Data()
            data.append("#bundle".toBase32())
            data.append(timeTag.data)

            for element in elements {
                let elementData = element.data
                data.append(Int32(elementData.count).toData())
            }

            return data
        }
    }


    public init(_ elements: [OSCElement] = [], timeTag: Timetag = 1) {
        self.timeTag = timeTag
        self.elements = elements
    }


    public mutating func add(_ elements: OSCMessage...) {
        self.elements += elements
    }
}