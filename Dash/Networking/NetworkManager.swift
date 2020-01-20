// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/7/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import Foundation
import RTTrPSwift










class NetworkManager {
    
    let servers = Servers()
    let clients = Clients()
    
    
    func sendOSC(message: Message, to client: DashNetworkType.Client) -> Bool {
        return clients.sendOSC(message: message, to: client)
    }
    
    
    func send(ds100 data: [DS100]) -> Bool {
        return clients.send(ds100: data)
    }
    
    
    // swiftlint:disable opening_brace
    func connectAll(from defaults: UserDefaultsProtocol = UserDefaults.standard) -> (clients: [DashNetworkType
    .Client], servers: [DashNetworkType.Server])
    {
        let badClients = clients.connectAll(from: defaults)
        let badServers = servers.connectAll(from: defaults)
        
        return (clients: badClients, servers: badServers)
    }
    // swiftlint:enable opening_brace
}
