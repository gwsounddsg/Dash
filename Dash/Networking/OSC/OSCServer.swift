//
// Created by GW Rodriguez on 11/22/22.
// Copyright (c) 2022 GW Rodriguez. All rights reserved.
//

import Foundation
import Network


protocol OSCServerDelegate {
    func packetReceived(data: Data)
}





class OSCServer {
    let delegate: OSCServerDelegate
    var queue: DispatchQueue {
        get {return _queue}
    }

    private let _queue:DispatchQueue
    private var _listener: NWListener?
    private var _port: NWEndpoint.Port
    private var _connection: NWConnection?


    init(on port: Int, and label: String, delegate: OSCServerDelegate) {
        _queue = DispatchQueue(label: label)
        self.delegate = delegate
        _port = NWEndpoint.Port(String(port))!
    }


    init?(with listener: NWListener, and label: String, delegate: OSCServerDelegate) {
        if listener.port == nil {return nil}

        _port = listener.port!
        _listener = listener
        _queue = DispatchQueue(label: label)
        self.delegate = delegate
    }
}





// MARK: - Starting
extension OSCServer {
    func start() -> Bool {
        do {
            _listener = try NWListener(using: .udp, on: _port)
        }
        catch let error {
            print("Couldn't connect listener with error: \(error)")
            return false
        }

        setupUpdateHandler()
        setupConnectionHandler()
        return true
    }


    private func setupUpdateHandler() {
        _listener!.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                print("Listening on port: \(String(describing: self._port))")
            case .failed (let error):
                print("Listener failed with error: \(error)")
            default:
                print("Unhandled case for listener update handler: \(newState)")
            }
        }
    }


    private func setupConnectionHandler() {
        _listener!.newConnectionHandler = { [weak self] newConnection in
            guard let strongSelf = self else {
                print("Error: weak self")
                return
            }

            newConnection.start(queue: strongSelf.queue)
            strongSelf.createConnection(newConnection)
            print("NEW CONNECTION")
        }
        _listener!.start(queue: _queue)
        print("Starting Listening for: \(_queue.label)")
    }


    private func createConnection(_ connection: NWConnection) {
        print("Creating Connection")
        _connection = connection

        _connection?.stateUpdateHandler = { newState in
            switch newState {
            case .ready:
                print("Listener ready to receive message - \(String(describing: self._connection))")
                self.receive()
            default:
                print("Create Connection state: \(newState)")
            }
        }
    }
}





// MARK: - Other
extension OSCServer {
    func stop() {
        _listener?.cancel()
        _listener = nil
    }


    func receive() {
        _connection?.receiveMessage { completeContent, contentContext, isComplete, error in
            if error != nil {
                print("Receive error: \(String(describing: error))")
                return
            }

            guard let newData = completeContent else {
                print("Received data nil")
                return
            }

            self.delegate.packetReceived(data: newData)
            self.receive() // loop
        }
    }
}
