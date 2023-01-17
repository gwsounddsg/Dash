// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/7/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import Foundation
import Network





class DashOSCClient {
    let type: DashNetworkType.Client
    let _client: OSCClient

    private var _port: Int
    private var _address: String


    init(_ type: DashNetworkType.Client, _ address: String, _ port: Int, _ client: OSCClient = OSCClient()) {
        _port = port
        _address = address
        self.type = type
        _client = client

        connect()
    }
    

    internal func clientSend(_ element: OSCElement) {
        _client.send(element)
    }


    internal func connect() {
        if _client.isConnected() {_client.disconnect()}
        _client.connect(to: NWEndpoint.Host(_address), with: NWEndpoint.Port(String(_port))!)
    }

    
    func printNetwork() {
        print("Client")
        print("|\tType: \(type)")
        print("|\tAddress: \(_address)")
        print("|\tPort: \(_port)")
    }


    //MARK: - Getters / Setters
    func port() -> Int {
        return _port
    }


    func setPort(_ newPort: Int) {
        _port = newPort
        connect()
    }


    func address() -> String {
        return _address
    }


    func setAddress(_ newAddress: String) {
        _address = newAddress
        connect()
    }


    func changeEndpoints(_ address: String, _ port: Int) {
        _address = address
        _port = port
        connect()
    }
}





//MARK: - Sending
extension DashOSCClient {
    /// Regular OSC message
    func send(message: OSCMessage) {
        clientSend(message)
    }

    
    /// Sends data to DS100
    func send(data: [DS100], coordinate: Coordinate) {
        var bundle = OSCBundle()
        var addy: String = ""
        var msg: OSCMessage!
        
        for each in data {
            switch coordinate {
            case .x:
                addy = each.coordinateX()
                msg = OSCMessage(addy, [each.x])
            case .y:
                addy = each.coordinateY()
                msg = OSCMessage(addy, [each.y])
            case .z, .all:
                addy = each.coordinate()
                msg = OSCMessage(addy, [each.x, each.y])
            }
            
            bundle.add(msg)
        }
        
        clientSend(bundle)
    }
    
    
    /// Sends data to Vezer
    func send(data: [Vezer]) {
        var bundle = OSCBundle()
        
        for each in data {
            let addy = each.addy()
            let msgX = OSCMessage(addy.x, [each.x])
            let msgY = OSCMessage(addy.y, [each.y])
            bundle.add(msgX, msgY)
        }
        
        clientSend(bundle)
    }
 }
