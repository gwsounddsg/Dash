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
    let type: DashNetworkType.Listener
    var delegate: DashListenerDelegate?

    internal var _listener: NWListenerProtocol
    internal var _connection: NWConnectionProtocol?

    private var _queue: DispatchQueue

    
    init(_ listener: NWListenerProtocol, _ queueName: String, _ type: DashNetworkType.Listener) {
        _listener = listener
        _queue = DispatchQueue(label: queueName)
        self.type = type
    }


    deinit {
        _listener.cancel()
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
    
    
    //MARK: - Getters
    
    func port() -> Int {
        return Int(_listener.port!.rawValue)
    }
    
    
    func queue() -> String {
        return _queue.label
    }


    func printNetwork() {
        print("DashListener:")
        print("|\ttype: \(type)")
        print("|\tport: \(port())")
        print("|\tqueue: \(_queue.label)")
    }
}





//MARK: - Connection
extension DashListener {
    func connect() {
        setupConnectionHandler()
        setupConnectionHandler()

        _listener.start(queue: _queue)
        print("Started Listening to port: \(port()) on queue: \(_queue.label)")
    }


    private func setupStateHandler() {
        _listener.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("Listening on port \(String(describing: self._listener.port))")
            case .failed(let error):
                print("Listener failed with error: \(error)")
            default:
                print("Unhandled state for listener")
            }
        }
    }


    private func setupConnectionHandler() {
        _listener.newConnectionHandler = { [weak self] connection in
            guard let strongSelf = self else {
                print("Error: weak self")
                return
            }

            connection.start(queue: strongSelf._queue)
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
