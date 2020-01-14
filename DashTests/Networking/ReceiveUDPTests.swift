// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/14/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import XCTest
import CocoaAsyncSocket
@testable import Dash





class ReceiveUDPTests: XCTestCase {

    var receive: ReceiveUDP!
    var mockSock: MockGCDAsyncUdpSocket!
}





extension ReceiveUDPTests {
    
    func testReceiveUDP() {
        
    }
}





// MARK: - Mocks
class MockGCDAsyncUdpSocket: GCDAsyncUdpSocket {
    
    var invokedInitParameters: (delegate: GCDAsyncUdpSocketDelegate?, queue: DispatchQueue?)?
    var invokedInitParametersList = [(delegate: GCDAsyncUdpSocketDelegate?, queue: DispatchQueue?)]()
    
    var invokedBindToPort: UInt16 = 0
    var invokedBeginReceiving = false
    var stubIsIPv4Enabled = true
    var stubIsConnected = true
    var invokedConnectedHost = ""
    var invokedConnectedPort: UInt16 = 0
    var invokedLocalHost = ""
    var invokedLocalPort: UInt16 = 0
    
    
    override init(delegate aDelegate: GCDAsyncUdpSocketDelegate?, delegateQueue dq: DispatchQueue?) {
        super.init(delegate: aDelegate, delegateQueue: dq)
        invokedInitParameters = (aDelegate, dq)
        invokedInitParametersList.append(invokedInitParameters!)
    }
    
    override func bind(toPort port: UInt16) throws {
        invokedBindToPort = port
    }
    
    override func beginReceiving() throws {
        invokedBeginReceiving = true
    }
    
    override func isIPv4Enabled() -> Bool {
        return stubIsIPv4Enabled
    }
    
    override func isConnected() -> Bool {
        return stubIsConnected
    }
    
    override func connectedHost() -> String? {
        return invokedConnectedHost
    }
    
    override func connectedPort() -> UInt16 {
        return invokedConnectedPort
    }
    
    override func localHost() -> String? {
        return invokedLocalHost
    }
    
    override func localPort() -> UInt16 {
        return invokedLocalPort
    }
}
