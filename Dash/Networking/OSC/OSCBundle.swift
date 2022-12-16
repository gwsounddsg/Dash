//
// Created by GW Rodriguez on 12/16/22.
// Copyright (c) 2022 GW Rodriguez. All rights reserved.
//

import Foundation

public struct OSCBundle {
    public var timetag: Timetag
    public var elements: [OSCType] = []

    public var data: Data {
        get {
            var data = Data()
            data.append("#bundle".toBase32())
            data.append(timetag.data)

            for element in elements {
                let elementData = element.data
                data.append(Int32(elementData.count).toData())
            }

            return data
        }
    }


    public init(_ elements: OSCType...) {
        timetag = 1
        self.elements = elements
    }
}