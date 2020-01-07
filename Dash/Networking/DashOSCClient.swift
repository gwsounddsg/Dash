// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/7/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import Foundation
import SwiftOSC





class DashOSCClient {
    
    let type: DashOSCType.Client
    let client: OSCClient
    
    fileprivate let _address = "/dbaudio1/coordinatemapping/source_position_xy/"
    
    
    init(_ type: DashOSCType.Client, _ address: String, _ port: Int) {
        self.type = type
        client = OSCClient(address: address, port: port)
    }
    
    
    /// Regular OSC message
    func send(message: Message) {
        let msg = makeMessage(message.address, message.values)
        clientSend(msg)
    }
    
    
    /// Sends data to DS100
    func send(data: [DS100]) {
        let bundle = OSCBundle()
        
        for each in data {
            let dest = _address + each.addy()
            let msg = makeMessage(dest, each.x, each.y)
            bundle.add(msg)
        }
        
        clientSend(bundle)
    }
}





fileprivate extension DashOSCClient {
    
    func makeMessage(_ address: String, _ data: OSCType?...) -> OSCMessage {
        return OSCMessage(OSCAddressPattern(address), data)
    }
    
    
    func makeMessage(_ address: String, _ data: [OSCType?]) -> OSCMessage {
        return OSCMessage(OSCAddressPattern(address), data)
    }
    
    
    func clientSend(_ message: OSCElement) {
        client.send(message)
    }
}
