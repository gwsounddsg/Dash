// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/15/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import XCTest
import RTTrPSwift
@testable import Dash





class NetworkManagerTests: XCTestCase {

    var manager: NetworkManager!
    var mClients: MockClients!
    var mServers: MockServers!

    
    override func setUp() {
        manager = NetworkManager()
    }
}





extension NetworkManagerTests {

    func testNetworkManager() {
        XCTAssertTrue(manager.servers.delegate === manager)
    }
    
    
    func testNetworkManager_connectAll() {
        mockAll()
        mClients.stubbedConnectAllResult = []
        mServers.stubbedConnectAllResult = []
        
        let result = manager.connectAll()
        
        XCTAssertTrue(result.clients.isEmpty)
        XCTAssertTrue(result.servers.isEmpty)
        XCTAssertTrue(mClients.invokedConnectAll)
        XCTAssertTrue(mServers.invokedConnectAll)
    }
    
    
    func testNetworkManager_sendOSC() {
        mockAll()
        mClients.stubbedSendOSCResult = true
        let msg = Message("/sendosc", [nil])
        
        let result = manager.sendOSC(message: msg, to: .vezer)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mClients.invokedSendOSC)
    }
    
    
    func testNetworkManager_sendDS100() {
        mockAll()
        mClients.stubbedSendDs100Result = true
        let data = DS100("4", input: "88", x: 3, y: 2, spread: 0.5)
        let coord: Coordinate = .x
        
        let result = manager.send(ds100: [data], coordinates: coord)
        
        XCTAssertTrue(result)
        XCTAssertTrue(mClients.invokedSendDs100)
    }
    
    
    func testNetworkManager_redirectDS100() {
        mockAll()
        mClients.stubbedSendDs100Result = true
        guard let data = try? RTTrP(data: rttData) else {
            assertionFailure()
            return
        }
        manager.currentTrackables[data.pmPackets[0].trackable!.name] = 0
        
        manager.redirectFromBlackTrax(data: data)
        
        XCTAssertEqual(mClients.invokedSendDs100Parameters?.data[0].mapping, "1")
    }
    
    
    func testNetworkManager_redirectFromVezer() {
        mockAll()
        mClients.stubbedSendResult = true
        let val: Float = 3.2
        let msg = Message("/trackable/name/coord", [val])
        
        manager.redirectFromVezer(data: msg)
        
        if !mClients.invokedSendDs100 {
            XCTAssertTrue(false, "send ds100 not called")
            return
        }
        
        XCTAssertEqual(mClients.invokedSendDs100Parameters?.data[0].mapping, manager.ds100Mapping)
        XCTAssertEqual(mClients.invokedSendDs100Parameters?.data[0].input, "name")
        XCTAssertEqual(mClients.invokedSendDs100Parameters?.data[0].x, val)
        XCTAssertEqual(mClients.invokedSendDs100Parameters?.data[0].y, val)
        XCTAssertEqual(mClients.invokedSendDs100Parameters?.data[0].spread, 0.5)
    }
    
    
    func testNetworkManager_toBeRecorded() {
        mockAll()
        mClients.stubbedSendResult = true
        
        guard let data = try? RTTrP(data: rttData) else {
            assertionFailure()
            return
        }
        manager.currentTrackables[data.pmPackets[0].trackable!.name] = 0
        
        manager.toBeRecorded(data: data)
        
        XCTAssertEqual(mClients.invokedSendParameters?.data[0].name, "0")
    }
}





// MARK: - ServersProtocol

extension NetworkManagerTests {
    
    func testNetworkManager_liveBlackTrax() {
        mockAll()
        mClients.stubbedSendDs100Result = true
        guard let data = try? RTTrP(data: rttData) else {
            assertionFailure()
            return
        }
        manager.currentTrackables[data.pmPackets[0].trackable!.name] = 0

        expectation(forNotification: DashNotif.blacktrax, object: nil, handler: { (notif) -> Bool in
            let info = notif.userInfo as? [String: RTTrP]
            XCTAssertNotNil(info)
            return info != nil
        })
                    
        manager.liveBlackTrax(data)

        // checks outputFunc is called
        XCTAssertEqual(mClients.invokedSendDs100Parameters?.data[0].mapping, "1")
        waitForExpectations(timeout: 1)
    }
    
    
    func testNetworkManager_command_switchActive_blacktrax() {
        mockAll()
        let osc = "blAckTRax" // odd spelling intentional
        manager.output = .vezer
        
        expectation(forNotification: DashNotif.updateSwitchTo, object: nil, handler: { (notif) -> Bool in
            let info = notif.userInfo as? [String: ActiveOutput]
            XCTAssertNotNil(info, "\(String(describing: notif.userInfo))")
            return info != nil
        })
        
        manager.command(control: .switchActive, data: osc)
        
        XCTAssertEqual(manager.output, .blacktrax)
        waitForExpectations(timeout: 1)
    }
    
    
    func testNetworkManager_command_switchActive_vezer() {
        mockAll()
        let osc = "VEZer" // odd spelling intentional
        manager.output = .blacktrax
        
        expectation(forNotification: DashNotif.updateSwitchTo, object: nil, handler: { (notif) -> Bool in
            let info = notif.userInfo as? [String: ActiveOutput]
            XCTAssertNotNil(info)
            return info != nil
        })
        
        manager.command(control: .switchActive, data: osc)
        
        XCTAssertEqual(manager.output, .vezer)
        waitForExpectations(timeout: 2)
    }
}





// MARK: - Utility

extension NetworkManagerTests {

    func mockAll() {
        mClients = MockClients()
        mServers = MockServers()
        manager = NetworkManager(mClients, mServers)
    }
}





// MARK: - Mocks

// swiftlint:disable weak_delegate

class MockServers: Listeners {
    
    var invokedBlackTraxSetter = false
    var invokedBlackTraxSetterCount = 0
    var invokedBlackTrax: ReceiveUDP?
    var invokedBlackTraxList = [ReceiveUDP]()
    var invokedBlackTraxGetter = false
    var invokedBlackTraxGetterCount = 0
    var stubbedBlackTrax: ReceiveUDP!
    override var blackTrax: ReceiveUDP {
        set {
            invokedBlackTraxSetter = true
            invokedBlackTraxSetterCount += 1
            invokedBlackTrax = newValue
            invokedBlackTraxList.append(newValue)
        }
        get {
            invokedBlackTraxGetter = true
            invokedBlackTraxGetterCount += 1
            return stubbedBlackTrax
        }
    }
    var invokedVezerSetter = false
    var invokedVezerSetterCount = 0
    var invokedVezer: DashOSCServer?
    var invokedVezerList = [DashOSCServer?]()
    var invokedVezerGetter = false
    var invokedVezerGetterCount = 0
    var stubbedVezer: DashOSCServer!
    override var vezer: DashOSCServer? {
        set {
            invokedVezerSetter = true
            invokedVezerSetterCount += 1
            invokedVezer = newValue
            invokedVezerList.append(newValue)
        }
        get {
            invokedVezerGetter = true
            invokedVezerGetterCount += 1
            return stubbedVezer
        }
    }
    var invokedControlSetter = false
    var invokedControlSetterCount = 0
    var invokedControl: DashOSCServer?
    var invokedControlList = [DashOSCServer?]()
    var invokedControlGetter = false
    var invokedControlGetterCount = 0
    var stubbedControl: DashOSCServer!
    override var control: DashOSCServer? {
        set {
            invokedControlSetter = true
            invokedControlSetterCount += 1
            invokedControl = newValue
            invokedControlList.append(newValue)
        }
        get {
            invokedControlGetter = true
            invokedControlGetterCount += 1
            return stubbedControl
        }
    }
    var invokedDelegateSetter = false
    var invokedDelegateSetterCount = 0
    var invokedDelegate: ListenersProtocol?
    var invokedDelegateList = [ListenersProtocol?]()
    var invokedDelegateGetter = false
    var invokedDelegateGetterCount = 0
    var stubbedDelegate: ListenersProtocol!
    override var delegate: ListenersProtocol? {
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
    var invokedIsBlackTraxConnectedGetter = false
    var invokedIsBlackTraxConnectedGetterCount = 0
    var stubbedIsBlackTraxConnected: Bool! = false
    override var isBlackTraxConnected: Bool {
        invokedIsBlackTraxConnectedGetter = true
        invokedIsBlackTraxConnectedGetterCount += 1
        return stubbedIsBlackTraxConnected
    }
    var invokedIsVezerConnectedGetter = false
    var invokedIsVezerConnectedGetterCount = 0
    var stubbedIsVezerConnected: Bool! = false
    override var isVezerConnected: Bool {
        invokedIsVezerConnectedGetter = true
        invokedIsVezerConnectedGetterCount += 1
        return stubbedIsVezerConnected
    }
    var invokedIsControlConnectedGetter = false
    var invokedIsControlConnectedGetterCount = 0
    var stubbedIsControlConnected: Bool! = false
    override var isControlConnected: Bool {
        invokedIsControlConnectedGetter = true
        invokedIsControlConnectedGetterCount += 1
        return stubbedIsControlConnected
    }
    var invokedConnectAll = false
    var invokedConnectAllCount = 0
    var invokedConnectAllParameters: (defaults: UserDefaultsProtocol, Void)?
    var invokedConnectAllParametersList = [(defaults: UserDefaultsProtocol, Void)]()
    var stubbedConnectAllResult: [DashNetworkType.Server]! = []
    
    override func connectAll(from defaults: UserDefaultsProtocol = UserDefaults.standard) -> [DashNetworkType.Server] {
        invokedConnectAll = true
        invokedConnectAllCount += 1
        invokedConnectAllParameters = (defaults, ())
        invokedConnectAllParametersList.append((defaults, ()))
        return stubbedConnectAllResult
    }
    
    var invokedConnectBlackTrax = false
    var invokedConnectBlackTraxCount = 0
    var invokedConnectBlackTraxParameters: (defaults: UserDefaultsProtocol, Void)?
    var invokedConnectBlackTraxParametersList = [(defaults: UserDefaultsProtocol, Void)]()
    
    override func connectBlackTrax(from defaults: UserDefaultsProtocol = UserDefaults.standard) {
        invokedConnectBlackTrax = true
        invokedConnectBlackTraxCount += 1
        invokedConnectBlackTraxParameters = (defaults, ())
        invokedConnectBlackTraxParametersList.append((defaults, ()))
    }
    
    var invokedConnectVezer = false
    var invokedConnectVezerCount = 0
    var invokedConnectVezerParameters: (defaults: UserDefaultsProtocol, Void)?
    var invokedConnectVezerParametersList = [(defaults: UserDefaultsProtocol, Void)]()
    
    override func connectVezer(from defaults: UserDefaultsProtocol = UserDefaults.standard) {
        invokedConnectVezer = true
        invokedConnectVezerCount += 1
        invokedConnectVezerParameters = (defaults, ())
        invokedConnectVezerParametersList.append((defaults, ()))
    }
    
    var invokedConnectControl = false
    var invokedConnectControlCount = 0
    var invokedConnectControlParameters: (defaults: UserDefaultsProtocol, Void)?
    var invokedConnectControlParametersList = [(defaults: UserDefaultsProtocol, Void)]()
    
    override func connectControl(from defaults: UserDefaultsProtocol = UserDefaults.standard) {
        invokedConnectControl = true
        invokedConnectControlCount += 1
        invokedConnectControlParameters = (defaults, ())
        invokedConnectControlParametersList.append((defaults, ()))
    }
}


class MockClients: Clients {
    
    var invokedVezerSetter = false
    var invokedVezerSetterCount = 0
    var invokedVezer: DashOSCClient?
    var invokedVezerList = [DashOSCClient?]()
    var invokedVezerGetter = false
    var invokedVezerGetterCount = 0
    var stubbedVezer: DashOSCClient!
    override var vezer: DashOSCClient? {
        set {
            invokedVezerSetter = true
            invokedVezerSetterCount += 1
            invokedVezer = newValue
            invokedVezerList.append(newValue)
        }
        get {
            invokedVezerGetter = true
            invokedVezerGetterCount += 1
            return stubbedVezer
        }
    }
    var invokedDs100MainSetter = false
    var invokedDs100MainSetterCount = 0
    var invokedDs100Main: DashOSCClient?
    var invokedDs100MainList = [DashOSCClient?]()
    var invokedDs100MainGetter = false
    var invokedDs100MainGetterCount = 0
    var stubbedDs100Main: DashOSCClient!
    override var ds100Main: DashOSCClient? {
        set {
            invokedDs100MainSetter = true
            invokedDs100MainSetterCount += 1
            invokedDs100Main = newValue
            invokedDs100MainList.append(newValue)
        }
        get {
            invokedDs100MainGetter = true
            invokedDs100MainGetterCount += 1
            return stubbedDs100Main
        }
    }
    var invokedIsVezerConnectedGetter = false
    var invokedIsVezerConnectedGetterCount = 0
    var stubbedIsVezerConnected: Bool! = false
    override var isVezerConnected: Bool {
        invokedIsVezerConnectedGetter = true
        invokedIsVezerConnectedGetterCount += 1
        return stubbedIsVezerConnected
    }
    var invokedIsDS100MainConnectedGetter = false
    var invokedIsDS100MainConnectedGetterCount = 0
    var stubbedIsDS100MainConnected: Bool! = false
    override var isDS100MainConnected: Bool {
        invokedIsDS100MainConnectedGetter = true
        invokedIsDS100MainConnectedGetterCount += 1
        return stubbedIsDS100MainConnected
    }
    var invokedConnectAll = false
    var invokedConnectAllCount = 0
    var invokedConnectAllParameters: (defaults: UserDefaultsProtocol, Void)?
    var invokedConnectAllParametersList = [(defaults: UserDefaultsProtocol, Void)]()
    var stubbedConnectAllResult: [DashNetworkType.Client]! = []
    
    override func connectAll(from defaults: UserDefaultsProtocol = UserDefaults.standard) -> [DashNetworkType.Client] {
        invokedConnectAll = true
        invokedConnectAllCount += 1
        invokedConnectAllParameters = (defaults, ())
        invokedConnectAllParametersList.append((defaults, ()))
        return stubbedConnectAllResult
    }
    
    var invokedConnectVezer = false
    var invokedConnectVezerCount = 0
    var invokedConnectVezerParameters: (defaults: UserDefaultsProtocol, Void)?
    var invokedConnectVezerParametersList = [(defaults: UserDefaultsProtocol, Void)]()
    
    override func connectVezer(from defaults: UserDefaultsProtocol = UserDefaults.standard) {
        invokedConnectVezer = true
        invokedConnectVezerCount += 1
        invokedConnectVezerParameters = (defaults, ())
        invokedConnectVezerParametersList.append((defaults, ()))
    }
    
    var invokedConnectDS100Main = false
    var invokedConnectDS100MainCount = 0
    var invokedConnectDS100MainParameters: (defaults: UserDefaultsProtocol, Void)?
    var invokedConnectDS100MainParametersList = [(defaults: UserDefaultsProtocol, Void)]()
    
    override func connectDS100Main(from defaults: UserDefaultsProtocol = UserDefaults.standard) {
        invokedConnectDS100Main = true
        invokedConnectDS100MainCount += 1
        invokedConnectDS100MainParameters = (defaults, ())
        invokedConnectDS100MainParametersList.append((defaults, ()))
    }
    
    var invokedSendOSC = false
    var invokedSendOSCCount = 0
    var invokedSendOSCParameters: (message: Message, client: DashNetworkType.Client)?
    var invokedSendOSCParametersList = [(message: Message, client: DashNetworkType.Client)]()
    var stubbedSendOSCResult: Bool! = false
    
    override func sendOSC(message: Message, to client: DashNetworkType.Client) -> Bool {
        invokedSendOSC = true
        invokedSendOSCCount += 1
        invokedSendOSCParameters = (message, client)
        invokedSendOSCParametersList.append((message, client))
        return stubbedSendOSCResult
    }
    
    var invokedSendDs100 = false
    var invokedSendDs100Count = 0
    var invokedSendDs100Parameters: (data: [DS100], coordinate: Coordinate)?
    var invokedSendDs100ParametersList = [(data: [DS100], coordinate: Coordinate)]()
    var stubbedSendDs100Result: Bool! = false
    
    override func send(ds100 data: [DS100], coordinate: Coordinate = .all) -> Bool {
        invokedSendDs100 = true
        invokedSendDs100Count += 1
        invokedSendDs100Parameters = (data, coordinate)
        invokedSendDs100ParametersList.append((data, coordinate))
        return stubbedSendDs100Result
    }
    
    var invokedSend = false
    var invokedSendCount = 0
    var invokedSendParameters: (data: [Vezer], Void)?
    var invokedSendParametersList = [(data: [Vezer], Void)]()
    var stubbedSendResult: Bool! = false
    
    override func send(vezer data: [Vezer]) -> Bool {
        invokedSend = true
        invokedSendCount += 1
        invokedSendParameters = (data, ())
        invokedSendParametersList.append((data, ()))
        return stubbedSendResult
    }
    
    var invokedPrintNetworks = false
    var invokedPrintNetworksCount = 0
    
    override func printNetworks() {
        invokedPrintNetworks = true
        invokedPrintNetworksCount += 1
    }
}
