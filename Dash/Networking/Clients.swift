// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/20/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import Foundation





class Clients {

    var vezer: DashOSCClient?
    var ds100Main: DashOSCClient?
    
    fileprivate(set) var isVezerConnected = false
    fileprivate(set) var isDS100MainConnected = false
    
    
    init(withObservers: Bool = true) {
        if withObservers {
            addObserver(#selector(preferenceChange), DashNotif.userPrefClientDS100MainIP)
            addObserver(#selector(preferenceChange), DashNotif.userPrefClientDS100MainPort)
            addObserver(#selector(preferenceChange), DashNotif.userPrefClientVezerIP)
            addObserver(#selector(preferenceChange), DashNotif.userPrefClientVezerPort)
        }
    }
    
    
    // MARK: - Connecting
    
    func connectAll(from defaults: UserDefaultsProtocol = UserDefaults.standard) -> [DashNetworkType.Client] {
        connectVezer(from: defaults)
        connectDS100Main(from: defaults)
        
        var badClients = [DashNetworkType.Client]()
        if !isVezerConnected {badClients.append(.vezer)}
        if !isDS100MainConnected {badClients.append(.ds100Main)}
        badClients.append(.ds100Backup)
        return badClients
    }
    
    
    func connectVezer(from defaults: UserDefaultsProtocol = UserDefaults.standard) {
        isVezerConnected = false
        
        do {
            try doConnectVezer(defaults)
            isVezerConnected = true
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    
    func connectDS100Main(from defaults: UserDefaultsProtocol = UserDefaults.standard) {
        isDS100MainConnected = false
        
        do {
            try doConnectDS100Main(defaults)
            isDS100MainConnected = true
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    
    // MARK: - Sending Messages
    
    func sendOSC(message: Message, to client: DashNetworkType.Client) -> Bool {
        switch client {
        case .vezer:
            if !isVezerConnected {return false}
            vezer!.send(message: message)
        
        case .ds100Main:
            if !isDS100MainConnected {return false}
            ds100Main!.send(message: message)
        
        case .ds100Backup:
            return false
        }
        
        return true
    }
    
    
    //TODO: when i add second ds100, change this so both are called even if both are not connected
    func send(ds100 data: [DS100]) -> Bool {
        if !isDS100MainConnected {return false}
        ds100Main!.send(data: data)
        return true
    }
    
    
    func send(vezer data: [Vezer]) -> Bool {
        if !isVezerConnected {return false}
        vezer?.send(data: data)
        return true
    }
    
    
    func printNetworks() {
        vezer?.printNetwork()
        ds100Main?.printNetwork()
    }
}





// MARK: - Notifications

extension Clients {
    
    @objc
    func preferenceChange(_ notif: Notification) {
        guard let userInfo = notif.userInfo as? [String: String] else {
            return
        }
        
        guard let data = userInfo[DashNotifData.userPref] else {
            return
        }
        
        switch notif.name {
        case DashNotif.userPrefClientDS100MainIP:
            ds100Main?.address = data
            
        case DashNotif.userPrefClientDS100MainPort:
            let val = Int(data)
            if val == nil {
                print("Bad DS100 Main port number for string: \(data)")
                return
            }
            ds100Main?.port = val!
            
        case DashNotif.userPrefClientVezerIP:
            vezer?.address = data
            
        case DashNotif.userPrefClientVezerPort:
            let val = Int(data)
            if val == nil {
                print("Bad Vezer port number for string: \(data)")
                return
            }
            vezer?.port = val!
            
        default:
            return
        }
    }
    
    
    fileprivate func addObserver(_ selector: Selector, _ name: NSNotification.Name?) {
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: nil)
    }
}





// MARK: - Utility

private extension Clients {
    
    func doConnectVezer(_ defaults: UserDefaultsProtocol) throws {
        let keys = DashDefaultIDs.Network.Outgoing.self
        
        guard let addy: String = getDefault(withKey: keys.recordedIP, from: defaults) else {
            vezer = nil
            throw DashError.CantGetDefaultValueFor(keys.recordedIP)
        }
        
        guard let port: Int = getDefault(withKey: keys.recordedPort, from: defaults) else {
            vezer = nil
            throw DashError.CantGetDefaultValueFor(keys.recordedPort)
        }
        
        if vezer == nil {
            vezer = DashOSCClient(.vezer, addy, port)
        }
        else {
            vezer!.address = addy
            vezer!.port = port
        }
    }
    
    
    func doConnectDS100Main(_ defaults: UserDefaultsProtocol) throws {
        let keys = DashDefaultIDs.Network.Outgoing.self
        
        guard let addy: String = getDefault(withKey: keys.liveIP, from: defaults) else {
            ds100Main = nil
            throw DashError.CantGetDefaultValueFor(keys.liveIP)
        }
        
        guard let port: Int = getDefault(withKey: keys.livePort, from: defaults) else {
            ds100Main = nil
            throw DashError.CantGetDefaultValueFor(keys.livePort)
        }
        
        if ds100Main == nil {
            ds100Main = DashOSCClient(.ds100Main, addy, port)
        }
        else {
            ds100Main!.address = addy
            ds100Main!.port = port
        }
    }
}
