// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/20/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import Foundation
import RTTrPSwift


protocol ListenersProtocol: AnyObject {
    func liveBlackTrax(_ data: RTTrP)
    func recordedVezer(_ data: Message)
    func command(control: ControlMessage, data: Any?)
}





class Listeners: ReceiveUDPDelegate, DashOSCServerDelegate {
    
    // ivars
    var blackTrax = ReceiveUDP()
    var vezer: DashOSCServer?
    var control: DashOSCServer?
    weak var delegate: ListenersProtocol?
    
    // states
    fileprivate (set) var isBlackTraxConnected: Bool = false
    fileprivate (set) var isVezerConnected: Bool = false
    fileprivate (set) var isControlConnected: Bool = false
    
    
    init(withObservers: Bool = true) {
        blackTrax.delegate = self
        
        if withObservers {
            addObserver(#selector(preferenceChange), DashNotif.userPrefServerBlackTraxPort)
            addObserver(#selector(preferenceChange), DashNotif.userPrefServerVezerPort)
            addObserver(#selector(preferenceChange), DashNotif.userPrefServerControlPort)
        }
    }
    
    
    // MARK: - Connecting
    
    func connectAll(from defaults: UserDefaultsProtocol = UserDefaults.standard) -> [DashNetworkType.Listener] {
        connectBlackTrax(from: defaults)
        connectControl(from: defaults)
        connectVezer(from: defaults)
        
        var badClients = [DashNetworkType.Listener]()
        if !isBlackTraxConnected {badClients.append(.blackTrax)}
        if !isControlConnected {badClients.append(.control)}
        if !isVezerConnected {badClients.append(.vezer)}
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
    
    
    func printNetworks() {
        blackTrax.printNetwork()
        vezer?.printNetwork()
        control?.printNetwork()
    }
}





// MARK: - ReceiveUDPDelegate

extension Listeners {

    func newPacket(_ data: RTTrP) {
        delegate?.liveBlackTrax(data)
    }
}





// MARK: - DashOSCServerDelegate

extension Listeners {
    
    func oscDataReceived(_ msg: Message, _ from: DashNetworkType.Listener) {
        switch from {
        case .control:
            controlOSC(data: msg)
        case .vezer:
            vezerOSC(data: msg)
        case .blackTrax:
            break
        }
    }
    
    
    private func controlOSC(data: Message) {
        switch data.address {
        case ControlOSC.switchTo:
            if data.values.isEmpty {
                print(data.address + " message is empty")
                return
            }
            delegate?.command(control: .switchActive, data: data.values[0])
    
        default:
            print("Invalid control message: \(data.address)")
        }
    }
    
    
    private func vezerOSC(data: Message) {
        delegate?.recordedVezer(data)
    }
}





// MARK: - Notifications

extension Listeners {
    
    @objc
    func preferenceChange(_ notif: Notification) {
        updateDefaults(notif)
    }
    
    
    func updateDefaults(_ notif: Notification, _ defaults: UserDefaultsProtocol = UserDefaults.standard) {
        guard let userInfo = notif.userInfo as? [String: String] else {
            return
        }
    
        guard let data = userInfo[DashNotifData.userPref] else {
            return
        }
    
        switch notif.name {
        case DashNotif.userPrefServerBlackTraxPort:
            let val = Int(data)
            if val == nil {
                print("Bad BlackTrax port number for string: \(data)")
                return
            }
            updateDefault(val!, DashDefaultIDs.Network.Server.blacktraxPort, defaults)
            connectBlackTrax(from: defaults)
            blackTrax.printNetwork()
    
        case DashNotif.userPrefServerVezerPort:
            let val = Int(data)
            if val == nil {
                print("Bad Vezer port number for string: \(data)")
                return
            }
            vezer?.port = val!
            updateDefault(val!, DashDefaultIDs.Network.Server.vezerPort, defaults)
            vezer?.printNetwork()
    
        case DashNotif.userPrefServerControlPort:
            let val = Int(data)
            if val == nil {
                print("Bad Control port number for string: \(data)")
                return
            }
            control?.port = val!
            updateDefault(val!, DashDefaultIDs.Network.Server.controlPort, defaults)
            control?.printNetwork()
    
        default:
            return
        }
    }
    
    
    fileprivate func addObserver(_ selector: Selector, _ name: NSNotification.Name?) {
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: nil)
    }
    
    
    private func updateDefault(_ value: Any, _ key: String, _ withDefault: UserDefaultsProtocol) {
        withDefault.update(value: value, forKey: key)
    }
}





// MARK: - Utility

private extension Listeners {
    
    func doConnectBlackTrax(_ defaults: UserDefaultsProtocol = UserDefaults.standard) throws {
        guard let port: Int = getDefault(withKey: DashDefaultIDs.Network.Server.blacktraxPort, from: defaults) else {
            throw DashError.CantGetDefaultValueFor(DashDefaultIDs.Network.Server.blacktraxPort)
        }
        
        if blackTrax.localPort() == port {return} // already connected
        
        do {try blackTrax.connect(port: port)}
        catch {throw error}
    }
    
    
    func doConnectVezer(_ defaults: UserDefaultsProtocol) throws {
        let keys = DashDefaultIDs.Network.Server.self
        
        guard let port: Int = getDefault(withKey: keys.vezerPort, from: defaults) else {
            vezer = nil
            throw DashError.CantGetDefaultValueFor(keys.vezerPort)
        }
        
        if vezer == nil {
            vezer = DashOSCServer(.vezer, "", port)
            vezer!.delegate = self
        }
        else {
            vezer!.port = port
        }
    }
    
    
    func doConnectControl(_ defaults: UserDefaultsProtocol) throws {
        let keys = DashDefaultIDs.Network.Server.self
        
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
}
