// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/20/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import Foundation
import RTTrPSwift
import Network


protocol ListenersProtocol: AnyObject {
    func liveBlackTrax(_ data: RTTrP)
    func recordedVezer(_ data: OSCMessage)
    func command(control: ControlMessage, data: Any?)
}





class Listeners: DashListenerDelegate, DashOSCListenerDelegate {
    // ivars
    var blackTrax: DashListener?
    var vezer: DashOSCListener?
    var control: DashOSCListener?
    weak var delegate: ListenersProtocol?
    
    // states
    fileprivate (set) var isBlackTraxConnected: Bool = false
    fileprivate (set) var isVezerConnected: Bool = false
    fileprivate (set) var isControlConnected: Bool = false
    
    
    init(withObservers: Bool = true) {
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
            try newConnection(.blackTrax, defaults)
            isBlackTraxConnected = true
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    
    func connectVezer(from defaults: UserDefaultsProtocol = UserDefaults.standard) {
        isVezerConnected = false
        
        do {
            try newConnection(.vezer, defaults)
            isVezerConnected = true
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    
    func connectControl(from defaults: UserDefaultsProtocol = UserDefaults.standard) {
        isControlConnected = false
        
        do {
            try newConnection(.control, defaults)
            isControlConnected = true
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    
    func printNetworks() {
        blackTrax?.printNetwork()
        vezer?.printNetwork()
        control?.printNetwork()
    }
}





// MARK: - DashListenersDelegate
extension Listeners {
    func listenerReceived(_ data: Data, _ from: DashNetworkType.Listener) {
        do {
            let rttrp = try RTTrP(data: data.bytes)
            delegate?.liveBlackTrax(rttrp)
        }
        catch {
            print("Failed to convert data to RTTrP with error: \(error)")
        }
    }
}





// MARK: - DashOSCServerDelegate
extension Listeners {
    func oscMessageReceived(_ message: OSCMessage, _ from: DashNetworkType.Listener) {
        switch from {
        case .control:
            controlOSC(data: message)
        case .vezer:
            vezerOSC(data: message)
        case .blackTrax:
            break
        }
    }

    func oscBundleReceived(_ bundle: OSCBundle, _ from: DashNetworkType.Listener) {
//        switch from {
//        case .control:
//            controlOSC(data: bundle)
//        case .vezer:
//            vezerOSC(data: bundle)
//        case .blackTrax:
//            break
//        }
        print("Bundles not handled yet!!!!!")
    }


    private func controlOSC(data: OSCMessage) {
//        switch data.address {
//        case ControlOSC.switchTo:
//            if data.values.isEmpty {
//                print(data.address + " message is empty")
//                return
//            }
//            delegate?.command(control: .switchActive, data: data.values[0])
//
//        default:
//            print("Invalid control message: \(data.address)")
//        }
    }


    private func vezerOSC(data: OSCMessage) {
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
            updateDefault(val!, DashDefaultIDs.Network.Listener.blacktraxPort, defaults)
            connectBlackTrax(from: defaults)
            blackTrax?.printNetwork()

        case DashNotif.userPrefServerVezerPort:
            let val = Int(data)
            if val == nil {
                print("Bad Vezer port number for string: \(data)")
                return
            }
            updateDefault(val!, DashDefaultIDs.Network.Listener.vezerPort, defaults)
            connectVezer(from: defaults)
            vezer?.printNetwork()
    
        case DashNotif.userPrefServerControlPort:
            let val = Int(data)
            if val == nil {
                print("Bad Control port number for string: \(data)")
                return
            }
            updateDefault(val!, DashDefaultIDs.Network.Listener.controlPort, defaults)
            connectControl(from: defaults)
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
    
    func newConnection(_ type: DashNetworkType.Listener, _ defaults: UserDefaultsProtocol = UserDefaults.standard) throws {
        let port = try getPortForType(type)
        let newListener: NWListener = try createNewListener(with: port)
        
        switch type {
        case .blackTrax:
            blackTrax = DashListener(newListener, "BlackTrax udp listener", .blackTrax)
            blackTrax!.delegate = self
            blackTrax!.connect()
        case .vezer:
            vezer = DashOSCListener(newListener, "Vezer udp listener", .vezer)
            vezer!.delegate = self
            vezer!.connect()
        case .control:
            control = DashOSCListener(newListener, "Control udp listener", .control)
            control!.delegate = self
            control!.connect()
        }
    }
    
    
    func getPortForType(_ type: DashNetworkType.Listener, _ defaults: UserDefaultsProtocol = UserDefaults.standard) throws -> String {
        let keys = DashDefaultIDs.Network.Listener.self
        var portKey: String
        
        switch type {
        case .blackTrax:
            portKey = keys.blacktraxPort
        case .vezer:
            portKey = keys.vezerPort
        case .control:
            portKey = keys.controlPort
        }
        
        guard let port: String = getDefault(withKey: portKey, from: defaults) else {
            throw DashError.CantGetDefaultValueFor(portKey)
        }
        
        return port
    }
    
    
    func createNewListener(with port: String) throws  -> NWListener {
        let endpoint = NWEndpoint.Port(port)!
        let newListener = try NWListener(using: .udp, on: endpoint)
        return newListener
    }
}
