//
// Created by GW Rodriguez on 11/16/22.
// Copyright (c) 2022 GW Rodriguez. All rights reserved.
//

import Foundation

extension Data {
    func toString() -> String? {
        return String(data: self, encoding: .utf8)
    }
}