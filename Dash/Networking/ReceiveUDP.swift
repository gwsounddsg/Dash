// ===================================================
// Created by:  GW Rodriguez
// Date:        12/24/19
// Copyright:   Copyright © 2019 GW Rodriguez. All rights reserved.
// ===================================================

import Foundation
import CocoaAsyncSocket
import RTTrPSwift





protocol ReceiveUDPDelegate: class {
    func newPacket(_ data: RTTrP)
}





class ReceiveUDP: NSObject, GCDAsyncUdpSocketDelegate {
    
    var delegate: ReceiveUDPDelegate? {
        get {return _delegate}
        set {_delegate = newValue}
    }
    
    internal var _socket: GCDAsyncUdpSocket!
    internal weak var _delegate: ReceiveUDPDelegate?
    
    
    override init() {
        super.init()
        _socket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
    }
    
    
    
    
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
    
    func connect(port: Int) throws {
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
        return Int(_socket.localPort())
    }
}
