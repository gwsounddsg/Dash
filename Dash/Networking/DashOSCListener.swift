//
// Created by GW Rodriguez on 12/21/22.
// Copyright (c) 2022 GW Rodriguez. All rights reserved.
//

import Foundation
import Network


protocol DashOSCListenerDelegate: AnyObject {
    func oscMessageReceived(_ message: OSCMessage, _ from: DashNetworkType.Listener)
    func oscBundleReceived(_ bundle: OSCBundle, _ from: DashNetworkType.Listener)
}





class DashOSCListener: DashListener {
    weak var oscDelegate: DashOSCListenerDelegate?


    override func receive() {
        _connection?.receiveMessage { completeContent, contentContext, isComplete, error in
            if self.oscDelegate == nil {return}
            if error != nil {
                print("Listener receive error: \(String(describing: error))")
                return
            }

            guard let newData = completeContent else {
                print("Listener receive data nil")
                return
            }

            self.sendToDelegate(newData)
            self.receive() // loop
        }
    }
}





// MARK: Relaying
private extension DashOSCListener {
    func sendToDelegate(_ data: Data) {
        let forwardSlash = 0x2f

        if data[0] == forwardSlash {
            sendMessageToDelegate(data)
        }
        else {
            sendBundleToDelegate(data)
        }
    }


    func sendMessageToDelegate(_ data: Data) {
        do {
            let message = try OSCParseMessage(data)
            oscDelegate!.oscMessageReceived(message, type)
        }
        catch {
            print("Error parsing received osc packet: \(error)")
        }
    }


    func sendBundleToDelegate(_ data: Data) {
        do {
            let bundle = try OSCParseBundle(data)
            oscDelegate!.oscBundleReceived(bundle, type)
        }
        catch {
            print("Error parsing received osc bundle: \(error)")
        }
    }
}