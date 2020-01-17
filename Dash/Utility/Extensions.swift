// ===================================================
// Created by:  GW Rodriguez
// Date:        12/24/19
// Copyright:   Copyright © 2019 GW Rodriguez. All rights reserved.
// ===================================================

import Foundation





extension Data {
    var bytes: [UInt8] {return [UInt8](self)}
}





// This protocol, and following extension, are about making it easier to do Unit Tests
protocol UserDefaultsProtocol: class {
    func update(value: Any?, forKey: String)
    func getString(forKey: String) -> String?
    func getInt(forKey: String) -> Int?
    func removeTheObject(forKey key: String)
}


extension UserDefaults: UserDefaultsProtocol {
    func update(value: Any?, forKey: String) {
        self.set(value, forKey: forKey)
    }
    
    func getString(forKey: String) -> String? {
        return self.string(forKey: forKey)
    }
    
    func getInt(forKey: String) -> Int? {
        return self.integer(forKey: forKey)
    }
    
    func removeTheObject(forKey key: String) {
        self.removeObject(forKey: key)
    }
    
    func resetDefaults() {
        UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        UserDefaults.standard.synchronize()
    }
}