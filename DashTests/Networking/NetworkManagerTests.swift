// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/15/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import XCTest
import RTTrPSwift
import CocoaAsyncSocket
import SwiftOSC
@testable import Dash



// swiftlint:disable weak_delegate

class NetworkManagerTests: XCTestCase {

    var manager: NetworkManager!
    var delegate: MockNetworkManagerDelegate!

    var mBlackTrax: MockReceiveUDP!
    var mOscServerControl: MDashOSCServer!
    var mOscServerRecorded: MDashOSCServer!
    var mOscClientRecorded: MDashOSCClient!
    var mOscClientLive: MDashOSCClient!

    
    override func setUp() {
        manager = NetworkManager()
        delegate = MockNetworkManagerDelegate()
        manager.delegate = delegate
    }
}





extension NetworkManagerTests {

    func testNetworkManager() {
        XCTAssertFalse(manager.isBlackTraxConnected)
        XCTAssertFalse(manager.isServerControlConnected)
        XCTAssertFalse(manager.isServerRecordedConnected)
        XCTAssertFalse(manager.isClientRecordedConnected)
        XCTAssertFalse(manager.isClientLiveConnected)

        XCTAssertTrue(manager.blackTrax.delegate === manager)
    }


    func testNetworkManager_newPacket() {
        let rttrp = try? RTTrP(data: rttData)
        if rttrp == nil {
            assertionFailure()
            return
        }

        manager.newPacket(rttrp!)
        XCTAssertTrue(delegate.invokedLiveBlackTrax)
    }
}





// MARK: - OSC Server Delegate

extension NetworkManagerTests {

    func testNetworkManager_oscDataReceived_control() {
        let msg = Message("/data/received/control", [3.14])
        
        manager.oscDataReceived(msg, .control)
        
        //TODO: fill out test
    }
    
    
    func testNetworkManager_oscDataReceived_recorded() {
        let msg = Message("/data/received/recorded", [4.14])
        
        manager.oscDataReceived(msg, .recorded)
        
        //TODO: fill out test
    }
    
    
    func testNetworkManager_oscDataReceived_blackTrax() {
        let msg = Message("/data/received/blacktrax", [1.12])
        
        manager.oscDataReceived(msg, .blackTrax)
        // this server type does nothing
    }
}





// MARK: - Connecting

extension NetworkManagerTests {

    func testNetworkManager_connectAll() {
        let addy = "/connect/recorded/client"
        let port = 9999
        let mockDefaults = MockUserDefaults()
        mockDefaults.stubbedGetStringResult = addy
        mockDefaults.stubbedGetIntResult = port
        mockAll()
        
        let result = manager.connectAll(from: mockDefaults)
    
        XCTAssertTrue(manager.isBlackTraxConnected)
        XCTAssertTrue(manager.isServerControlConnected)
        XCTAssertTrue(manager.isServerRecordedConnected)
        XCTAssertTrue(manager.isClientRecordedConnected)
        XCTAssertTrue(manager.isClientLiveConnected)
    
        XCTAssertTrue(result.clients.isEmpty)
        XCTAssertTrue(result.servers.isEmpty)
    }
    
    
    func testNetworkManager_connectBlackTraxPortWithPref() {
        let port = 8888
        let mockDefaults = MockUserDefaults()
        mockDefaults.stubbedGetIntResult = port
        mockAll()
        
        manager.connectBlackTrax(from: mockDefaults)
        
        XCTAssertEqual(mBlackTrax.invokedConnectParameters?.port, port)
        XCTAssertTrue(manager.isBlackTraxConnected)
    }
    
    
    func testNetworkManager_connectControlServer() {
        let port = 4321
        let mockDefaults = MockUserDefaults()
        mockDefaults.stubbedGetIntResult = port
        mockAll()
    
        manager.connectControlServer(from: mockDefaults)
    
        XCTAssertEqual(mOscServerControl.invokedPort, port)
        XCTAssertTrue(manager.isServerControlConnected)
    }
    
    
    func testNetworkManager_connectRecordedServer() {
        let port = 3967
        let mockDefaults = MockUserDefaults()
        mockDefaults.stubbedGetIntResult = port
        mockAll()
    
        manager.connectRecordedServer(from: mockDefaults)
    
        XCTAssertEqual(mOscServerRecorded.invokedPort, port)
        XCTAssertTrue(manager.isServerRecordedConnected)
    }
    
    
    func testNetworkManager_connectRecordedClient() {
        let addy = "/connect/recorded/client"
        let port = 9999
        let mockDefaults = MockUserDefaults()
        mockDefaults.stubbedGetStringResult = addy
        mockDefaults.stubbedGetIntResult = port
        mockAll()
        
        manager.connectRecordedClient(from: mockDefaults)
        
        XCTAssertEqual(mOscClientRecorded.invokedAddress, addy)
        XCTAssertEqual(mOscClientRecorded.invokedPort, port)
        XCTAssertTrue(manager.isClientRecordedConnected)
    }
    
    
    func testNetworkManager_connectLiveClient() {
        let addy = "/connect/live/client"
        let port = 7890
        let mockDefaults = MockUserDefaults()
        mockDefaults.stubbedGetStringResult = addy
        mockDefaults.stubbedGetIntResult = port
        mockAll()
        
        manager.connectLiveClient(from: mockDefaults)
        
        XCTAssertEqual(mOscClientLive.invokedAddress, addy)
        XCTAssertEqual(mOscClientLive.invokedPort, port)
        XCTAssertTrue(manager.isClientLiveConnected)
    }
}





// MARK: - Utility

extension NetworkManagerTests {

    func mockAll() {
        mBlackTrax = MockReceiveUDP()
        mOscServerControl = MDashOSCServer(.control, "/server/control", 1111)
        mOscServerRecorded = MDashOSCServer(.recorded, "/server/recorded", 2222)
        mOscClientRecorded = MDashOSCClient(.recorded, "/client/recorded", 3333)
        mOscClientLive = MDashOSCClient(.ds100, "/client/live", 4444)
        
        manager.blackTrax = mBlackTrax
        manager.oscServerControl = mOscServerControl
        manager.oscServerRecorded = mOscServerRecorded
        manager.oscClientRecorded = mOscClientRecorded
        manager.oscClientLive = mOscClientLive
    }
}





// MARK: - Mocks

class MockNetworkManagerDelegate: NetworkManagerDelegate {

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
}
