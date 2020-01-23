// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/7/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import Foundation
import SwiftOSC





class DashOSCClient {
    
    let type: DashNetworkType.Client
    let client: OSCClient

    var address: String { //"/dbaudio1/coordinatemapping/source_position_xy/"
        didSet {
            clientAddress(address)
        }
    }
    var port: Int {
        didSet {
            clientPort(port)
        }
    }

    
    init(_ type: DashNetworkType.Client, _ address: String, _ port: Int) {
        self.type = type
        self.address = address
        self.port = port
        client = OSCClient(address: address, port: port)
    }


    /// Only internal for mocking
    internal func clientSend(_ message: OSCElement) {
        client.send(message)
    }


    /// Only internal for mocking
    internal func clientAddress(_ newAddress: String) {
        client.address = newAddress
    }


    /// Only internal for mocking
    internal func clientPort(_ newPort: Int) {
        client.port = newPort
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
            let msg = makeMessage(each.addy(), each.x, each.y)
            bundle.add(msg)
        }
        
        clientSend(bundle)
    }
    
    
    /// Sends data to Vezer
    func send(data: [Vezer]) {
        let bundle = OSCBundle()
        
        for each in data {
            let msg = makeMessage(each.addy(), each.x, each.y)
            bundle.add(msg)
        }
        
        clientSend(bundle)
    }
    
    
    func printNetwork() {
        print("Client")
        print("|\tType: \(type)")
        print("|\tAddress: \(address)")
        print("|\tPort: \(port)")
    }
 }





fileprivate extension DashOSCClient {
    
    func makeMessage(_ address: String, _ data: OSCType?...) -> OSCMessage {
        return OSCMessage(OSCAddressPattern(address), data)
    }
    
    
    func makeMessage(_ address: String, _ data: [OSCType?]) -> OSCMessage {
        return OSCMessage(OSCAddressPattern(address), data)
    }
}
