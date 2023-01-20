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
