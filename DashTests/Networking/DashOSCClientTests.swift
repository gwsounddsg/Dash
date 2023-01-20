// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/15/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import XCTest
@testable import Dash
import Network



// swiftlint:disable force_cast


class DashOSCClientTests: XCTestCase {
    let type: DashNetworkType.Client = .vezer
    let hostname: String = "127.0.0.1"
    let port: Int = 1234
    let address = "/test/message/"
    var client: DashOSCClient!
    var mClient: MockOSCClient!


    override func setUp() {
        mClient = MockOSCClient()
        client = DashOSCClient(type, hostname, port, mClient)
    }
}





extension DashOSCClientTests {

    func testDashOSCClient() {
        XCTAssertEqual(client.type, type)
        XCTAssertEqual(client.address(), hostname)
        XCTAssertEqual(client.port(), port)
    }


    func testDashOSCClient_clientSend() {
        let message = OSCMessage("foo", [])
        client.clientSend(message)

        XCTAssertTrue(mClient.invokedSend)
        if mClient.invokedSendParameters == nil {return}

        guard let sentMsg = mClient.invokedSendParameters?.element as? OSCMessage else {
           XCTFail("element is not an OSCMessage")
            return
        }

        XCTAssertEqual(sentMsg.address, message.address)
    }


    func testDashOSCClient_connect_isConnected() {
        mClient.stubbedIsConnectedResult = true

        client.connect()

        XCTAssertTrue(mClient.invokedDisconnect)
        XCTAssertTrue(mClient.invokedConnect)
    }


    func testDashOSCClient_connect_isNotConnected() {
        client.connect()

        XCTAssertFalse(mClient.invokedDisconnect)
        XCTAssertTrue(mClient.invokedConnect)
    }
}





//MARK: - Getters / Setters
extension DashOSCClientTests {

    func testDashOSCClient_port() {
        let clientPort = client.port()
        XCTAssertEqual(clientPort, port)
    }


    func testDashOSCClient_setPort() {
        let newPort = 9876
        client.setPort(newPort)

        XCTAssertEqual(client.port(), newPort)
        XCTAssertTrue(mClient.invokedConnect)
    }


    func testDashOSCClient_address() {
        let clientAddress = client.address()
        XCTAssertEqual(clientAddress, hostname)
    }


    func testDashOSCClient_setAddress() {
        let newAddress = "9.9.9.9"
        client.setAddress(newAddress)

        XCTAssertEqual(client.address(), newAddress)
        XCTAssertTrue(mClient.invokedConnect)
    }
}





//MARK: - Sending
extension DashOSCClientTests {

    func testDashOSCClient_send() {
        let vals: [Float] = [1.0, 2.0]
        let msg = OSCMessage(address, vals)

        client.send(message: msg)

        XCTAssertEqual(mClient.invokedSendCount, 1)
        XCTAssertNotNil(mClient.invokedSendParameters)
        if let sentMsg = mClient.invokedSendParameters?.element {
            XCTAssertEqual(sentMsg.data, msg.data)
        }
    }


    func testDashOSCClient_sendData_all() {
        let mapping = "myMap"
        let input = "something"
        let x: Float = 5.0
        let y: Float = 6.0
        let data = DS100(mapping, input: input, x: x, y: y, spread: 0.5)
        let coord: Coordinate = .all

        client.send(data: [data], coordinate: coord)

        XCTAssertTrue(mClient.invokedSend)
        if !mClient.invokedSend {return}

        let oscBundle = mClient.invokedSendParameters!.element as! OSCBundle
        XCTAssertEqual(oscBundle.elements.count, 1)
        if oscBundle.elements.count != 1 {return}

        guard let oscMsg = oscBundle.elements[0] as? OSCMessage else {
            XCTAssertFalse(true, "osc element is not an OSCMessage")
            return
        }

        XCTAssertEqual(oscMsg.address, data.coordinate())
        XCTAssertEqual(oscMsg.arguments.count, 2)
        XCTAssertEqual(oscMsg.arguments[0]?.data, x.data)
        XCTAssertEqual(oscMsg.arguments[1]?.data, y.data)
    }
    
    
    func testDashOSCClient_sendData_x() {
        let mapping = "myMap"
        let input = "something"
        let x: Float = 5.0
        let y: Float = 6.0
        let data = DS100(mapping, input: input, x: x, y: y, spread: 0.5)
        let coord: Coordinate = .x
        
        client.send(data: [data], coordinate: coord)
        
        XCTAssertTrue(mClient.invokedSend)
        if !mClient.invokedSend {return}
        
        let oscBundle = mClient.invokedSendParameters!.element as! OSCBundle
        XCTAssertEqual(oscBundle.elements.count, 1)
        if oscBundle.elements.count != 1 {return}
        
        guard let oscMsg = oscBundle.elements[0] as? OSCMessage else {
            XCTAssertFalse(true, "osc element is not an OSCMessage")
            return
        }
        
        XCTAssertEqual(oscMsg.address, data.coordinateX())
        XCTAssertEqual(oscMsg.arguments.count, 1)
        XCTAssertEqual(oscMsg.arguments[0]?.data, x.data)
    }
    
    
    func testDashOSCClient_sendData_y() {
        let mapping = "myMap"
        let input = "something"
        let x: Float = 5.0
        let y: Float = 6.0
        let data = DS100(mapping, input: input, x: x, y: y, spread: 0.5)
        let coord: Coordinate = .y
        
        client.send(data: [data], coordinate: coord)
        
        XCTAssertTrue(mClient.invokedSend)
        if !mClient.invokedSend {return}
        
        let oscBundle = mClient.invokedSendParameters!.element as! OSCBundle
        XCTAssertEqual(oscBundle.elements.count, 1)
        if oscBundle.elements.count != 1 {return}
        
        guard let oscMsg = oscBundle.elements[0] as? OSCMessage else {
            XCTAssertFalse(true, "osc element is not an OSCMessage")
            return
        }
        
        XCTAssertEqual(oscMsg.address, data.coordinateY())
        XCTAssertEqual(oscMsg.arguments.count, 1)
        XCTAssertEqual(oscMsg.arguments[0]?.data, y.data)
    }
}





// MARK: - Mocks

class MockOSCClient: OSCClient {

    var invokedConnect = false
    var invokedConnectCount = 0

    override func connect() {
        invokedConnect = true
        invokedConnectCount += 1
    }

    var invokedConnectTo = false
    var invokedConnectToCount = 0
    var invokedConnectToParameters: (address: NWEndpoint.Host, port: NWEndpoint.Port)?
    var invokedConnectToParametersList = [(address: NWEndpoint.Host, port: NWEndpoint.Port)]()

    override func connect(to address: NWEndpoint.Host, with port: NWEndpoint.Port) {
        invokedConnectTo = true
        invokedConnectToCount += 1
        invokedConnectToParameters = (address, port)
        invokedConnectToParametersList.append((address, port))
    }

    var invokedDisconnect = false
    var invokedDisconnectCount = 0

    override func disconnect() {
        invokedDisconnect = true
        invokedDisconnectCount += 1
    }

    var invokedAddress = false
    var invokedAddressCount = 0
    var stubbedAddressResult: String! = ""

    override func address() -> String {
        invokedAddress = true
        invokedAddressCount += 1
        return stubbedAddressResult
    }

    var invokedPort = false
    var invokedPortCount = 0
    var stubbedPortResult: Int! = 0

    override func port() -> Int {
        invokedPort = true
        invokedPortCount += 1
        return stubbedPortResult
    }

    var invokedSetEndpoints = false
    var invokedSetEndpointsCount = 0
    var invokedSetEndpointsParameters: (address: String, port: Int)?
    var invokedSetEndpointsParametersList = [(address: String, port: Int)]()

    override func setEndpoints(address: String, port: Int) {
        invokedSetEndpoints = true
        invokedSetEndpointsCount += 1
        invokedSetEndpointsParameters = (address, port)
        invokedSetEndpointsParametersList.append((address, port))
    }

    var invokedUpdateAddress = false
    var invokedUpdateAddressCount = 0
    var invokedUpdateAddressParameters: (newAddress: NWEndpoint.Host, Void)?
    var invokedUpdateAddressParametersList = [(newAddress: NWEndpoint.Host, Void)]()

    override func updateAddress(_ newAddress: NWEndpoint.Host) {
        invokedUpdateAddress = true
        invokedUpdateAddressCount += 1
        invokedUpdateAddressParameters = (newAddress, ())
        invokedUpdateAddressParametersList.append((newAddress, ()))
    }

    var invokedUpdatePort = false
    var invokedUpdatePortCount = 0
    var invokedUpdatePortParameters: (newPort: NWEndpoint.Port, Void)?
    var invokedUpdatePortParametersList = [(newPort: NWEndpoint.Port, Void)]()

    override func updatePort(_ newPort: NWEndpoint.Port) {
        invokedUpdatePort = true
        invokedUpdatePortCount += 1
        invokedUpdatePortParameters = (newPort, ())
        invokedUpdatePortParametersList.append((newPort, ()))
    }

    var invokedSend = false
    var invokedSendCount = 0
    var invokedSendParameters: (element: OSCElement, Void)?
    var invokedSendParametersList = [(element: OSCElement, Void)]()

    override func send(_ element: OSCElement) {
        invokedSend = true
        invokedSendCount += 1
        invokedSendParameters = (element, ())
        invokedSendParametersList.append((element, ()))
    }

    var invokedIsConnected = false
    var invokedIsConnectedCount = 0
    var stubbedIsConnectedResult: Bool! = false

    override func isConnected() -> Bool {
        invokedIsConnected = true
        invokedIsConnectedCount += 1
        return stubbedIsConnectedResult
    }
}
