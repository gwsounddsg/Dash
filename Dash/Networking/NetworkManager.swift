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
        print("Control \(data)")
    }
    
    
    fileprivate func recordedOSC(data: Message) {
        print("Vezer: \(data)")
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
        isBlackTraxConnected = false
        
        do {
            try doConnectBlackTrax(defaults)
            isBlackTraxConnected = true
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    private func doConnectBlackTrax(_ defaults: UserDefaultsProtocol = UserDefaults.standard) throws {
        guard let port: Int = getDefault(withKey: DashDefaultIDs.Network.Incoming.blacktraxPort, from: defaults) else {
            throw DashError.CantGetDefaultValueFor(DashDefaultIDs.Network.Incoming.blacktraxPort)
        }
        
        if blackTrax.localPort() == port {return} // already connected
        
        do {try blackTrax.connect(port: port)}
        catch {throw error}
    }
    
    
    func connectControlServer(from defaults: UserDefaultsProtocol) {
        isServerControlConnected = false
        
        do {
            try doConnectControlServer(defaults)
            oscServerControl!.start()
            isServerControlConnected = true
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    private func doConnectControlServer(_ defaults: UserDefaultsProtocol) throws {
        let keys = DashDefaultIDs.Network.Incoming.self
        
        guard let port: Int = getDefault(withKey: keys.controlPort, from: defaults) else {
            oscServerControl = nil
            throw DashError.CantGetDefaultValueFor(keys.controlPort)
        }
    
        if oscServerControl == nil {
            oscServerControl = DashOSCServer(.control, "", port)
            oscServerControl!.delegate = self
        }
        else {
            oscServerControl!.port = port
        }
    }
    
    
    func connectRecordedServer(from defaults: UserDefaultsProtocol = UserDefaults.standard) {
        isServerRecordedConnected = false
        
        do {
            try doConnectRecordedServer(defaults)
            oscServerRecorded!.start()
            isServerRecordedConnected = true
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    private func doConnectRecordedServer(_ defaults: UserDefaultsProtocol) throws {
        let keys = DashDefaultIDs.Network.Incoming.self
    
        guard let port: Int = getDefault(withKey: keys.recordedPort, from: defaults) else {
            oscServerRecorded = nil
            throw DashError.CantGetDefaultValueFor(keys.recordedPort)
        }
    
        if oscServerRecorded == nil {
            oscServerRecorded = DashOSCServer(.recorded, "", port)
            oscServerRecorded!.delegate = self
        }
        else {
            oscServerRecorded!.port = port
        }
    }
    
    
    func connectRecordedClient(from defaults: UserDefaultsProtocol = UserDefaults.standard) {
        isClientRecordedConnected = false
        
        do {
            try doConnectRecordedClient(defaults)
            isClientRecordedConnected = true
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    private func doConnectRecordedClient(_ defaults: UserDefaultsProtocol) throws {
        let keys = DashDefaultIDs.Network.Outgoing.self
    
        guard let addy: String = getDefault(withKey: keys.recordedIP, from: defaults) else {
            oscClientRecorded = nil
            throw DashError.CantGetDefaultValueFor(keys.recordedIP)
        }
    
        guard let port: Int = getDefault(withKey: keys.recordedPort, from: defaults) else {
            oscClientRecorded = nil
            throw DashError.CantGetDefaultValueFor(keys.recordedPort)
        }
    
        if oscClientRecorded == nil {
            oscClientRecorded = DashOSCClient(.recorded, addy, port)
        }
        else {
            oscClientRecorded!.address = addy
            oscClientRecorded!.port = port
        }
    }
    
    
    func connectLiveClient(from defaults: UserDefaultsProtocol = UserDefaults.standard) {
        isClientLiveConnected = false
        
        do {
            try doConnectLiveClient(defaults)
            isClientLiveConnected = true
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    private func doConnectLiveClient(_ defaults: UserDefaultsProtocol) throws {
        let keys = DashDefaultIDs.Network.Outgoing.self
    
        guard let addy: String = getDefault(withKey: keys.liveIP, from: defaults) else {
            oscClientLive = nil
            throw DashError.CantGetDefaultValueFor(keys.liveIP)
        }
    
        guard let port: Int = getDefault(withKey: keys.livePort, from: defaults) else {
            oscClientLive = nil
            throw DashError.CantGetDefaultValueFor(keys.livePort)
        }
    
        if oscClientLive == nil {
            oscClientLive = DashOSCClient(.ds100, addy, port)
        }
        else {
            oscClientLive!.address = addy
            oscClientLive!.port = port
        }
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
