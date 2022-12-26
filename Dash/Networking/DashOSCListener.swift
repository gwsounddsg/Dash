//
// Created by GW Rodriguez on 12/21/22.
// Copyright (c) 2022 GW Rodriguez. All rights reserved.
//

import Foundation
import Network


protocol DashListenerDelegate: AnyObject {
    func oscMessageReceived(_ message: OSCMessage, _ from: DashNetworkType.Server)
    func oscBundleReceived(_ bundle: OSCBundle, _ from: DashNetworkType.Server)
}





class DashListener {
    let address: String
    let port: NWEndpoint.Port
    let queue: DispatchQueue
    let type: DashNetworkType.Server

    weak var delegate: DashListenerDelegate?

    private var _listener: NWListener?
    private var _connection: NWConnection?


    init(_ address: String, _ port: Int, _ type: DashNetworkType.Server) {
        self.address = address
        self.port = NWEndpoint.Port(rawValue: UInt16(port))!
        self.type = type
    }
}





//MARK - Connection
extension DashListener {
    func connect() {
        do {_listener = try NWListener(using: .udp, on: port)}
        catch {print("Couldn't connect listener with error: \(error)")}

        setupConnectionHandler()
        setupConnectionHandler()

        _listener!.start(queue: queue)
        print("Started Listening")
    }


    private func setupStateHandler() {
        if _listener == nil {return}
        _listener!.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("Listening on port \(String(describing: self._listener!.port))")
            case .failed(let error):
                print("Listener failed with error: \(error)")
            default:
                print("Unhandled state for listener")
            }
        }
    }


    private func setupConnectionHandler() {
        if _listener == nil {return}
        _listener!.newConnectionHandler = { [weak self] connection in
            guard let strongSelf = self else {
                print("Error: weak self")
                return
            }

            connection.start(queue: strongSelf.queue)
            strongSelf.createConnection(connection)
        }
    }


    private func createConnection(_ connection: NWConnection)  {
        _connection = connection
        _connection?.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("Listener ready to receive message: \(connection)")
                self.receive()
            default:
                print("Create connection state: \(state)")
            }
        }
    }
}





// MARK: Relaying
fileprivate extension DashListener {
    func receive() {
        _connection?.receiveMessage { completeContent, contentContext, isComplete, error in
            if self.delegate == nil {return}
            if error != nil {
                print("Listener receive error: \()")
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


    private func sendToDelegate(_ data: Data) {
        let forwardSlash = 0x2f

        if data[0] == forwardSlash {
            sendMessageToDelegate(data)
        }
        else {
            sendBundleToDelegate(data)
        }
    }


    private func sendMessageToDelegate(_ data: Data) {
        do {
            let message = try OSCParseMessage(data)
            delegate!.oscMessageReceived(message, type)
        }
        catch {
            print("Error parsing received osc packet: \(error)")
        }
    }


    private func sendBundleToDelegate(_ data: Data) {
        do {
            let bundle = try OSCParseBundle(data)
            delegate!.oscBundleReceived(bundle, type)
        }
        catch {
            print("Error parsing received osc bundle: \(error)")
        }
    }
}