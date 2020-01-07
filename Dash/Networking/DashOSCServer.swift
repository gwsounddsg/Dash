// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/7/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import Foundation
import SwiftOSC





protocol DashOSCServerDelegate {
    func oscDataReceived(_ msg: Message)
}





class DashOSCServer {
    
    let type: DashOSCType.Server
    let server: OSCServer?
    var delegate: DashOSCServerDelegate?
    
    
    init(_ type: DashOSCType.Server, _ address: String, _ port: Int) {
        self.type = type
        server = OSCServer(address: address, port: port)
    }
}





extension DashOSCServer: OSCServerDelegate {
    
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
