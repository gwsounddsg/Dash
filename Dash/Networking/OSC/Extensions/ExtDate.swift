//
// Created by GW Rodriguez on 12/16/22.
// Copyright (c) 2022 GW Rodriguez. All rights reserved.
//

import Foundation

extension Date {
    var oscTime: Timetag {
        let RFC3339DateFormatter = DateFormatter()
        RFC3339DateFormatter.locale = Locale(identifier: "en_US_POSIX")
        RFC3339DateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        RFC3339DateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        let date = RFC3339DateFormatter.date(from: "1900-01-01T00:00:00-00:00")

        return Timetag(Date().timeIntervalSince(date!) * 0x1_0000_0000)
    }
}