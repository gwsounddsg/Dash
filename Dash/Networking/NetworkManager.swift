// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/7/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import Foundation
import RTTrPSwift





class NetworkManager {
    
    // Singleton
    static let instance = NetworkManager()
    
    fileprivate let _blackTrax = ReceiveUDP()
    fileprivate var _oscServerControl: DashOSCServer? = nil
    fileprivate var _oscServerRecorded: DashOSCServer? = nil
    
    
    init() {
        // setup blacktrax
        _blackTrax.delegate = self
    }
}





//MARK: - Receive BlackTrax
extension NetworkManager: ReceiveUDPDelegate {
    
    func newPacket(_ data: RTTrP) {
        
    }
}





//MARK: - Connecting

extension NetworkManager {
    
    func connectAll() {
        connectBlackTraxPortWithPref()
        connectControlServer()
        connectRecordedServer()
    }
    
    
    func connectBlackTraxPortWithPref() {
        guard let port: Int = getDefault(withKey: DashDefaultIDs.Network.Incoming.blacktraxPort) else {
            print("Error: couldn't get default port number for BlackTrax")
            return
        }
        
        do      {try _blackTrax.connect(port: port)}
        catch   {print(error.localizedDescription)}
    }
    
    
    func connectControlServer() {
        let keys = DashDefaultIDs.Network.Incoming.self
        
        guard let port: Int = getDefault(withKey: keys.controlPort) else {
            print("Error couldn't get default port number for Control Server")
            return
        }
        
        if _oscServerControl != nil {_oscServerControl = nil}
        _oscServerControl = DashOSCServer(.control, "127.0.0.1", port)
        _oscServerControl!.start()
    }
    
    
    func connectRecordedServer() {
        let keys = DashDefaultIDs.Network.Incoming.self
        
        guard let port: Int = getDefault(withKey: keys.recordedPort) else {
            print("Error couldn't get default port number for Recorded Server")
            return
        }
        
        if _oscServerRecorded != nil {_oscServerRecorded = nil}
        _oscServerRecorded = DashOSCServer(.recorded, "127.0.0.1", port)
        _oscServerRecorded!.start()
    }
}





//MARK: - Utility
fileprivate extension NetworkManager {
    
    func getDefault(withKey key: String) -> Int? {
        guard let str: String = getDefault(withKey: key) else {return nil}
        return Int(str)
    }
    
    
    func getDefault(withKey key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
}
