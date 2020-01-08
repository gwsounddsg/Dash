// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/7/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import Foundation
import RTTrPSwift





protocol NetworkManagerDelegate {
    func liveBlackTrax(_ data: RTTrP)
}





class NetworkManager {
    
    // Singleton
    static let instance = NetworkManager()
    
    // iVars
    var delegate: NetworkManagerDelegate? = nil
    
    // States
    fileprivate (set) var isBlackTraxConnect: Bool = false
    fileprivate (set) var isControlServerConnect: Bool = false
    fileprivate (set) var isRecordedServerConnect: Bool = false
    fileprivate (set) var isRecordedClientConnect: Bool = false
    fileprivate (set) var isLiveClientConnect: Bool = false
    
    // Incoming
    fileprivate let _blackTrax = ReceiveUDP()
    fileprivate var _oscServerControl: DashOSCServer? = nil
    fileprivate var _oscServerRecorded: DashOSCServer? = nil
    
    // Outgoing
    fileprivate var _oscClientRecorded: DashOSCClient? = nil
    fileprivate var _oscClientLive: DashOSCClient? = nil
    
    
    init() {
        _blackTrax.delegate = self
    }
}





//MARK: - Receive BlackTrax

extension NetworkManager: ReceiveUDPDelegate {
    
    func newPacket(_ data: RTTrP) {
        delegate?.liveBlackTrax(data)
    }
}





//MARK: - OSC Server Delegate

extension NetworkManager: DashOSCServerDelegate {
    
    func oscDataReceived(_ msg: Message, _ from: DashNetworkType.Server) {
        switch from {
            case .control:
                controlOSC(data: msg)
            case .recorded:
                recordedOSC(data: msg)
            case .blackTrax:
                break;
        }
    }
    
    
    fileprivate func controlOSC(data: Message) {
        //TODO: add control logic
    }
    
    
    fileprivate func recordedOSC(data: Message) {
        //TODO: add recorded logic
    }
}





//MARK: - Connecting

extension NetworkManager {
    
    /// Returns array of types not connected
    func connectAll() -> ([DashNetworkType.Client], [DashNetworkType.Server]) {
        connectBlackTraxPortWithPref()
        connectControlServer()
        connectRecordedServer()
        connectRecordedClient()
        connectLiveClient()
        
        return checkConnections()
    }
    
    
    private func checkConnections() -> ([DashNetworkType.Client], [DashNetworkType.Server]) {
        var badClients = [DashNetworkType.Client]()
        var badServers = [DashNetworkType.Server]()
        
        if !isBlackTraxConnect      {badServers.append(.blackTrax)}
        if !isControlServerConnect  {badServers.append(.control)}
        if !isRecordedServerConnect {badServers.append(.recorded)}
        if !isRecordedClientConnect {badClients.append(.recorded)}
        if !isLiveClientConnect     {badClients.append(.ds100)}
        
        return (badClients, badServers)
    }
    
    
    func connectBlackTraxPortWithPref() {
        guard let port: Int = getDefault(withKey: DashDefaultIDs.Network.Incoming.blacktraxPort) else {
            print("Error: couldn't get default port number for BlackTrax")
            return
        }
        
        do {
            try _blackTrax.connect(port: port)
            isBlackTraxConnect = true
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    
    func connectControlServer() {
        let keys = DashDefaultIDs.Network.Incoming.self
        
        guard let port: Int = getDefault(withKey: keys.controlPort) else {
            print("Error couldn't get default port number for Control Server")
            return
        }
        
        if _oscServerControl != nil {
            _oscServerControl = nil
            isControlServerConnect = false
        }
        _oscServerControl = DashOSCServer(.control, "127.0.0.1", port)
        _oscServerControl!.start()
        isControlServerConnect = true
    }
    
    
    func connectRecordedServer() {
        let keys = DashDefaultIDs.Network.Incoming.self
        
        guard let port: Int = getDefault(withKey: keys.recordedPort) else {
            print("Error couldn't get default port number for Recorded Server")
            return
        }
        
        if _oscServerRecorded != nil {
            _oscServerRecorded = nil
            isRecordedServerConnect = false
        }
        _oscServerRecorded = DashOSCServer(.recorded, "127.0.0.1", port)
        _oscServerRecorded!.start()
        isRecordedServerConnect = true
    }
    
    
    func connectRecordedClient() {
        let keys = DashDefaultIDs.Network.Outgoing.self
        
        guard let addy: String = getDefault(withKey: keys.recordedIP) else {
            print("Error couldn't get default IP Address for Recorded Client")
            return
        }
        
        guard let port: Int = getDefault(withKey: keys.recordedPort) else {
            print("Error couldn't get default port number for Recorded Client")
            return
        }
        
        if _oscClientRecorded != nil {
            _oscClientRecorded = nil
            isRecordedClientConnect = false
        }
        _oscClientRecorded = DashOSCClient(.recorded, addy, port)
        isRecordedClientConnect = true
    }
    
    
    func connectLiveClient() {
        let keys = DashDefaultIDs.Network.Outgoing.self
        
        guard let addy: String = getDefault(withKey: keys.liveIP) else {
            print("Error couldn't get default IP Address for Live Client")
            return
        }
        
        guard let port: Int = getDefault(withKey: keys.livePort) else {
            print("Error couldn't get default port number for Live Client")
            return
        }
        
        if _oscClientLive != nil {
            _oscClientLive = nil
            isLiveClientConnect = false
        }
        _oscClientLive = DashOSCClient(.ds100, addy, port)
        isLiveClientConnect = true
    }
}





//MARK: - Sending Messages

extension NetworkManager {
    
    func sendOSC(message: Message, to client: DashNetworkType.Client) -> Bool {
        switch client {
        case .recorded:
            if !isRecordedClientConnect {return false}
            _oscClientRecorded!.send(message: message)
            
        case .ds100:
            if !isLiveClientConnect {return false}
            _oscClientLive!.send(message: message)
        }
        
        return true
    }
    
    
    func send(ds100 data: [DS100]) -> Bool {
        if !isLiveClientConnect {return false}
        _oscClientLive!.send(data: data)
        return true
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
