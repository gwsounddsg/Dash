//
// Created by GW Rodriguez on 11/18/22.
// Copyright (c) 2022 GW Rodriguez. All rights reserved.
//

import Foundation

extension Bool: OSCType {
    public var tag: OSCTag {
        get {
            return self ? .boolTrue : .boolFalse
        }
    }

    public var data: Data {
        get { return Data() }
    }
}