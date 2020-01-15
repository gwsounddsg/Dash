// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/15/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import XCTest
import SwiftOSC
@testable import Dash



// swiftlint:disable force_cast


class DashOSCClientTests: XCTestCase {

    fileprivate var _client: MockDashOSCClient!
    let address = "/test/message/"
    let port: Int = 1234


    override func setUp() {
        _client = MockDashOSCClient(.recorded, address, port)
    }

    override func tearDown() {
        _client = nil
    }
}





extension DashOSCClientTests {

    func testDashOSCClient() {
        XCTAssertEqual(_client.type, .recorded)
        XCTAssertEqual(_client.address, address)
        XCTAssertEqual(_client.port, port)

        XCTAssertEqual(_client.invokedClientAddressList.count, 0)
        XCTAssertEqual(_client.invokedClientPortList.count, 0)
    }


    func testDashOSCClient_address() {
        let newAddy = "/something/different"
        _client.address = newAddy
        XCTAssertEqual(_client.invokedClientAddressParameter, newAddy)
    }


    func testDashOSCClient_port() {
        let newPort = 4444
        _client.port = newPort
        XCTAssertEqual(_client.invokedClientPortParameter, newPort)
    }
}





extension DashOSCClientTests {

    func testDashOSCClient_sendMessage() {
        let addy = "/send/message/"
        let vals: [Float] = [1.0, 2.0]
        let msg = Message(addy, vals)

        _client.send(message: msg)

        if !_client.invokedClientSend {
            XCTAssertTrue(_client.invokedClientSend)
            return
        }

        let oscMsg = _client.invokedClientSendParameter as! OSCMessage

        XCTAssertEqual(oscMsg.address.string, addy)
        XCTAssertEqual(oscMsg.arguments.count, vals.count)
        XCTAssertEqual(oscMsg.arguments[0]?.data, vals[0].data)
        XCTAssertEqual(oscMsg.arguments[1]?.data, vals[1].data)
    }


    func testDashOSCClient_sendData() {
        let mapping = "myMap"
        let input = "something"
        let x: Double = 5.0
        let y: Double = 6.0
        let data = DS100(mapping, input: input, x: x, y: y)

        _client.send(data: [data])

        XCTAssertTrue(_client.invokedClientSend)
        if !_client.invokedClientSend {return}

        let oscBundle = _client.invokedClientSendParameter as! OSCBundle
        XCTAssertEqual(oscBundle.elements.count, 1)
        if oscBundle.elements.count != 1 {return}

        guard let oscMsg = oscBundle.elements[0] as? OSCMessage else {
            XCTAssertFalse(true, "osc element is not an OSCMessage")
            return
        }

        XCTAssertEqual(oscMsg.address.string, _client.address + data.addy())
        XCTAssertEqual(oscMsg.arguments.count, 2)
        XCTAssertEqual(oscMsg.arguments[0]?.data, x.data)
        XCTAssertEqual(oscMsg.arguments[1]?.data, y.data)
    }
}





// MARK: - Mocks

private class MockDashOSCClient: DashOSCClient {

    var invokedClientSend = false
    var invokedClientSendParameter: OSCElement?
    var invokedClientSendList = [OSCElement]()

    var invokedClientAddress = false
    var invokedClientAddressParameter: String?
    var invokedClientAddressList = [String]()

    var invokedClientPort = false
    var invokedClientPortParameter: Int?
    var invokedClientPortList = [Int]()


    override func clientSend(_ message: OSCElement) {
        invokedClientSend = true
        invokedClientSendParameter = message
        invokedClientSendList.append(message)
    }

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
}