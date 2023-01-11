// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/14/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import XCTest
import RTTrPSwift
@testable import Dash





// swiftlint:disable weak_delegate

class ReceiveUDPTests: XCTestCase {

    var receive: ReceiveUDP!
    var mockSock: MockGCDAsyncUdpSocket!
    var mockDelegate: MockReceiveUDPDelegate!
}





extension ReceiveUDPTests {
    
    func testReceiveUDP() {
        receive = ReceiveUDP()
        XCTAssertNil(receive._socket)
    }


    func testReceiveUDP_startWith() {
        mockDelegate = MockReceiveUDPDelegate()

        do {
            receive = try ReceiveUDP.startWith(port: 1234, and: mockDelegate)
        }
        catch {
            XCTAssertFalse(false, error.localizedDescription)
            return
        }

        XCTAssertEqual(receive.localPort(), 1234)
        XCTAssertEqual(receive.delegate.debugDescription, mockDelegate.debugDescription)
    }
}





extension ReceiveUDPTests {

    func testReceiveUDP_udpSocket() {
        initMocks()
        receive.udpSocket(mockSock, didReceive: Data(rttData), fromAddress: Data(), withFilterContext: nil)
        XCTAssertTrue(mockDelegate.invokedNewPacket)
    }


    func testReceiveUDP_connectPort_sockNil() {
        initMocks()
        receive._socket = nil
        let port = 1234

        do {
            try receive.connect(port: port, socket: mockSock)
        }
        catch {
            XCTAssertFalse(false, error.localizedDescription)
            return
        }

        XCTAssertFalse(mockSock.invokedClose)
        XCTAssertTrue(mockSock.invokedSetDelegateParameters === receive)
        XCTAssertEqual(mockSock.invokedBindToPort, UInt16(port))
        XCTAssertTrue(mockSock.invokedBeginReceiving)
    }
    
    
    func testReceiveUDP_connectPort_sockNotNil() {
        initMocks()
        receive._socket = nil
        let port = 1234
        
        do {
            try receive.connect(port: 4, socket: mockSock)
            mockSock.invokedClose = false
            mockSock.invokedSetDelegate = false
            mockSock.invokedSetDelegateParameters = nil
            mockSock.invokedBindToPort = 0
            mockSock.invokedBeginReceiving = false
            try receive.connect(port: port)
        }
        catch {
            XCTAssertFalse(false, error.localizedDescription)
            return
        }
        
        XCTAssertTrue(mockSock.invokedClose)
        XCTAssertFalse(mockSock.invokedSetDelegate)
        XCTAssertEqual(mockSock.invokedBindToPort, UInt16(port))
        XCTAssertTrue(mockSock.invokedBeginReceiving)
    }


    func testReceiveUDP_isIPv4Enabled() {
        initMocks()
        _ = receive.isIPv4Enabled()
        XCTAssertTrue(mockSock.invokedIsIPv4Enabled)
    }


    func testReceiveUDP_connectedPort() {
        initMocks()
        _ = receive.connectedPort()
        XCTAssertTrue(mockSock.invokedConnectedPort)
    }


    func testReceiveUDP_localAddress() {
        initMocks()
        _ = receive.localAddress()
        XCTAssertTrue(mockSock.invokedLocalAddress)
    }


    func testReceiveUDP_localPort() {
        initMocks()
        _ = receive.localPort()
        XCTAssertTrue(mockSock.invokedLocalPort)
    }
}





extension ReceiveUDPTests {

    func initMocks() {
        receive = ReceiveUDP()
        mockDelegate = MockReceiveUDPDelegate()
        mockSock = MockGCDAsyncUdpSocket(delegate: receive, delegateQueue: nil)

        receive._socket = mockSock
        receive.delegate = mockDelegate
    }
}





// MARK: - Mocks
class MockGCDAsyncUdpSocket: GCDAsyncUdpSocket {

    var invokedBindToPort: UInt16 = 0
    var invokedBeginReceiving = false
    var invokedIsIPv4Enabled = false
    var invokedConnectedPort = false
    var invokedLocalAddress = false
    var invokedLocalPort = false
    var invokedClose = false


    override func bind(toPort port: UInt16) throws {
        invokedBindToPort = port
    }

    override func beginReceiving() throws {
        invokedBeginReceiving = true
    }

    override func isIPv4Enabled() -> Bool {
        invokedIsIPv4Enabled = true
        return invokedIsIPv4Enabled
    }

    override func connectedPort() -> UInt16 {
        invokedConnectedPort = true
        return 0
    }

    override func localHost() -> String? {
        invokedLocalAddress = true
        return ""
    }

    override func localPort() -> UInt16 {
        invokedLocalPort = true
        return 0
    }
    
    override func close() {
        invokedClose = true
    }
    
    var invokedSetDelegate = false
    var invokedSetDelegateParameters: GCDAsyncUdpSocketDelegate?
    override func setDelegate(_ delegate: GCDAsyncUdpSocketDelegate?) {
        invokedSetDelegate = true
        invokedSetDelegateParameters = delegate
    }
}


class MockReceiveUDPDelegate: ReceiveUDPDelegate {

    var invokedNewPacket = false
    var invokedNewPacketCount = 0
    var invokedNewPacketParameters: (data: RTTrP, Void)?
    var invokedNewPacketParametersList = [(data: RTTrP, Void)]()

    func newPacket(_ data: RTTrP) {
        invokedNewPacket = true
        invokedNewPacketCount += 1
        invokedNewPacketParameters = (data, ())
        invokedNewPacketParametersList.append((data, ()))
    }
}
