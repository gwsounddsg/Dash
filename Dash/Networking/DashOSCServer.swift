// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/7/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import Foundation
import SwiftOSC





protocol DashOSCServerDelegate: class {
    func oscDataReceived(_ msg: Message, _ from: DashNetworkType.Server)
}





class DashOSCServer {
    
    let type: DashNetworkType.Server
    let server: OSCServer
    weak var delegate: DashOSCServerDelegate?
    
    var address: String {
        didSet {
            clientAddress(address)
            printNetwork()
        }
    }
    var port: Int {
        didSet {
            clientPort(port)
            printNetwork()
        }
    }
    
    
    init(_ type: DashNetworkType.Server, _ address: String, _ port: Int) {
        self.type = type
        self.address = address
        self.port = port
        
        server = OSCServer(address: address, port: port)
        server.delegate = self
        start()
    }
    
    
    deinit {
        disconnect()
        delegate = nil
    }


    /// Only internal for mocking
    internal func clientAddress(_ newAddress: String) {
        server.address = newAddress
    }


    /// Only internal for mocking
    internal func clientPort(_ newPort: Int) {
        server.port = newPort
    }

    
    func start() {
        server.start()
    }
    
    
    func stop() {
        server.stop()
    }
    
    
    func disconnect() {
        if !server.running {return}
        stop()
    }
    
    
    func printNetwork() {
        print("Server")
        print("|\tType: \(type)")
        print("|\tAddress: \(address)")
        print("|\tPort: \(port)")
    }
}





// MARK: - OSCServerDelegate

extension DashOSCServer: OSCServerDelegate {

    func didReceive(_ message: OSCMessage) {
        let msg = Message(message.address.string, message.arguments)
        delegate?.oscDataReceived(msg, type)
    }
}
