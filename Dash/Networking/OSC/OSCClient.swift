//
// Created by GW Rodriguez on 11/18/22.
// Copyright (c) 2022 GW Rodriguez. All rights reserved.
//

import Foundation
import Network


class OSCClient {
    private var _client: NWConnection?
    private var _address: NWEndpoint.Host = "127.0.0.1"
    private var _port: NWEndpoint.Port = 1234
    private let _queue = DispatchQueue(label: "Dash OSCClient")


    init() {}


    init?(connect withAddress: NWEndpoint.Host, to port: NWEndpoint.Port) {
        connect(to: withAddress, with: port)
        if _client == nil {return nil}
    }
}




//MARK: - Connections
extension OSCClient {
    func connect(to address: NWEndpoint.Host, with port: NWEndpoint.Port) {
        _address = address
        _port = port

        _client = NWConnection(to: .hostPort(host: _address, port: _port), using: .udp)
        if _client == nil {
            return
        }

        _client!.stateUpdateHandler = { (newState) in
            switch newState {
            case .preparing:
                print("Entered state: preparing")
            case .ready:
                print("Entered state: ready")
            case .setup:
                print("Entered state: setup")
            case .cancelled:
                print("Entered state: cancelled")
            case .waiting:
                print("Entered state: waiting")
            case .failed:
                print("Entered state: failed")
            default:
                print("Entered an unknown state")
            }
        }

        _client!.start(queue: _queue)
    }


    func disconnect() {
        _client?.cancel()
    }
}





// MARK: - Sending
extension OSCClient {

}




// MARK: - Query
extension OSCClient {
    func isConnected() -> Bool {
        return _client != nil
    }


    func address() -> NWEndpoint.Host {
        return _address
    }


    func port() -> NWEndpoint.Port {
        return _port
    }
}