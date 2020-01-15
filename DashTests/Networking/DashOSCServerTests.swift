// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/15/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import XCTest
import SwiftOSC
@testable import Dash





class DashOSCServerTests: XCTestCase {

    var server: MockDashOSCServer!
    let address = "/test/message/"
    let port: Int = 1234

    override func setUp() {
        server = MockDashOSCServer(.control, address, port)
    }

    override func tearDown() {
        server = nil
    }
}





extension DashOSCServerTests {

    func testDashOSCServer() {
        XCTAssertEqual(server.type, .control)
        XCTAssertEqual(server.address, address)
        XCTAssertEqual(server.port, port)

        XCTAssertEqual(server.invokedClientAddressList.count, 0)
        XCTAssertEqual(server.invokedClientPortList.count, 0)
    }


    func testDashOSCServer_didReceive() {
        let val: Float = 4.0
        let msg = OSCMessage(OSCAddressPattern("/something"), val)
        let delegate = MockDashOSCServerDelegate()
        server.delegate = delegate

        server.didReceive(msg)

        XCTAssertEqual(delegate.invokedOscDataReceivedParameters?.msg.address, msg.address.string)
        XCTAssertEqual(delegate.invokedOscDataReceivedParameters?.msg.values[0].data, msg.arguments[0]?.data)
        XCTAssertEqual(delegate.invokedOscDataReceivedParameters?.from, .control)
    }
}





// MARK: - Mocks

class MockDashOSCServer: DashOSCServer {

    var invokedClientAddress = false
    var invokedClientAddressParameter: String?
    var invokedClientAddressList = [String]()

    var invokedClientPort = false
    var invokedClientPortParameter: Int?
    var invokedClientPortList = [Int]()

    var invokedStart = false
    var invokedStop = false

    override func clientAddress(_ newAddress: String) {
        invokedClientAddress = true
        invokedClientAddressParameter = newAddress
        invokedClientAddressList.append(newAddress)
    }

    override func clientPort(_ newPort: Int) {
        invokedClientPort = true
        invokedClientPortParameter = newPort
        invokedClientPortList.append(newPort)
    }

    override func start() {
        invokedStart = true
    }

    override func stop() {
        invokedStop = true
    }
}


class MockDashOSCServerDelegate: DashOSCServerDelegate {

    var invokedOscDataReceived = false
    var invokedOscDataReceivedCount = 0
    var invokedOscDataReceivedParameters: (msg: Message, from: DashNetworkType.Server)?
    var invokedOscDataReceivedParametersList = [(msg: Message, from: DashNetworkType.Server)]()

    func oscDataReceived(_ msg: Message, _ from: DashNetworkType.Server) {
        invokedOscDataReceived = true
        invokedOscDataReceivedCount += 1
        invokedOscDataReceivedParameters = (msg, from)
        invokedOscDataReceivedParametersList.append((msg, from))
    }
}