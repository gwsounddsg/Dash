// ===================================================
// Created by:  GW Rodriguez
// Date:        12/24/19
// Copyright:   Copyright © 2019 GW Rodriguez. All rights reserved.
// ===================================================

import Foundation
import SwiftOSC





protocol DashOSCDelegate {
    func oscDataReceived(_ msg: Message)
}





class DashOSC {
    
    let client: OSCClient?
    let server: OSCServer?
    var delegate: DashOSCDelegate?
    
    
    init(client address: String, _ port: Int) {
        client = OSCClient(address: address, port: port)
        server = nil
    }
    
    
    init(server address: String, _ port: Int) {
        server = OSCServer(address: address, port: port)
        client = nil
    }
}





extension DashOSC: OSCServerDelegate {
    
    func didReceive(_ message: OSCMessage) {
        if let msg = getFloatsFrom(message) {
            delegate?.oscDataReceived(msg)
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
