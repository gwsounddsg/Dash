// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/22/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import XCTest
import RTTrPSwift
import CocoaAsyncSocket
@testable import Dash





// swiftlint:disable weak_delegate

class ServersTests: XCTestCase {

    var servers: Servers!
    var mBlackTrax: MockReceiveUDP!
    var mVezer: MDashOSCServer!
    var mControl: MDashOSCServer!
    var delegate: MServersProtocol!
    
    
    override func setUp() {
        servers = Servers()
        delegate = MServersProtocol()
        servers.delegate = delegate
    }
}





extension ServersTests {

    func testServers() {
        XCTAssertTrue(servers.blackTrax.delegate === servers)
    }
    
    
    func testServers_connectAll() {
        let addy = "/connect/server/"
        let port = 78901
        let mockDefaults = MockUserDefaults()
        mockDefaults.stubbedGetStringResult = addy
        mockDefaults.stubbedGetIntResult = port
        mockAll()
        
        XCTAssertFalse(servers.isBlackTraxConnected)
        XCTAssertFalse(servers.isVezerConnected)
        XCTAssertFalse(servers.isControlConnected)
        
        let result = servers.connectAll()
        
        XCTAssertTrue(result.isEmpty, result.description)
    }
    
    
    func testServers_connectBlackTrax() {
        let addy = "/connect/server/blacktrax"
        let port = 85672
        let mockDefaults = MockUserDefaults()
        mockDefaults.stubbedGetStringResult = addy
        mockDefaults.stubbedGetIntResult = port
        mockAll()
        
        XCTAssertFalse(servers.isBlackTraxConnected)
        
        servers.connectBlackTrax(from: mockDefaults)
        
        XCTAssertEqual(mBlackTrax.invokedConnectParametersList[0].port, port)
        XCTAssertTrue(servers.isBlackTraxConnected)
    }
    
    
    func testServers_connectVezer() {
        let addy = "/connect/server/vezer"
        let port = 32451
        let mockDefaults = MockUserDefaults()
        mockDefaults.stubbedGetStringResult = addy
        mockDefaults.stubbedGetIntResult = port
        mockAll()
    
        XCTAssertFalse(servers.isVezerConnected)
    
        servers.connectVezer(from: mockDefaults)
    
        XCTAssertEqual(mVezer.invokedPort, port)
        XCTAssertTrue(servers.isVezerConnected)
    }
    
    
    func testServers_connectControl() {
        let addy = "/connect/server/vezer"
        let port = 44566
        let mockDefaults = MockUserDefaults()
        mockDefaults.stubbedGetStringResult = addy
        mockDefaults.stubbedGetIntResult = port
        mockAll()
    
        XCTAssertFalse(servers.isControlConnected)
    
        servers.connectControl(from: mockDefaults)
    
        XCTAssertEqual(mControl.invokedPort, port)
        XCTAssertTrue(servers.isControlConnected)
    }
}





// MARK: - ReceiveUDPDelegate

extension ServersTests {

    func testServers_newPacket() {
        mockAll()
        guard let data = try? RTTrP(data: rttData) else {
            assertionFailure()
            return
        }
        
        servers.newPacket(data)
        XCTAssertTrue(delegate.invokedLiveBlackTrax)
    }
}





// MARK: - DashOSCServerDelegate

extension ServersTests {

    func testServers_oscDataReceived_control() {
        let val: Double = 4.65
        let msg = Message(ControlOSC.switchTo, [val])
        mockAll()
        
        servers.oscDataReceived(msg, .control)
        
        if !delegate.invokedCommand {
            XCTAssertTrue(delegate.invokedCommand)
            return
        }
        
        guard let values = delegate.invokedCommandParameters?.data as? DashData? else {
            XCTAssertTrue(false)
            return
        }
        
        XCTAssertEqual(delegate.invokedCommandParameters?.control, .switchActive)
        XCTAssertEqual(values as? Double, val)
    }
    
    
    func testServers_oscDataReceived_vezer() {
        let val: Double = 4.65
        let msg = Message("/testing/oscDataReceived/control", [val])
        mockAll()
    
        servers.oscDataReceived(msg, .vezer)
        
        //TODO: not implemented yet
    }
}





// MARK: - Utility

extension  ServersTests {

    func mockAll(_ connected: Bool = false) {
        mBlackTrax = MockReceiveUDP()
        mVezer = MDashOSCServer(.vezer, "/server/vezer", 2222)
        mControl = MDashOSCServer(.control, "/server/control", 3333)
        
        servers.blackTrax = mBlackTrax
        servers.vezer = mVezer
        servers.control = mControl
        
        if connected {
            let mockDefaults = MockUserDefaults()
            mockDefaults.stubbedGetStringResult = "mocking"
            mockDefaults.stubbedGetIntResult = 9999
            
            _ = servers.connectAll(from: mockDefaults)
        }
    }
}





// MARK: - Mocks

class MServersProtocol: ServersProtocol {
    
    var invokedLiveBlackTrax = false
    var invokedLiveBlackTraxCount = 0
    var invokedLiveBlackTraxParameters: (data: RTTrP, Void)?
    var invokedLiveBlackTraxParametersList = [(data: RTTrP, Void)]()
    
    func liveBlackTrax(_ data: RTTrP) {
        invokedLiveBlackTrax = true
        invokedLiveBlackTraxCount += 1
        invokedLiveBlackTraxParameters = (data, ())
        invokedLiveBlackTraxParametersList.append((data, ()))
    }
    
    var invokedCommand = false
    var invokedCommandCount = 0
    var invokedCommandParameters: (control: ControlMessage, data: Any?)?
    var invokedCommandParametersList = [(control: ControlMessage, data: Any?)]()
    
    func command(control: ControlMessage, data: Any?) {
        invokedCommand = true
        invokedCommandCount += 1
        invokedCommandParameters = (control, data)
        invokedCommandParametersList.append((control, data))
    }
}


class MockReceiveUDP: ReceiveUDP {
    
    var invoked_socketSetter = false
    var invoked_socketSetterCount = 0
    var invoked_socket: GCDAsyncUdpSocket?
    var invoked_socketList = [GCDAsyncUdpSocket?]()
    var invoked_socketGetter = false
    var invoked_socketGetterCount = 0
    var stubbed_socket: GCDAsyncUdpSocket!
    override var _socket: GCDAsyncUdpSocket! {
        set {
            invoked_socketSetter = true
            invoked_socketSetterCount += 1
            invoked_socket = newValue
            invoked_socketList.append(newValue)
        }
        get {
            invoked_socketGetter = true
            invoked_socketGetterCount += 1
            return stubbed_socket
        }
    }
    var invoked_delegateSetter = false
    var invoked_delegateSetterCount = 0
    var invoked_delegate: ReceiveUDPDelegate?
    var invoked_delegateList = [ReceiveUDPDelegate?]()
    var invoked_delegateGetter = false
    var invoked_delegateGetterCount = 0
    var stubbed_delegate: ReceiveUDPDelegate!
    override var _delegate: ReceiveUDPDelegate? {
        set {
            invoked_delegateSetter = true
            invoked_delegateSetterCount += 1
            invoked_delegate = newValue
            invoked_delegateList.append(newValue)
        }
        get {
            invoked_delegateGetter = true
            invoked_delegateGetterCount += 1
            return stubbed_delegate
        }
    }
    var invokedUdpSocket = false
    var invokedUdpSocketCount = 0
    var invokedUdpSocketParameters: (sock: GCDAsyncUdpSocket, data: Data, address: Data, filterContext: Any?)?
    var invokedUdpSocketParametersList = [(sock: GCDAsyncUdpSocket, data: Data, address: Data, filterContext: Any?)]()
    
    override func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        invokedUdpSocket = true
        invokedUdpSocketCount += 1
        invokedUdpSocketParameters = (sock, data, address, filterContext)
        invokedUdpSocketParametersList.append((sock, data, address, filterContext))
    }
    
    var invokedConnect = false
    var invokedConnectCount = 0
    var invokedConnectParameters: (port: Int, Void)?
    var invokedConnectParametersList = [(port: Int, Void)]()
    var stubbedConnectError: Error?
    
    override func connect(port: Int) throws {
        invokedConnect = true
        invokedConnectCount += 1
        invokedConnectParameters = (port, ())
        invokedConnectParametersList.append((port, ()))
        if let error = stubbedConnectError {
            throw error
        }
    }
    
    var invokedIsIPv4Enabled = false
    var invokedIsIPv4EnabledCount = 0
    var stubbedIsIPv4EnabledResult: Bool! = false
    
    override func isIPv4Enabled() -> Bool {
        invokedIsIPv4Enabled = true
        invokedIsIPv4EnabledCount += 1
        return stubbedIsIPv4EnabledResult
    }
    
    var invokedConnectedPort = false
    var invokedConnectedPortCount = 0
    var stubbedConnectedPortResult: Int! = 0
    
    override func connectedPort() -> Int {
        invokedConnectedPort = true
        invokedConnectedPortCount += 1
        return stubbedConnectedPortResult
    }
    
    var invokedLocalAddress = false
    var invokedLocalAddressCount = 0
    var stubbedLocalAddressResult: String! = ""
    
    override func localAddress() -> String {
        invokedLocalAddress = true
        invokedLocalAddressCount += 1
        return stubbedLocalAddressResult
    }
    
    var invokedLocalPort = false
    var invokedLocalPortCount = 0
    var stubbedLocalPortResult: Int! = 0
    
    override func localPort() -> Int {
        invokedLocalPort = true
        invokedLocalPortCount += 1
        return stubbedLocalPortResult
    }
}


class MDashOSCServer: DashOSCServer {
    
    var invokedDelegateSetter = false
    var invokedDelegateSetterCount = 0
    var invokedDelegate: DashOSCServerDelegate?
    var invokedDelegateList = [DashOSCServerDelegate?]()
    var invokedDelegateGetter = false
    var invokedDelegateGetterCount = 0
    var stubbedDelegate: DashOSCServerDelegate!
    override var delegate: DashOSCServerDelegate? {
        set {
            invokedDelegateSetter = true
            invokedDelegateSetterCount += 1
            invokedDelegate = newValue
            invokedDelegateList.append(newValue)
        }
        get {
            invokedDelegateGetter = true
            invokedDelegateGetterCount += 1
            return stubbedDelegate
        }
    }
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
    
    var invokedStart = false
    var invokedStartCount = 0
    
    override func start() {
        invokedStart = true
        invokedStartCount += 1
    }
    
    var invokedStop = false
    var invokedStopCount = 0
    
    override func stop() {
        invokedStop = true
        invokedStopCount += 1
    }
    
    var invokedDisconnect = false
    var invokedDisconnectCount = 0
    
    override func disconnect() {
        invokedDisconnect = true
        invokedDisconnectCount += 1
    }
}
