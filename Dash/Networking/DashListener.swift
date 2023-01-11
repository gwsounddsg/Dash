//
// Created by GW Rodriguez on 1/6/23.
// Copyright (c) 2023 GW Rodriguez. All rights reserved.
//

import Foundation
import Network


protocol DashListenerDelegate {
    func listenerReceived(_ data: Data, _ from: DashNetworkType.Listener)
}





class DashListener {
    let address: String
    let port: NWEndpoint.Port
    let queue: DispatchQueue
    let type: DashNetworkType.Listener

    var delegate: DashListenerDelegate?

    internal var _listener: NWListener?
    internal var _connection: NWConnectionProtocol?


    init(_ address: String, _ port: Int, _ queueName: String, _ type: DashNetworkType.Listener) {
        self.address = address
        self.port = NWEndpoint.Port(rawValue: UInt16(port))!
        self.type = type
        queue = DispatchQueue(label: queueName)
    }


    deinit {
        _listener?.cancel()
    }


    func receive() {
        _connection?.receiveMessage { completeContent, contentContext, isComplete, error in
            if self.delegate == nil {return}

            if error != nil {
                print("Listener receive error: \(String(describing: error))")
                return
            }

            if let newData = completeContent {
                self.delegate?.listenerReceived(newData, self.type)
            }

            self.receive() // loop
        }
    }


    func printNetwork() {
        print("DashListener:")
        print("|\ttype: \(type)")
        print("|\taddress: \(address)")
        print("|\tport: \(port)")
        print("|\tqueue: \(queue.label)")
    }
}





//MARK: - Connection
extension DashListener {
    func connect() {
        do {_listener = try NWListener(using: .udp, on: port)}
        catch {print("Couldn't connect listener with error: \(error)")}

        setupConnectionHandler()
        setupConnectionHandler()

        _listener!.start(queue: queue)
        print("Started Listening to port: \(port) on queue: \(queue.label)")
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
