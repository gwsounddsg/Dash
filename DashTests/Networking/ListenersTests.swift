// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/22/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import XCTest
import RTTrPSwift
import Network
@testable import Dash





// swiftlint:disable weak_delegate

class ListenersTests: XCTestCase {

    var listeners: Listeners!
    var mBlackTrax: MockDashListener!
    var mVezer: MockDashOSCListener!
    var mControl: MockDashOSCListener!
    var delegate: MockListenersProtocol!
    
    
    override func setUp() {
        listeners = Listeners()
        delegate = MockListenersProtocol()
        listeners.delegate = delegate
    }
}





extension ListenersTests {

    func testListeners() {
        XCTAssertFalse(listeners.isVezerConnected)
        XCTAssertFalse(listeners.isControlConnected)
        XCTAssertFalse(listeners.isBlackTraxConnected)
    }
    
    
    func testListeners_connectAll() {
        let addy = "/connect/server/"
        let port = 78901
        let mockDefaults = MockUserDefaults()
        mockDefaults.stubbedGetStringResult = addy
        mockDefaults.stubbedGetIntResult = port
        mockAll()
        
        XCTAssertFalse(listeners.isBlackTraxConnected)
        XCTAssertFalse(listeners.isVezerConnected)
        XCTAssertFalse(listeners.isControlConnected)
        
        let result = listeners.connectAll()
        
        XCTAssertTrue(result.isEmpty, result.description)
    }
    
    
    func testListeners_connectBlackTrax() {
        let addy = "/connect/server/blacktrax"
        let port = 85672
        let mockDefaults = MockUserDefaults()
        mockDefaults.stubbedGetStringResult = addy
        mockDefaults.stubbedGetIntResult = port
        mockAll()
        
        XCTAssertFalse(listeners.isBlackTraxConnected)
        
        listeners.connectBlackTrax(from: mockDefaults)
        
        XCTAssertTrue(listeners.isBlackTraxConnected)
    }
    
    
    func testListeners_connectVezer() {
        let addy = "/connect/server/vezer"
        let port = 32451
        let mockDefaults = MockUserDefaults()
        mockDefaults.stubbedGetStringResult = addy
        mockDefaults.stubbedGetIntResult = port
        mockAll()
    
        XCTAssertFalse(listeners.isVezerConnected)
    
        listeners.connectVezer(from: mockDefaults)
    
        XCTAssertTrue(listeners.isVezerConnected)
    }
    
    
    func testListeners_connectControl() {
        let addy = "/connect/server/vezer"
        let port = 44566
        let mockDefaults = MockUserDefaults()
        mockDefaults.stubbedGetStringResult = addy
        mockDefaults.stubbedGetIntResult = port
        mockAll()
    
        XCTAssertFalse(listeners.isControlConnected)
    
        listeners.connectControl(from: mockDefaults)
    
        XCTAssertTrue(listeners.isControlConnected)
    }
}





// MARK: - DashOSCListenerDelegate

extension ListenersTests {

    func testListeners_oscDataReceived_vezer() {
        let val: Double = 4.65
        let msg = OSCMessage("/testing/oscMessageReceived/vezer", [val])
        mockAll()
    
        listeners.oscMessageReceived(msg, .vezer)
        
        XCTAssertTrue(delegate.invokedRecordedVezer)
    }
}





// MARK: - Notification

extension ListenersTests {

    func testListeners_updateDefaults_listenerBlackTraxPort() {
        mockAll()
        let key = DashNotifData.userPref
        let value: Int = 1111
        let notif = notification(DashNotif.userPrefServerBlackTraxPort, [key: String(value)])
        let mDefaults = MockUserDefaults()
        mDefaults.stubbedGetIntResult = value
        
        XCTAssertFalse(listeners.isBlackTraxConnected)
        
        listeners.updateDefaults(notif, mDefaults)
        
        XCTAssertTrue(listeners.isBlackTraxConnected)
        XCTAssertEqual(mDefaults.invokedUpdateParameters?.forKey, DashDefaultIDs.Network.Listener.blacktraxPort)
        XCTAssertEqual(mDefaults.invokedUpdateParameters?.value as? Int, Int(value))
    }
    
    
    func testListeners_updateDefaults_listenerVezerPort() {
        mockAll()
        let key = DashNotifData.userPref
        let value = "1111"
        let notif = notification(DashNotif.userPrefServerVezerPort, [key: value])
        let mDefaults = MockUserDefaults()
        
        XCTAssertFalse(listeners.isVezerConnected)
        
        listeners.updateDefaults(notif, mDefaults)
        
        XCTAssertTrue(listeners.isVezerConnected)
        XCTAssertEqual(mDefaults.invokedUpdateParameters?.forKey, DashDefaultIDs.Network.Listener.vezerPort)
        XCTAssertEqual(mDefaults.invokedUpdateParameters?.value as? Int, Int(value))
    }
    
    
    func testListeners_updateDefaults_listenerControlPort() {
        mockAll()
        let key = DashNotifData.userPref
        let value = "1111"
        let notif = notification(DashNotif.userPrefServerControlPort, [key: value])
        let mDefaults = MockUserDefaults()
        
        XCTAssertFalse(listeners.isControlConnected)
        
        listeners.updateDefaults(notif, mDefaults)
        
        XCTAssertTrue(listeners.isControlConnected)
        XCTAssertEqual(mDefaults.invokedUpdateParameters?.forKey, DashDefaultIDs.Network.Listener.controlPort)
        XCTAssertEqual(mDefaults.invokedUpdateParameters?.value as? Int, Int(value))
    }
}





// MARK: - Utility

extension  ListenersTests {

    func mockAll(_ connected: Bool = false) {
        mBlackTrax = MockDashListener()
        mVezer = MockDashOSCListener(type: .vezer)
        mControl = MockDashOSCListener(type: .control)
        
        listeners.blackTrax = mBlackTrax
        listeners.vezer = mVezer
        listeners.control = mControl
        
        if connected {
            let mockDefaults = MockUserDefaults()
            mockDefaults.stubbedGetStringResult = "mocking"
            mockDefaults.stubbedGetIntResult = 9999
            
            _ = listeners.connectAll(from: mockDefaults)
        }
    }
    
    
    func notification(_ name: Notification.Name, _ info: [String: String]) -> Notification {
        return Notification(name: name, userInfo: info)
    }
}





// MARK: - Mocks


class MockListenersProtocol: ListenersProtocol {

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

    var invokedRecordedVezer = false
    var invokedRecordedVezerCount = 0
    var invokedRecordedVezerParameters: (data: OSCMessage, Void)?
    var invokedRecordedVezerParametersList = [(data: OSCMessage, Void)]()

    func recordedVezer(_ data: OSCMessage) {
        invokedRecordedVezer = true
        invokedRecordedVezerCount += 1
        invokedRecordedVezerParameters = (data, ())
        invokedRecordedVezerParametersList.append((data, ()))
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

class MockDashOSCListener: DashOSCListener {
    
    convenience init(type: DashNetworkType.Listener = .vezer, mockListener: MockNWListener = MockNWListener()) {
        self.init(mockListener, "MockDashOSCListener", type)
    }
    
    var invokedOscDelegateSetter = false
    var invokedOscDelegateSetterCount = 0
    var invokedOscDelegate: DashOSCListenerDelegate?
    var invokedOscDelegateList = [DashOSCListenerDelegate?]()
    var invokedOscDelegateGetter = false
    var invokedOscDelegateGetterCount = 0
    var stubbedOscDelegate: DashOSCListenerDelegate!
    override var oscDelegate: DashOSCListenerDelegate? {
        set {
            invokedOscDelegateSetter = true
            invokedOscDelegateSetterCount += 1
            invokedOscDelegate = newValue
            invokedOscDelegateList.append(newValue)
        }
        get {
            invokedOscDelegateGetter = true
            invokedOscDelegateGetterCount += 1
            return stubbedOscDelegate
        }
    }
    var invokedDelegateSetter = false
    var invokedDelegateSetterCount = 0
    var invokedDelegate: DashListenerDelegate?
    var invokedDelegateList = [DashListenerDelegate?]()
    var invokedDelegateGetter = false
    var invokedDelegateGetterCount = 0
    var stubbedDelegate: DashListenerDelegate!
    override var delegate: DashListenerDelegate? {
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
    var invoked_listenerSetter = false
    var invoked_listenerSetterCount = 0
    var invoked_listener: NWListenerProtocol?
    var invoked_listenerList = [NWListenerProtocol]()
    var invoked_listenerGetter = false
    var invoked_listenerGetterCount = 0
    var stubbed_listener: NWListenerProtocol!
    override var _listener: NWListenerProtocol {
        set {
            invoked_listenerSetter = true
            invoked_listenerSetterCount += 1
            invoked_listener = newValue
            invoked_listenerList.append(newValue)
        }
        get {
            invoked_listenerGetter = true
            invoked_listenerGetterCount += 1
            return stubbed_listener
        }
    }
    var invoked_connectionSetter = false
    var invoked_connectionSetterCount = 0
    var invoked_connection: NWConnectionProtocol?
    var invoked_connectionList = [NWConnectionProtocol?]()
    var invoked_connectionGetter = false
    var invoked_connectionGetterCount = 0
    var stubbed_connection: NWConnectionProtocol!
    override var _connection: NWConnectionProtocol? {
        set {
            invoked_connectionSetter = true
            invoked_connectionSetterCount += 1
            invoked_connection = newValue
            invoked_connectionList.append(newValue)
        }
        get {
            invoked_connectionGetter = true
            invoked_connectionGetterCount += 1
            return stubbed_connection
        }
    }
    var invokedReceive = false
    var invokedReceiveCount = 0

    override func receive() {
        invokedReceive = true
        invokedReceiveCount += 1
    }

    var invokedPort = false
    var invokedPortCount = 0
    var stubbedPortResult: Int! = 0

    override func port() -> Int {
        invokedPort = true
        invokedPortCount += 1
        return stubbedPortResult
    }

    var invokedQueue = false
    var invokedQueueCount = 0
    var stubbedQueueResult: String! = ""

    override func queue() -> String {
        invokedQueue = true
        invokedQueueCount += 1
        return stubbedQueueResult
    }

    var invokedPrintNetwork = false
    var invokedPrintNetworkCount = 0

    override func printNetwork() {
        invokedPrintNetwork = true
        invokedPrintNetworkCount += 1
    }
}


class MockDashListener: DashListener {

    convenience init(mockListener: MockNWListener = MockNWListener()) {
        self.init(mockListener, "", .control)
    }

    var invokedDelegateSetter = false
    var invokedDelegateSetterCount = 0
    var invokedDelegate: DashListenerDelegate?
    var invokedDelegateList = [DashListenerDelegate?]()
    var invokedDelegateGetter = false
    var invokedDelegateGetterCount = 0
    var stubbedDelegate: DashListenerDelegate!
    override var delegate: DashListenerDelegate? {
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
    var invoked_connectionSetter = false
    var invoked_connectionSetterCount = 0
    var invoked_connection: NWConnectionProtocol?
    var invoked_connectionList = [NWConnectionProtocol?]()
    var invoked_connectionGetter = false
    var invoked_connectionGetterCount = 0
    var stubbed_connection: NWConnectionProtocol!
    override var _connection: NWConnectionProtocol? {
        set {
            invoked_connectionSetter = true
            invoked_connectionSetterCount += 1
            invoked_connection = newValue
            invoked_connectionList.append(newValue)
        }
        get {
            invoked_connectionGetter = true
            invoked_connectionGetterCount += 1
            return stubbed_connection
        }
    }
    var invokedReceive = false
    var invokedReceiveCount = 0

    override func receive() {
        invokedReceive = true
        invokedReceiveCount += 1
    }

    var invokedPort = false
    var invokedPortCount = 0
    var stubbedPortResult: Int! = 0

    override func port() -> Int {
        invokedPort = true
        invokedPortCount += 1
        return stubbedPortResult
    }

    var invokedQueue = false
    var invokedQueueCount = 0
    var stubbedQueueResult: String! = ""

    override func queue() -> String {
        invokedQueue = true
        invokedQueueCount += 1
        return stubbedQueueResult
    }

    var invokedPrintNetwork = false
    var invokedPrintNetworkCount = 0

    override func printNetwork() {
        invokedPrintNetwork = true
        invokedPrintNetworkCount += 1
    }
}


class MockNWListener: NWListenerProtocol {

    var invokedPortGetter = false
    var invokedPortGetterCount = 0
    var stubbedPort: NWEndpoint.Port!
    var port: NWEndpoint.Port? {
        invokedPortGetter = true
        invokedPortGetterCount += 1
        return stubbedPort
    }
    var invokedStateUpdateHandlerSetter = false
    var invokedStateUpdateHandlerSetterCount = 0
    var invokedStateUpdateHandler: ((NWListener.State) -> Void)?
    var invokedStateUpdateHandlerList = [((NWListener.State) -> Void)?]()
    var invokedStateUpdateHandlerGetter = false
    var invokedStateUpdateHandlerGetterCount = 0
    var stubbedStateUpdateHandler: ((NWListener.State) -> Void)!
    var stateUpdateHandler: ((NWListener.State) -> Void)? {
        set {
            invokedStateUpdateHandlerSetter = true
            invokedStateUpdateHandlerSetterCount += 1
            invokedStateUpdateHandler = newValue
            invokedStateUpdateHandlerList.append(newValue)
        }
        get {
            invokedStateUpdateHandlerGetter = true
            invokedStateUpdateHandlerGetterCount += 1
            return stubbedStateUpdateHandler
        }
    }
    var invokedNewConnectionHandlerSetter = false
    var invokedNewConnectionHandlerSetterCount = 0
    var invokedNewConnectionHandler: ((NWConnection) -> Void)?
    var invokedNewConnectionHandlerList = [((NWConnection) -> Void)?]()
    var invokedNewConnectionHandlerGetter = false
    var invokedNewConnectionHandlerGetterCount = 0
    var stubbedNewConnectionHandler: ((NWConnection) -> Void)!
    var newConnectionHandler: ((NWConnection) -> Void)? {
        set {
            invokedNewConnectionHandlerSetter = true
            invokedNewConnectionHandlerSetterCount += 1
            invokedNewConnectionHandler = newValue
            invokedNewConnectionHandlerList.append(newValue)
        }
        get {
            invokedNewConnectionHandlerGetter = true
            invokedNewConnectionHandlerGetterCount += 1
            return stubbedNewConnectionHandler
        }
    }
    var invokedCancel = false
    var invokedCancelCount = 0

    func cancel() {
        invokedCancel = true
        invokedCancelCount += 1
    }

    var invokedStart = false
    var invokedStartCount = 0
    var invokedStartParameters: (queue: DispatchQueue, Void)?
    var invokedStartParametersList = [(queue: DispatchQueue, Void)]()

    func start(queue: DispatchQueue) {
        invokedStart = true
        invokedStartCount += 1
        invokedStartParameters = (queue, ())
        invokedStartParametersList.append((queue, ()))
    }
}
