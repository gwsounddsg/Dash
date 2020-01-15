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
        }
    }
    var port: Int {
        didSet {
            clientPort(port)
        }
    }
    
    init(_ type: DashNetworkType.Server, _ address: String, _ port: Int) {
        self.type = type
        self.address = address
        self.port = port
        server = OSCServer(address: address, port: port)
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
}





extension DashOSCServer: OSCServerDelegate {
    
    func didReceive(_ message: OSCMessage) {
        if let msg = getFloatsFrom(message) {
            delegate?.oscDataReceived(msg, type)
        }
        else {
            print(message.description)
        }
    }
    
    
    fileprivate func getFloatsFrom(_ message: OSCMessage) -> Message? {
        var floats = [Float]()
        
        for someType in message.arguments {
            if let val = someType as? Float {
                floats.append(val)
            }
            else if let val = someType as? Double {
                floats.append(Float(val))
            }
        }
        
        if floats.isEmpty {return nil}
        
        let msg = Message(message.address.string, floats)
        return msg
    }
}
