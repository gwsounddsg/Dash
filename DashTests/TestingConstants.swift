// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/14/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import Foundation
@testable import Dash

// swiftlint:disable line_length comma

let rttData: [UInt8] = [65, 84, 52, 67, 0, 2, 0, 0, 0, 1, 0, 0, 231, 255, 255, 255, 255,1,1,0, 213,1,48,4,32,0, 51,6, 128, 32, 245, 221, 147, 35, 64, 0, 0, 0, 0, 0, 0, 0, 0,74, 178, 220, 252, 105, 132, 0, 64,122, 73, 219, 194,0, 0, 0, 0,237, 167, 84, 194,7, 196, 244, 64,0, 0, 0, 0,180, 84, 12, 194,33,0, 52,6, 128, 32, 245, 221, 147, 35, 64,0, 0, 0, 0, 0, 0, 0, 0,74, 178, 220, 252, 105, 132, 0, 64,122, 73, 219, 194,0, 0, 0, 0,237, 167, 84, 194,7, 196, 244, 64,0, 0, 0, 0,180, 84, 12, 194,0,33,0, 52,6, 128, 32, 245, 221, 147, 35, 64,0, 0, 0, 0, 0, 0, 0, 0,74, 178, 220, 252, 105, 132, 0, 64,122, 73, 219, 194,0, 0, 0, 0,237, 167, 84, 194,7, 196, 244, 64,0, 0, 0, 0,180, 84, 12, 194,1,33,0, 52,6, 128, 32, 245, 221, 147, 35, 64,0, 0, 0, 0, 0, 0, 0, 0,74, 178, 220, 252, 105, 132, 0, 64,122, 73, 219, 194,0, 0, 0, 0,237, 167, 84, 194,7, 196, 244, 64,0, 0, 0, 0,180, 84, 12, 194,2]

let rttrpData3: [UInt8] = [65, 84, 52, 67, 0, 2, 0, 0, 0, 1, 0, 2, 145, 255, 255, 255, 255, 3, 1, 0, 213, 1, 48, 4, 32, 0, 51, 8, 52, 42, 68, 33, 137, 239, 191, 1, 0, 0, 0, 0, 0, 0, 0, 77, 230, 251, 228, 231, 9, 198, 191, 0, 0, 0, 0, 16, 199, 157, 64, 136, 89, 36, 191, 0, 0, 0, 0, 236, 25, 98, 64, 33, 0, 52, 8, 52, 42, 68, 33, 137, 239, 191, 1, 0, 0, 0, 0, 0, 0, 0, 77, 230, 251, 228, 231, 9, 198, 191, 140, 74, 50, 65, 0, 0, 0, 0, 16, 199, 157, 64, 136, 89, 36, 191, 0, 0, 0, 0, 236, 25, 98, 64, 0, 33, 0, 52, 8, 52, 42, 68, 33, 137, 239, 191, 1, 0, 0, 0, 0, 0, 0, 0, 77, 230, 251, 228, 231, 9, 198, 191, 140, 74, 50, 65, 0, 0, 0, 0, 16, 199, 157, 64, 136, 89, 36, 191, 0, 0, 0, 0, 236, 25, 98, 64, 1, 33, 0, 52, 8, 52, 42, 68, 33, 137, 239, 191, 1, 0, 0, 0, 0, 0, 0, 0, 77, 230, 251, 228, 231, 9, 198, 191, 140, 74, 50, 65, 0, 0, 0, 0, 16, 199, 157, 64, 136, 89, 36, 191, 0, 0, 0, 0, 236, 25, 98, 64, 2, 1, 0, 213, 1, 49, 4, 32, 0, 51, 83, 206, 192, 108, 193, 198, 226, 63, 0, 0, 0, 0, 0, 0, 0, 0, 148, 116, 215, 190, 196, 237, 233, 191, 254, 15, 21, 193, 0, 0, 0, 0, 81, 84, 251, 64, 247, 52, 57, 192, 0, 0, 0, 0, 157, 11, 8, 192, 33, 0, 52, 83, 206, 192, 108, 193, 198, 226, 63, 0, 0, 0, 0, 0, 0, 0, 0, 148, 116, 215, 190, 196, 237, 233, 191, 254, 15, 21, 193, 0, 0, 0, 0, 81, 84, 251, 64, 247, 52, 57, 192, 0, 0, 0, 0, 157, 11, 8, 192, 0, 33, 0, 52, 83, 206, 192, 108, 193, 198, 226, 63, 0, 0, 0, 0, 0, 0, 0, 0, 148, 116, 215, 190, 196, 237, 233, 191, 254, 15, 21, 193, 0, 0, 0, 0, 81, 84, 251, 64, 247, 52, 57, 192, 0, 0, 0, 0, 157, 11, 8, 192, 1, 33, 0, 52, 83, 206, 192, 108, 193, 198, 226, 63, 0, 0, 0, 0, 0, 0, 0, 0, 148, 116, 215, 190, 196, 237, 233, 191, 254, 15, 21, 193, 0, 0, 0, 0, 81, 84, 251, 64, 247, 52, 57, 192, 0, 0, 0, 0, 157, 11, 8, 192, 2, 1, 0, 213, 1, 50, 4, 32, 0, 51, 5, 131, 191, 235, 141, 25, 238, 63, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 236, 52, 221, 205, 213, 63, 75, 226, 33, 193, 0, 0, 0, 0, 197, 76, 217, 192, 77, 115, 159, 63, 0, 0, 0, 0, 12, 136, 87, 192, 33, 0, 52, 5, 131, 191, 235, 141, 25, 238, 63, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 236, 52, 221, 205, 213, 63, 75, 226, 33, 193, 0, 0, 0, 0, 197, 76, 217, 192, 77, 115, 159, 63, 0, 0, 0, 0, 12, 136, 87, 192, 0, 33, 0, 52, 5, 131, 191, 235, 141, 25, 238, 63, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 236, 52, 221, 205, 213, 63, 75, 226, 33, 193, 0, 0, 0, 0, 197, 76, 217, 192, 77, 115, 159, 63, 0, 0, 0, 0, 12, 136, 87, 192, 1, 33, 0, 52, 5, 131, 191, 235, 141, 25, 238, 63, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 236, 52, 221, 205, 213, 63, 75, 226, 33, 193, 0, 0, 0, 0, 197, 76, 217, 192, 77, 115, 159, 63, 0, 0, 0, 0, 12, 136, 87, 192, 2]





class MockUserDefaults: UserDefaultsProtocol {
    
    var invokedUpdate = false
    var invokedUpdateCount = 0
    var invokedUpdateParameters: (value: Any?, forKey: String)?
    var invokedUpdateParametersList = [(value: Any?, forKey: String)]()
    
    func update(value: Any?, forKey: String) {
        invokedUpdate = true
        invokedUpdateCount += 1
        invokedUpdateParameters = (value, forKey)
        invokedUpdateParametersList.append((value, forKey))
    }
    
    var invokedGetString = false
    var invokedGetStringCount = 0
    var invokedGetStringParameters: (forKey: String, Void)?
    var invokedGetStringParametersList = [(forKey: String, Void)]()
    var stubbedGetStringResult: String!
    
    func getString(forKey: String) -> String? {
        invokedGetString = true
        invokedGetStringCount += 1
        invokedGetStringParameters = (forKey, ())
        invokedGetStringParametersList.append((forKey, ()))
        return stubbedGetStringResult
    }
    
    var invokedGetInt = false
    var invokedGetIntCount = 0
    var invokedGetIntParameters: (forKey: String, Void)?
    var invokedGetIntParametersList = [(forKey: String, Void)]()
    var stubbedGetIntResult: Int!
    
    func getInt(forKey: String) -> Int? {
        invokedGetInt = true
        invokedGetIntCount += 1
        invokedGetIntParameters = (forKey, ())
        invokedGetIntParametersList.append((forKey, ()))
        return stubbedGetIntResult
    }
    
    var invokedRemoveTheObject = false
    var invokedRemoveTheObjectCount = 0
    var invokedRemoveTheObjectParameters: (key: String, Void)?
    var invokedRemoveTheObjectParametersList = [(key: String, Void)]()
    
    func removeTheObject(forKey key: String) {
        invokedRemoveTheObject = true
        invokedRemoveTheObjectCount += 1
        invokedRemoveTheObjectParameters = (key, ())
        invokedRemoveTheObjectParametersList.append((key, ()))
    }
    
    var invokedSynchronizeAll = false
    var invokedSynchronizeAllCount = 0
    
    func synchronizeAll() {
        invokedSynchronizeAll = true
        invokedSynchronizeAllCount += 1
    }
}