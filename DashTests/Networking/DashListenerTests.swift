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

    fileprivate var mListener: MockNWListener!
    fileprivate var mConnection: MockNWConnection!
    fileprivate var mDelegate: MockDashListenerDelegate!
    
    fileprivate var dashListener: DashListener!


    override func setUp() {
        mListener = MockNWListener()
        mConnection = MockNWConnection()
        mDelegate = MockDashListenerDelegate()
        
        dashListener = DashListener(mListener, queue, .control)
        dashListener._connection = mConnection
        dashListener.delegate = mDelegate
    }
}





extension DashListenerTests {

    func testDashListener() {
        XCTAssertEqual(dashListener.type, .control)
    }
    
    
    func testDashListener_deinit() {
        dashListener = nil
        XCTAssertTrue(mListener.invokedCancel)
    }
    
    
    func testDashListener_receive() {
        dashListener.receive()
        XCTAssertTrue(mConnection.invokedReceiveMessage)
    }
    
    
    func testDashListener_port() {
        mListener.stubbedPort = NWEndpoint.Port(rawValue: UInt16(port))
        let val = dashListener.port()
        XCTAssertEqual(val, port)
    }
    
    
    func testDashListener_queue() {
        let val = dashListener.queue()
        XCTAssertEqual(val, queue)
    }
}





// MARK: - Mocks

class MockNWConnection: NWConnectionProtocol {
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


class MockDashListenerDelegate: DashListenerDelegate {

    var invokedListenerReceived = false
    var invokedListenerReceivedCount = 0
    var invokedListenerReceivedParameters: (data: Data, from: DashNetworkType.Listener)?
    var invokedListenerReceivedParametersList = [(data: Data, from: DashNetworkType.Listener)]()

    func listenerReceived(_ data: Data, _ from: DashNetworkType.Listener) {
        invokedListenerReceived = true
        invokedListenerReceivedCount += 1
        invokedListenerReceivedParameters = (data, from)
        invokedListenerReceivedParametersList.append((data, from))
    }
}
