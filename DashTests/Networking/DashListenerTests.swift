// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/15/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import XCTest
import Network
@testable import Dash





class DashListenerTests: XCTestCase {
    let address = "/test/message/"
    let port: Int = 1234
    let queue = "test queue"

    fileprivate var mListener: MockDashListener!
    fileprivate var mConnection: MockNWConnection!


    override func setUp() {
        mListener = MockDashListener(address, port, queue, .control)
        mConnection = MockNWConnection()
    }
}





extension DashListenerTests {

    func testDashListener() {
        XCTAssertEqual(mListener.type, .control)
        XCTAssertEqual(mListener.address, address)
        XCTAssertEqual(mListener.port.rawValue, UInt16(port))
    }
    
    
    func testDashListener_receive() {
        
    }


//    func testDashListener_didReceive() {
//        let val: Float = 4.0
//        let msg = OSCMessage(OSCAddressPattern("/something"), val)
//        let delegate = MockDashListenerDelegate()
//        mListener.delegate = delegate
//
//        mListener.didReceive(msg)
//
//        XCTAssertEqual(delegate.invokedOscDataReceivedParameters?.msg.address, msg.address.string)
//        XCTAssertEqual(delegate.invokedOscDataReceivedParameters?.msg.values[0].data, msg.arguments[0]?.data)
//        XCTAssertEqual(delegate.invokedOscDataReceivedParameters?.from, .control)
//    }
//
//
//    func testDashListener_didReceive_vezer() {
//        let vezerData = Vezer("name", 3.0, 4.0)
//        let msg = OSCMessage(OSCAddressPattern(vezerData.addy().x), vezerData.x)
//        let delegate = MockDashListenerDelegate()
//
//        mListener = MockDashOSCListener(.vezer, address, port)
//        mListener.delegate = delegate
//        mListener.didReceive(msg)
//
//        XCTAssertEqual(delegate.invokedOscDataReceivedParameters?.msg.values.count, 2)
//        XCTAssertEqual(delegate.invokedOscDataReceivedParameters?.msg.values[1] as? String, "name")
//    }
}





// MARK: - Mocks
private class MockDashListener: DashListener {
    convenience init() {
        self.init("", 0, "", .control)
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
    var invoked_listener: NWListener?
    var invoked_listenerList = [NWListener?]()
    var invoked_listenerGetter = false
    var invoked_listenerGetterCount = 0
    var stubbed_listener: NWListener!

    override var _listener: NWListener? {
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

    var invokedPrintNetwork = false
    var invokedPrintNetworkCount = 0

    override func printNetwork() {
        invokedPrintNetwork = true
        invokedPrintNetworkCount += 1
    }
}

private class MockNWConnection: NWConnectionProtocol {
    var invokedStateUpdateHandlerSetter = false
    var invokedStateUpdateHandlerSetterCount = 0
    var invokedStateUpdateHandler: ((NWConnection.State) -> Void)?
    var invokedStateUpdateHandlerList = [((NWConnection.State) -> Void)?]()
    var invokedStateUpdateHandlerGetter = false
    var invokedStateUpdateHandlerGetterCount = 0
    var stubbedStateUpdateHandler: ((NWConnection.State) -> Void)!
    var stateUpdateHandler: ((NWConnection.State) -> Void)? {
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
    var invokedReceiveMessage = false
    var invokedReceiveMessageCount = 0
    var stubbedReceiveMessageCompletionResult: (Data?, NWConnection.ContentContext?, Bool, NWError?)?

    func receiveMessage(completion: @escaping (_ completeContent: Data?, _ contentContext: NWConnection.ContentContext?, _ isComplete: Bool, _ error: NWError?) -> Void) {
        invokedReceiveMessage = true
        invokedReceiveMessageCount += 1
        if let result = stubbedReceiveMessageCompletionResult {
            completion(result.0, result.1, result.2, result.3)
        }
    }
}
