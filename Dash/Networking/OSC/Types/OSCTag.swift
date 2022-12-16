//
// Created by GW Rodriguez on 11/17/22.
// Copyright (c) 2022 GW Rodriguez. All rights reserved.
//

import Foundation

public enum OSCTag: String, CaseIterable {
    case int = "i"
    case float = "f"
    case string = "s"
    case blob = "b"
    case boolTrue = "T"
    case boolFalse = "F"

    case time = "t"
    case null = "N"
    case impulse = "I"
}


func GetAllOscTags() -> String {
    let tags = OSCTag.allCases
    var allTypes = ""

    for tag in tags {
        allTypes += tag.rawValue
    }

    return allTypes
}