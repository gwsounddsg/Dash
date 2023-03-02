// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/22/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import XCTest
@testable import Dash





class ClientsTests: XCTestCase {

    var clients: Clients!
    var mVezer: MockDashOSCClient!
    var mDS100Main: MockDashOSCClient!
    var mVezerOSCClient: MockOSCClient!
    var mDS100MainOSCClient: MockOSCClient!
    
    override func setUp() {
        clients = Clients()
    }
}





// MARK: - Connecting

extension ClientsTests {

    func testClients_connectAll() {
        let addy = "/connect/clients/"
        let port = 7890
        let mockDefaults = MockUserDefaults()
        mockDefaults.stubbedGetStringResult = addy
        mockDefaults.stubbedGetIntResult = port
        
        XCTAssertFalse(clients.isVezerConnected)
        XCTAssertFalse(clients.isDS100MainConnected)
    
        let result = clients.connectAll(from: mockDefaults)
        
        XCTAssertEqual(result.count, 1)
        XCTAssertTrue(result.contains(.ds100Backup))
    }
    
    
    func testClients_connectVezer() {
        let addy = "/connect/clients/vezer"
        let port = 7890
        let mockDefaults = MockUserDefaults()
        mockDefaults.stubbedGetStringResult = addy
        mockDefaults.stubbedGetIntResult = port
        mockAll()
        
        XCTAssertFalse(clients.isVezerConnected)
        
        clients.connectVezer(from: mockDefaults)
        
        XCTAssertEqual(mVezer.invokedChangeEndpointsParameters?.address, addy)
        XCTAssertEqual(mVezer.invokedChangeEndpointsParameters?.port, port)
        XCTAssertTrue(clients.isVezerConnected)
    }
    
    
    func testClients_connectDS100Main() {
        let addy = "/connect/clients/ds100Main"
        let port = 3746
        let mockDefaults = MockUserDefaults()
        mockDefaults.stubbedGetStringResult = addy
        mockDefaults.stubbedGetIntResult = port
        mockAll()
    
        XCTAssertFalse(clients.isDS100MainConnected)
    
        clients.connectDS100Main(from: mockDefaults)
    
        XCTAssertEqual(mDS100Main.invokedChangeEndpointsParameters?.address, addy)
        XCTAssertEqual(mDS100Main.invokedChangeEndpointsParameters?.port, port)
        XCTAssertTrue(clients.isDS100MainConnected)
    }
}





// MARK: - Sending

extension ClientsTests {

    func testClients_sendOSC_vezer() {
        let message = OSCMessage("/testing/sendosc/vezer", [])
        mockAll(true)
        
        let result = clients.sendOSC(message: message, to: .vezer)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mVezer.invokedSendMessage)
        
        guard let newMessage = mVezer.invokedSendMessageParameters?.message as? OSCMessage else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(newMessage.address, message.address)
    }
    
    
    func testClients_sendOSC_vezer_notConnected() {
        let message = OSCMessage("/testing/sendosc/vezer/notconnected", [])
        mockAll(false)
        
        let result = clients.sendOSC(message: message, to: .vezer)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mVezer.invokedClientSend)
    }
    
    
    func testClients_sendOSC_ds100Main() {
        let message = OSCMessage("/testing/sendosc/ds100Main", [])
        mockAll(true)
    
        let result = clients.sendOSC(message: message, to: .ds100Main)
    
        XCTAssertTrue(result)
        XCTAssertNotNil(mDS100Main.invokedClientSendParameters)
        
        guard let newMessage = mDS100Main.invokedClientSendParameters?.element as? OSCMessage else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(newMessage.address, message.address)
    }
    
    
    func testClients_sendOSC_ds100Main_notConnected() {
        let message = OSCMessage("/testing/sendosc/ds100Main/notconnected", [])
        mockAll(false)
    
        let result = clients.sendOSC(message: message, to: .ds100Main)
    
        XCTAssertFalse(result)
        XCTAssertFalse(mDS100Main.invokedClientSend)
    }
    
    
    func testClients_sendDS100() {
        let data = DS100("/test/sendDS100", input: "foo", x: 4, y: 6, spread: 0.5)
        mockAll(true)
        
        let result = clients.send(ds100: [data])
        
        XCTAssertTrue(result)
        XCTAssertEqual(mDS100Main.invokedSendDataCoordinateParameters?.data[0], data)
    }
    
    
    func testClients_sendDS100_notConnected() {
        let data = DS100("/test/sendDS100", input: "foo", x: 4, y: 6, spread: 0.5)
        mockAll(false)
    
        let result = clients.send(ds100: [data])
        
        XCTAssertFalse(result)
        XCTAssertFalse(mDS100Main.invokedSendDataCoordinate)
    }
    
    
    func testClients_sendVezer() {
        let data = Vezer("/test/vezer", 33, 44)
        mockAll(true)
        
        let result = clients.send(vezer: [data])
        
        XCTAssertTrue(result)
        XCTAssertEqual(mVezer.invokedSendDataParameters?.data[0], data)
    }
    
    
    func testClients_sendVezer_notConnected() {
        let data = Vezer("/test/vezer", 33, 44)
        mockAll(false)
    
        let result = clients.send(vezer: [data])
    
        XCTAssertFalse(result)
        XCTAssertFalse(mVezer.invokedSendData)
    }
}





// MARK: - Notifications

extension ClientsTests {
    
    func testClients_updateDefaults_clientds100MainIP() {
        mockAll()
        let key = DashNotifData.userPref
        let value = "192.168.99.99"
        let notif = notification(DashNotif.userPrefClientDS100MainIP, [key: value])
        let mDefaults = MockUserDefaults()
        
        clients.updateDefaults(notif, mDefaults)
        
        XCTAssertEqual(mDS100Main.invokedSetAddressParameters?.newAddress, value)
        XCTAssertEqual(mDefaults.invokedUpdateParameters?.forKey, DashDefaultIDs.Network.Client.ds100MainIP)
        XCTAssertEqual(mDefaults.invokedUpdateParameters?.value as? String, value)
    }
    
    
    func testClients_updateDefaults_clientds100MainPort() {
        mockAll()
        let key = DashNotifData.userPref
        let value = "1111"
        let notif = notification(DashNotif.userPrefClientDS100MainPort, [key: value])
        let mDefaults = MockUserDefaults()
        
        clients.updateDefaults(notif, mDefaults)
        
        XCTAssertEqual(mDS100Main.invokedSetPortParameters?.newPort, Int(value))
        XCTAssertEqual(mDefaults.invokedUpdateParameters?.forKey, DashDefaultIDs.Network.Client.ds100MainPort)
        XCTAssertEqual(mDefaults.invokedUpdateParameters?.value as? Int, Int(value))
    }
    
    
    func testClients_updateDefaults_clientdsVezerIP() {
        mockAll()
        let key = DashNotifData.userPref
        let value = "192.168.99.99"
        let notif = notification(DashNotif.userPrefClientVezerIP, [key: value])
        let mDefaults = MockUserDefaults()
        
        clients.updateDefaults(notif, mDefaults)
        
        XCTAssertEqual(mVezer.invokedSetAddressParameters?.newAddress, value)
        XCTAssertEqual(mDefaults.invokedUpdateParameters?.forKey, DashDefaultIDs.Network.Client.vezerIP)
        XCTAssertEqual(mDefaults.invokedUpdateParameters?.value as? String, value)
    }
    
    
    func testClients_updateDefaults_clientdsVezerPort() {
        mockAll()
        let key = DashNotifData.userPref
        let value = "1111"
        let notif = notification(DashNotif.userPrefClientVezerPort, [key: value])
        let mDefaults = MockUserDefaults()
        
        clients.updateDefaults(notif, mDefaults)
        
        XCTAssertEqual(mVezer.invokedSetPortParameters?.newPort, Int(value))
        XCTAssertEqual(mDefaults.invokedUpdateParameters?.forKey, DashDefaultIDs.Network.Client.vezerPort)
        XCTAssertEqual(mDefaults.invokedUpdateParameters?.value as? Int, Int(value))
    }
}





// MARK: - Utility

extension ClientsTests {
    
    func mockAll(_ connected: Bool = false) {
        mVezerOSCClient = MockOSCClient()
        mDS100MainOSCClient = MockOSCClient()
        
        mVezer = MockDashOSCClient(.vezer, "/client/vezer", 1111, mVezerOSCClient)
        mDS100Main = MockDashOSCClient(.ds100Main, "/client/ds100/main", 2222, mDS100MainOSCClient)
        
        clients.vezer = mVezer
        clients.ds100Main = mDS100Main
        
        if connected {
            let mockDefaults = MockUserDefaults()
            mockDefaults.stubbedGetStringResult = "/mocking"
            mockDefaults.stubbedGetIntResult = 9999
            
            _ = clients.connectAll(from: mockDefaults)
        }
    }
    
    
    func notification(_ name: Notification.Name, _ info: [String: String]) -> Notification {
        return Notification(name: name, userInfo: info)
    }
}





// MARK: - Mocks

class MockDashOSCClient: DashOSCClient {

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

    override func changeEndpoints(_ address: String, _ port: Int) {
        invokedChangeEndpoints = true
        invokedChangeEndpointsCount += 1
        invokedChangeEndpointsParameters = (address, port)
        invokedChangeEndpointsParametersList.append((address, port))
    }

    var invokedSendMessage = false
    var invokedSendMessageCount = 0
    var invokedSendMessageParameters: (message: OSCMessage, Void)?
    var invokedSendMessageParametersList = [(message: OSCMessage, Void)]()

    override func send(message: OSCMessage) {
        invokedSendMessage = true
        invokedSendMessageCount += 1
        invokedSendMessageParameters = (message, ())
        invokedSendMessageParametersList.append((message, ()))
    }

    var invokedSendDataCoordinate = false
    var invokedSendDataCoordinateCount = 0
    var invokedSendDataCoordinateParameters: (data: [DS100], coordinate: Coordinate)?
    var invokedSendDataCoordinateParametersList = [(data: [DS100], coordinate: Coordinate)]()

    override func send(data: [DS100], coordinate: Coordinate) {
        invokedSendDataCoordinate = true
        invokedSendDataCoordinateCount += 1
        invokedSendDataCoordinateParameters = (data, coordinate)
        invokedSendDataCoordinateParametersList.append((data, coordinate))
    }

    var invokedSendData = false
    var invokedSendDataCount = 0
    var invokedSendDataParameters: (data: [Vezer], Void)?
    var invokedSendDataParametersList = [(data: [Vezer], Void)]()

    override func send(data: [Vezer]) {
        invokedSendData = true
        invokedSendDataCount += 1
        invokedSendDataParameters = (data, ())
        invokedSendDataParametersList.append((data, ()))
    }
}
