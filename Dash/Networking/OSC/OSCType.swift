//
// Created by GW Rodriguez on 11/16/22.
// Copyright (c) 2022 GW Rodriguez. All rights reserved.
//

import Foundation

public typealias Blob = Data
public typealias Timetag = UInt64


public protocol OSCType {
    var data: Data { get }
}