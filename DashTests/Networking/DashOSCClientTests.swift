// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/15/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import XCTest
@testable import Dash



// swiftlint:disable force_cast


class DashOSCClientTests: XCTestCase {

    fileprivate var _client: MockDashOSCClient!
    let address = "/test/message/"
    let port: Int = 1234


    override func setUp() {
        _client = MockDashOSCClient(.vezer, address, port)
    }

    override func tearDown() {
        _client = nil
    }
}





extension DashOSCClientTests {

    func testDashOSCClient() {
        XCTAssertEqual(_client.type, .vezer)
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
        let msg = OSCMessage(addy, vals)

        _client.send(message: msg)

        if !_client.invokedClientSend {
            XCTAssertTrue(_client.invokedClientSend)
            return
        }

        let oscMsg = _client.invokedClientSendParameter as! OSCMessage

        XCTAssertEqual(oscMsg.address, addy)
        XCTAssertEqual(oscMsg.arguments.count, vals.count)
        XCTAssertEqual(oscMsg.arguments[0]?.data, vals[0].data)
        XCTAssertEqual(oscMsg.arguments[1]?.data, vals[1].data)
    }


    func testDashOSCClient_sendData_all() {
        let mapping = "myMap"
        let input = "something"
        let x: Float = 5.0
        let y: Float = 6.0
        let data = DS100(mapping, input: input, x: x, y: y, spread: 0.5)
        let coord: Coordinate = .all

        _client.send(data: [data], coordinate: coord)

        XCTAssertTrue(_client.invokedClientSend)
        if !_client.invokedClientSend {return}

        let oscBundle = _client.invokedClientSendParameter as! OSCBundle
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
        
        _client.send(data: [data], coordinate: coord)
        
        XCTAssertTrue(_client.invokedClientSend)
        if !_client.invokedClientSend {return}
        
        let oscBundle = _client.invokedClientSendParameter as! OSCBundle
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
        
        _client.send(data: [data], coordinate: coord)
        
        XCTAssertTrue(_client.invokedClientSend)
        if !_client.invokedClientSend {return}
        
        let oscBundle = _client.invokedClientSendParameter as! OSCBundle
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

private class MockDashOSCClient: DashOSCClient {

    convenience init() {
        self.init(<#_#>, "", 0, <#_#>)
    }

    var invokedClientSend = false
    var invokedClientSendCount = 0
    var invokedClientSendParameters: (element: OSCElement, Void)?
    var invokedClientSendParametersList = [(element: OSCElement, Void)]()

    override func clientSend(_ element: OSCElement) {
        invokedClientSend = true
        invokedClientSendCount += 1
        invokedClientSendParameters = (element, ())
        invokedClientSendParametersList.append((element, ()))
    }

    var invokedConnect = false
    var invokedConnectCount = 0

    override func connect() {
        invokedConnect = true
        invokedConnectCount += 1
    }

    var invokedPrintNetwork = false
    var invokedPrintNetworkCount = 0

    override func printNetwork() {
        invokedPrintNetwork = true
        invokedPrintNetworkCount += 1
    }

    var invokedPort = false
    var invokedPortCount = 0
    var stubbedPortResult: Int! = 0

    override func port() -> Int {
        invokedPort = true
        invokedPortCount += 1
        return stubbedPortResult
    }

    var invokedSetPort = false
    var invokedSetPortCount = 0
    var invokedSetPortParameters: (newPort: Int, Void)?
    var invokedSetPortParametersList = [(newPort: Int, Void)]()

    override func setPort(_ newPort: Int) {
        invokedSetPort = true
        invokedSetPortCount += 1
        invokedSetPortParameters = (newPort, ())
        invokedSetPortParametersList.append((newPort, ()))
    }

    var invokedAddress = false
    var invokedAddressCount = 0
    var stubbedAddressResult: String! = ""

    override func address() -> String {
        invokedAddress = true
        invokedAddressCount += 1
        return stubbedAddressResult
    }

    var invokedSetAddress = false
    var invokedSetAddressCount = 0
    var invokedSetAddressParameters: (newAddress: String, Void)?
    var invokedSetAddressParametersList = [(newAddress: String, Void)]()

    override func setAddress(_ newAddress: String) {
        invokedSetAddress = true
        invokedSetAddressCount += 1
        invokedSetAddressParameters = (newAddress, ())
        invokedSetAddressParametersList.append((newAddress, ()))
    }

    var invokedChangeEndpoints = false
    var invokedChangeEndpointsCount = 0
    var invokedChangeEndpointsParameters: (address: String, port: Int)?
    var invokedChangeEndpointsParametersList = [(address: String, port: Int)]()

    override func changeEndpoints(address: String, port: Int) {
        invokedChangeEndpoints = true
        invokedChangeEndpointsCount += 1
        invokedChangeEndpointsParameters = (address, port)
        invokedChangeEndpointsParametersList.append((address, port))
    }
}
