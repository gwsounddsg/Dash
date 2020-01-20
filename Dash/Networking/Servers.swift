// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/20/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import Foundation
import RTTrPSwift


protocol ServersProtocol: class {
    func liveBlackTrax(_ data: RTTrP)
}





class Servers: ReceiveUDPDelegate, DashOSCServerDelegate {
    
    // ivars
    var blackTrax = ReceiveUDP()
    var vezer: DashOSCServer?
    var control: DashOSCServer?
    weak var delegate: ServersProtocol?
    
    // states
    fileprivate (set) var isBlackTraxConnected: Bool = false
    fileprivate (set) var isVezerConnected: Bool = false
    fileprivate (set) var isControlConnected: Bool = false
    
    
    init() {
        blackTrax.delegate = self
    }
    
    
    // MARK: - Connecting
    func connectAll(from defaults: UserDefaultsProtocol = UserDefaults.standard) -> [DashNetworkType.Server] {
        connectBlackTrax(from: defaults)
        connectControl(from: defaults)
        connectVezer(from: defaults)
        
        var badClients = [DashNetworkType.Server]()
        if !isBlackTraxConnected {badClients.append(.blackTrax)}
        if !isControlConnected {badClients.append(.control)}
        if !isVezerConnected {badClients.append(.recorded)}
        return badClients
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
    
    
    func connectControl(from defaults: UserDefaultsProtocol = UserDefaults.standard) {
        isControlConnected = false
        
        do {
            try doConnectControl(defaults)
            control!.start()
            isControlConnected = true
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    
    func connectVezer(from defaults: UserDefaultsProtocol = UserDefaults.standard) {
        isVezerConnected = false
        
        do {
            try doConnectVezer(defaults)
            vezer!.start()
            isVezerConnected = true
        }
        catch {
            print(error.localizedDescription)
        }
    }
}





// MARK: - ReceiveUDPDelegate

extension Servers {

    func newPacket(_ data: RTTrP) {
        delegate?.liveBlackTrax(data)
    }
}





// MARK: - OSC Server Delegate

extension Servers {
    
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





// MARK: - Utility

private extension Servers {
    
    func doConnectBlackTrax(_ defaults: UserDefaultsProtocol = UserDefaults.standard) throws {
        guard let port: Int = getDefault(withKey: DashDefaultIDs.Network.Incoming.blacktraxPort, from: defaults) else {
            throw DashError.CantGetDefaultValueFor(DashDefaultIDs.Network.Incoming.blacktraxPort)
        }
        
        if blackTrax.localPort() == port {return} // already connected
        
        do {try blackTrax.connect(port: port)}
        catch {throw error}
    }
    
    
    func doConnectControl(_ defaults: UserDefaultsProtocol) throws {
        let keys = DashDefaultIDs.Network.Incoming.self
        
        guard let port: Int = getDefault(withKey: keys.controlPort, from: defaults) else {
            control = nil
            throw DashError.CantGetDefaultValueFor(keys.controlPort)
        }
        
        if control == nil {
            control = DashOSCServer(.control, "", port)
            control!.delegate = self
        }
        else {
            control!.port = port
        }
    }
    
    
    private func doConnectVezer(_ defaults: UserDefaultsProtocol) throws {
        let keys = DashDefaultIDs.Network.Incoming.self
        
        guard let port: Int = getDefault(withKey: keys.recordedPort, from: defaults) else {
            vezer = nil
            throw DashError.CantGetDefaultValueFor(keys.recordedPort)
        }
        
        if vezer == nil {
            vezer = DashOSCServer(.recorded, "", port)
            vezer!.delegate = self
        }
        else {
            vezer!.port = port
        }
    }
}