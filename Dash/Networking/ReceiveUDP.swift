// ===================================================
// Created by:  GW Rodriguez
// Date:        12/24/19
// Copyright:   Copyright © 2019 GW Rodriguez. All rights reserved.
// ===================================================

import Foundation
import CocoaAsyncSocket
import RTTrPSwift





protocol ReceiveUDPDelegate: AnyObject {
    func newPacket(_ data: RTTrP)
}





class ReceiveUDP: NSObject, GCDAsyncUdpSocketDelegate {
    
    var delegate: ReceiveUDPDelegate? {
        get {return _delegate}
        set {_delegate = newValue}
    }
    
    internal var _socket: GCDAsyncUdpSocket!
    internal weak var _delegate: ReceiveUDPDelegate?
    
    
    
    
    
    // MARK: - Basic
    
    class func startWith(port: Int, and aDelegate: ReceiveUDPDelegate) throws -> ReceiveUDP {
        let receive = ReceiveUDP()
        receive._delegate = aDelegate
        try receive.connect(port: port)
        return receive
    }





    // MARK: - Socket Delegate
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        do {
            let receivedData = try RTTrP(data: data.bytes)
            delegate?.newPacket(receivedData)
        }
        catch {
            print(error)
        }
    }





    // MARK: - Utility
    
    func connect(port: Int, socket: GCDAsyncUdpSocket = GCDAsyncUdpSocket(delegate: nil, delegateQueue: DispatchQueue.main)) throws {
        if _socket != nil {
            _socket.close()
        }
        else {
            _socket = socket
            _socket.setDelegate(self)
        }
        
        try _socket.bind(toPort: UInt16(port))
        try _socket.beginReceiving()
    }
    
    
    func isIPv4Enabled() -> Bool {
        return _socket.isIPv4Enabled()
    }
    

    func connectedPort() -> Int {
        return Int(_socket.connectedPort())
    }
    
    
    func localAddress() -> String {
        return _socket.localHost() ?? ""
    }
    
    
    func localPort() -> Int {
        if _socket == nil {return 0}
        return Int(_socket.localPort())
    }
    
    
    func printNetwork() {
        print("Receive UDP")
        print("|\tPort: \(localPort())")
    }
}
