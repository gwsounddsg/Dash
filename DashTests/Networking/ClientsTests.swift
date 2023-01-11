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
    var mVezer: MDashOSCClient!
    var mDS100Main: MDashOSCClient!
    
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
        
        XCTAssertEqual(mVezer.invokedAddress, addy)
        XCTAssertEqual(mVezer.invokedPort, port)
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
    
        XCTAssertEqual(mDS100Main.invokedAddress, addy)
        XCTAssertEqual(mDS100Main.invokedPort, port)
        XCTAssertTrue(clients.isDS100MainConnected)
    }
}





// MARK: - Sending

extension ClientsTests {

    func testClients_sendOSC_vezer() {
        let message = Message("/testing/sendosc/vezer", [nil])
        mockAll(true)
        
        let result = clients.sendOSC(message: message, to: .vezer)
        
        XCTAssertTrue(result)
        XCTAssertEqual(mVezer.invokedSendMessageParameters?.message.address, message.address)
    }
    
    
    func testClients_sendOSC_vezer_notConnected() {
        let message = Message("/testing/sendosc/vezer/notconnected", [nil])
        mockAll(false)
        
        let result = clients.sendOSC(message: message, to: .vezer)
        
        XCTAssertFalse(result)
        XCTAssertFalse(mVezer.invokedSendMessage)
    }
    
    
    func testClients_sendOSC_ds100Main() {
        let message = Message("/testing/sendosc/ds100Main", [nil])
        mockAll(true)
    
        let result = clients.sendOSC(message: message, to: .ds100Main)
    
        XCTAssertTrue(result)
        XCTAssertEqual(mDS100Main.invokedSendMessageParameters?.message.address, message.address)
    }
    
    
    func testClients_sendOSC_ds100Main_notConnected() {
        let message = Message("/testing/sendosc/ds100Main/notconnected", [nil])
        mockAll(false)
    
        let result = clients.sendOSC(message: message, to: .ds100Main)
    
        XCTAssertFalse(result)
        XCTAssertFalse(mDS100Main.invokedSendMessage)
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
        
        XCTAssertEqual(mDS100Main.invokedAddress, value)
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
        
        XCTAssertEqual(mDS100Main.invokedPort, Int(value))
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
        
        XCTAssertEqual(mVezer.invokedAddress, value)
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
        
        XCTAssertEqual(mVezer.invokedPort, Int(value))
        XCTAssertEqual(mDefaults.invokedUpdateParameters?.forKey, DashDefaultIDs.Network.Client.vezerPort)
        XCTAssertEqual(mDefaults.invokedUpdateParameters?.value as? Int, Int(value))
    }
}





// MARK: - Utility

extension ClientsTests {
    
    func mockAll(_ connected: Bool = false) {
        mVezer = MDashOSCClient(.vezer, "/client/vezer", 1111)
        mDS100Main = MDashOSCClient(.ds100Main, "/client/ds100/main", 2222)
        
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

class MDashOSCClient: DashOSCClient {
    
    var invokedAddressSetter = false
    var invokedAddressSetterCount = 0
    var invokedAddress: String?
    var invokedAddressList = [String]()
    var invokedAddressGetter = false
    var invokedAddressGetterCount = 0
    var stubbedAddress: String! = ""
    override var address: String {
        set {
            invokedAddressSetter = true
            invokedAddressSetterCount += 1
            invokedAddress = newValue
            invokedAddressList.append(newValue)
        }
        get {
            invokedAddressGetter = true
            invokedAddressGetterCount += 1
            return stubbedAddress
        }
    }
    var invokedPortSetter = false
    var invokedPortSetterCount = 0
    var invokedPort: Int?
    var invokedPortList = [Int]()
    var invokedPortGetter = false
    var invokedPortGetterCount = 0
    var stubbedPort: Int! = 0
    override var port: Int {
        set {
            invokedPortSetter = true
            invokedPortSetterCount += 1
            invokedPort = newValue
            invokedPortList.append(newValue)
        }
        get {
            invokedPortGetter = true
            invokedPortGetterCount += 1
            return stubbedPort
        }
    }
    var invokedClientSend = false
    var invokedClientSendCount = 0
    var invokedClientSendParameters: (message: OSCElement, Void)?
    var invokedClientSendParametersList = [(message: OSCElement, Void)]()
    
    override func clientSend(_ message: OSCElement) {
        invokedClientSend = true
        invokedClientSendCount += 1
        invokedClientSendParameters = (message, ())
        invokedClientSendParametersList.append((message, ()))
    }
    
    var invokedClientAddress = false
    var invokedClientAddressCount = 0
    var invokedClientAddressParameters: (newAddress: String, Void)?
    var invokedClientAddressParametersList = [(newAddress: String, Void)]()
    
    override func clientAddress(_ newAddress: String) {
        invokedClientAddress = true
        invokedClientAddressCount += 1
        invokedClientAddressParameters = (newAddress, ())
        invokedClientAddressParametersList.append((newAddress, ()))
    }
    
    var invokedClientPort = false
    var invokedClientPortCount = 0
    var invokedClientPortParameters: (newPort: Int, Void)?
    var invokedClientPortParametersList = [(newPort: Int, Void)]()
    
    override func clientPort(_ newPort: Int) {
        invokedClientPort = true
        invokedClientPortCount += 1
        invokedClientPortParameters = (newPort, ())
        invokedClientPortParametersList.append((newPort, ()))
    }
    
    var invokedSendMessage = false
    var invokedSendMessageCount = 0
    var invokedSendMessageParameters: (message: Message, Void)?
    var invokedSendMessageParametersList = [(message: Message, Void)]()
    
    override func send(message: Message) {
        invokedSendMessage = true
        invokedSendMessageCount += 1
        invokedSendMessageParameters = (message, ())
        invokedSendMessageParametersList.append((message, ()))
    }
    
    var invokedSendDataCoordinate = false
    var invokedSendDataCoordinateCount = 0
    var invokedSendDataCoordinateParameters: (data: [DS100], coordinate: Coordinate)?
    var invokedSendDataCoordinateParametersList = [(data: [DS100], coordinate: Coordinate)]()
    
    override func send(data: [DS100], coordinate: Coordinate = .all) {
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
    
    var invokedPrintNetwork = false
    var invokedPrintNetworkCount = 0
    
    override func printNetwork() {
        invokedPrintNetwork = true
        invokedPrintNetworkCount += 1
    }
}
