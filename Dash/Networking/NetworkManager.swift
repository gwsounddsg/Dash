// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/7/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import Foundation
import RTTrPSwift





protocol NetworkManagerDelegate: class {
    func liveBlackTrax(_ data: RTTrP)
}





class NetworkManager {
    
    // Singleton
    static let instance = NetworkManager()
    
    // iVars
    weak var delegate: NetworkManagerDelegate?
    
    // States
    fileprivate (set) var isBlackTraxConnected: Bool = false
    fileprivate (set) var isServerControlConnected: Bool = false
    fileprivate (set) var isServerRecordedConnected: Bool = false
    fileprivate (set) var isClientRecordedConnected: Bool = false
    fileprivate (set) var isClientLiveConnected: Bool = false
    
    // Incoming
    var blackTrax = ReceiveUDP()
    var oscServerControl: DashOSCServer?
    var oscServerRecorded: DashOSCServer?
    
    // Outgoing
    var oscClientRecorded: DashOSCClient?
    var oscClientLive: DashOSCClient?
    
    
    init() {
        blackTrax.delegate = self
    }
}





// MARK: - Receive BlackTrax

extension NetworkManager: ReceiveUDPDelegate {
    
    func newPacket(_ data: RTTrP) {
        delegate?.liveBlackTrax(data)
    }
}





// MARK: - OSC Server Delegate

extension NetworkManager: DashOSCServerDelegate {
    
    func oscDataReceived(_ msg: Message, _ from: DashNetworkType.Server) {
        switch from {
        case .control:
            controlOSC(data: msg)
        case .recorded:
            recordedOSC(data: msg)
        case .blackTrax:
            break
        }
    }
    
    
    fileprivate func controlOSC(data: Message) {
        print(data)
    }
    
    
    fileprivate func recordedOSC(data: Message) {
        //TODO: add recorded logic
    }
}





// MARK: - Connecting

extension NetworkManager {
    // swiftlint:disable opening_brace
    
    /// Returns array of types not connected
    func connectAll(from defaults: UserDefaultsProtocol = UserDefaults.standard) -> (clients: [DashNetworkType
    .Client], servers: [DashNetworkType.Server])
    {
        connectBlackTrax(from: defaults)
        connectControlServer(from: defaults)
        connectRecordedServer(from: defaults)
        connectRecordedClient(from: defaults)
        connectLiveClient(from: defaults)
        
        return checkConnections()
    }
    // swiftlint:enable opening_brace
    
    
    private func checkConnections() -> ([DashNetworkType.Client], [DashNetworkType.Server]) {
        var badClients = [DashNetworkType.Client]()
        var badServers = [DashNetworkType.Server]()
        
        if !isBlackTraxConnected {badServers.append(.blackTrax)}
        if !isServerControlConnected {badServers.append(.control)}
        if !isServerRecordedConnected {badServers.append(.recorded)}
        if !isClientRecordedConnected {badClients.append(.recorded)}
        if !isClientLiveConnected {badClients.append(.ds100)}
        
        return (badClients, badServers)
    }
    
    
    func connectBlackTrax(from defaults: UserDefaultsProtocol = UserDefaults.standard) {
        guard let port: Int = getDefault(withKey: DashDefaultIDs.Network.Incoming.blacktraxPort, from: defaults) else {
            print("Error: couldn't get default port number for BlackTrax")
            return
        }
        
        do {
            try blackTrax.connect(port: port)
            isBlackTraxConnected = true
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    
    func connectControlServer(from defaults: UserDefaultsProtocol = UserDefaults.standard) {
        let keys = DashDefaultIDs.Network.Incoming.self
        
        guard let port: Int = getDefault(withKey: keys.controlPort, from: defaults) else {
            print("Error couldn't get default port number for Control Server")
            return
        }
        
        isServerControlConnected = false
        
        if oscServerControl == nil {
            oscServerControl = DashOSCServer(.control, "", port)
            oscServerControl!.delegate = self
        }
        else {
            oscServerControl!.port = port
        }
        
        oscServerControl!.start()
        isServerControlConnected = true
    }
    
    
    func connectRecordedServer(from defaults: UserDefaultsProtocol = UserDefaults.standard) {
        let keys = DashDefaultIDs.Network.Incoming.self
        
        guard let port: Int = getDefault(withKey: keys.recordedPort, from: defaults) else {
            print("Error couldn't get default port number for Recorded Server")
            return
        }
    
        isServerRecordedConnected = false
        
        if oscServerRecorded == nil {
            oscServerRecorded = DashOSCServer(.recorded, "", port)
            oscServerRecorded!.delegate = self
        }
        else {
            oscServerRecorded!.port = port
        }
        
        oscServerRecorded!.start()
        isServerRecordedConnected = true
    }
    
    
    func connectRecordedClient(from defaults: UserDefaultsProtocol = UserDefaults.standard) {
        let keys = DashDefaultIDs.Network.Outgoing.self
        
        guard let addy: String = getDefault(withKey: keys.recordedIP, from: defaults) else {
            print("Error couldn't get default IP Address for Recorded Client")
            return
        }
        
        guard let port: Int = getDefault(withKey: keys.recordedPort, from: defaults) else {
            print("Error couldn't get default port number for Recorded Client")
            return
        }
    
        isClientRecordedConnected = false
        
        if oscClientRecorded == nil {
            oscClientRecorded = DashOSCClient(.recorded, addy, port)
        }
        else {
            oscClientRecorded!.address = addy
            oscClientRecorded!.port = port
        }
        
        isClientRecordedConnected = true
    }
    
    
    func connectLiveClient(from defaults: UserDefaultsProtocol = UserDefaults.standard) {
        let keys = DashDefaultIDs.Network.Outgoing.self
        
        guard let addy: String = getDefault(withKey: keys.liveIP, from: defaults) else {
            print("Error couldn't get default IP Address for Live Client")
            return
        }
        
        guard let port: Int = getDefault(withKey: keys.livePort, from: defaults) else {
            print("Error couldn't get default port number for Live Client")
            return
        }
    
        isClientLiveConnected = false
        
        if oscClientLive == nil {
            oscClientLive = DashOSCClient(.ds100, addy, port)
        }
        else {
            oscClientLive!.address = addy
            oscClientLive!.port = port
        }
        
        isClientLiveConnected = true
    }
}





// MARK: - Sending Messages

extension NetworkManager {
    
    func sendOSC(message: Message, to client: DashNetworkType.Client) -> Bool {
        switch client {
        case .recorded:
            if !isClientRecordedConnected {return false}
            oscClientRecorded!.send(message: message)
            
        case .ds100:
            if !isClientLiveConnected {return false}
            oscClientLive!.send(message: message)
        }
        
        return true
    }
    
    
    func send(ds100 data: [DS100]) -> Bool {
        if !isClientLiveConnected {return false}
        oscClientLive!.send(data: data)
        return true
    }
}





// MARK: - Utility

fileprivate extension NetworkManager {
    
    func getDefault(withKey key: String, from: UserDefaultsProtocol) -> Int? {
        return from.getInt(forKey: key)
    }
    
    
    func getDefault(withKey key: String, from: UserDefaultsProtocol) -> String? {
        return from.getString(forKey: key)
    }
}
