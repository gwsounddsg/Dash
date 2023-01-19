// ===================================================
// Created by:  GW Rodriguez
// Date:        12/24/19
// Copyright:   Copyright © 2019 GW Rodriguez. All rights reserved.
// ===================================================

import Cocoa
import RTTrPSwift





class ViewController: NSViewController {
    
    // TableViews
    @IBOutlet weak var liveTabView: NSTabView!
    @IBOutlet weak var recordedTabView: NSTabView!
    
    // Images
    @IBOutlet weak var indicatorBlackTrax: NSImageView!
    @IBOutlet weak var indicatorControlIn: NSImageView!
    @IBOutlet weak var indicatorDS100Main: NSImageView!
    @IBOutlet weak var indicatorDS100Backup: NSImageView!
    @IBOutlet weak var indicatorVezerIn: NSImageView!
    @IBOutlet weak var indicatorVezerOut: NSImageView!
    @IBOutlet weak var switchButton: NSButton!
    
    // Network
    let networkManager = NetworkManager()
    
    // Private
    fileprivate var _liveTable: RttTableView!
    fileprivate var _recordedTable: RttTableView!
    fileprivate var _liveData = [String: CentroidAccVel]()
    fileprivate var _vezerData = [String: [String: Float]]() // [Name: [x/y: value]]
    
    
    override func viewWillAppear() {
        super.viewWillAppear()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDefaults()
        
        let liveTabViewItem = liveTabView.tabViewItem(at: 0)
        let recTabViewItem = recordedTabView.tabViewItem(at: 0)
        
        _liveTable = RttTableView(frame: liveTabViewItem.view!.frame)
        _liveTable.tableView.delegate = self
        _liveTable.tableView.dataSource = self
        _liveTable.tableView.identifier = DashID.TableType.live
        liveTabViewItem.view = _liveTable

        _recordedTable = RttTableView(frame: liveTabViewItem.view!.frame)
        _recordedTable.tableView.delegate = self
        _recordedTable.tableView.dataSource = self
        _recordedTable.tableView.identifier = DashID.TableType.recorded
        recTabViewItem.view = _recordedTable
        
        createObservers()
        connectAll()

        _liveTable.reload()
        _recordedTable.reload()
    }
    
    
    @IBAction func refreshClicked(_ sender: Any) {
        connectAll()
    }
    
    
    @IBAction func switchClicked(_ sender: Any) {
        toggleSwitch()
    }
    
    
    func clearData(_ type: ActiveOutput) {
        if type == .blacktrax {
            _liveData.removeAll()
            _liveTable.reload()
        }
        else {
            _vezerData.removeAll()
            _recordedTable.reload()
        }
    }
}





// MARK: - Table View

extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        switch tableView.identifier {
        case DashID.TableType.live:
            return _liveData.count
        case DashID.TableType.recorded:
            return _vezerData.count
        default:
            return 0
        }
    }

    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn == nil {return nil}
        
        switch tableView.identifier {
        case DashID.TableType.live:
            return createViewForBlackTrax(tableView, tableColumn!.identifier, row)
        
        case DashID.TableType.recorded:
            return createViewForVezer(tableView, tableColumn!.identifier, row)
        
        default:
            return nil
        }
    }
    
    
    private func createViewForBlackTrax(_ tableView: NSTableView, _ columnIdentifier: NSUserInterfaceItemIdentifier, _ row: Int) -> NSView? {
        if _liveData.isEmpty {return nil}
        
        guard let trackableName = getTrackableID(row + 1) else {
            print("Can't find trackable name for row: \(row + 1)")
            return nil
        }
        
        guard let centroidModule = _liveData[trackableName] else {
            print("Row \(row) doesn't exist")
            return nil
        }
        
        var id = NSUserInterfaceItemIdentifier("")
        var text = ""
        
        switch columnIdentifier {
        case DashID.Column.trackable:
            text = trackableName
            id = DashID.Cell.trackable
            
        case DashID.Column.x:
            text = String(format: "%.3f", centroidModule.position.x)
            id = DashID.Cell.x
            
        case DashID.Column.y:
            text = String(format: "%.3f", centroidModule.position.y)
            id = DashID.Cell.y
            
        case DashID.Column.z:
            text = String(format: "%.3f", centroidModule.position.z)
            id = DashID.Cell.z
            
        default:
            return nil
        }
        
        guard let cell = tableView.makeView(withIdentifier: id, owner: nil) as? NSTableCellView else {return nil}
        cell.textField?.stringValue = text
        
        return cell
    }
    
    
    private func createViewForVezer(_ tableView: NSTableView, _ columnIdentifier: NSUserInterfaceItemIdentifier, _ row: Int) -> NSView? {
        if _vezerData.isEmpty {return nil}
    
        guard let trackableName = getTrackableID(row + 1) else {
            print("Can't find trackable name for row: \(row + 1)")
            return nil
        }
        
        var indexName = trackableName
        indexName.remove(at: indexName.startIndex)
    
        guard let data = _vezerData[indexName] else {
            print("Row \(row) doesn't exist")
            return nil
        }
        
        var id = NSUserInterfaceItemIdentifier("")
        var text = ""
        
        switch columnIdentifier {
        case DashID.Column.trackable:
            text = trackableName
            id = DashID.Cell.trackable
            
        case DashID.Column.x:
            text = String(format: "%.3f", data["x"] ?? "")
            id = DashID.Cell.x
            
        case DashID.Column.y:
            text = String(format: "%.3f", data["y"] ?? "")
            id = DashID.Cell.y
            
        default:
            return nil
        }
        
        guard let cell = tableView.makeView(withIdentifier: id, owner: nil) as? NSTableCellView else {return nil}
        cell.textField?.stringValue = text
        
        return cell
    }
}





// MARK: - Notifications

extension ViewController {
    
    func createObservers() {
        addObserver(#selector(liveBlackTrax), DashNotif.blacktrax)
        addObserver(#selector(changingActive), DashNotif.updateSwitchTo)
        addObserver(#selector(recordedVezer), DashNotif.recordedVezerIn)
        addObserver(#selector(resetDefaults), DashNotif.resetDefaults)
    }
    
    
    @objc
    func liveBlackTrax(_ notif: Notification) {
        guard let data = notif.userInfo?[DashNotifData.rttrp] as? RTTrP else {
            return
        }
        
        for rttrpm in data.pmPackets {
            if let trackable = rttrpm.trackable {
                checkTrackable(trackable.name)
                _liveData[trackable.name] = trackable.submodules[.centroidAccVel]?[0] as? CentroidAccVel ?? nil
                _liveTable.reload()
            }
        }
    }
    
    
    @objc
    func changingActive(_ notif: Notification) {
        guard let output = notif.userInfo?[DashNotifData.switchOutputTo] as? ActiveOutput else {
            return
        }
        
        setSwitch(output)
    }
    
    
    @objc
    func recordedVezer(_ notif: Notification) {
        guard let message = notif.userInfo?[DashNotifData.message] as? Message else {return}
        guard let value = message.values[0] as? Float else {return}
        guard let name = message.values[1] as? String else {return}
        guard let coord = message.addressPart(2) else {return}
    
        checkTrackable(name)
        
        if _vezerData[name] == nil {
            _vezerData[name] = [coord: value]
        }
        else {
            _vezerData[name]![coord] = value
        }
        
        _recordedTable.reload()
    }
    
    
    @objc
    func resetDefaults(_ notif: Notification) {
        let idNetIn = DashDefaultIDs.Network.Listener.self
        let idNetOut = DashDefaultIDs.Network.Client.self
        let defaultNetIn = DashDefaultValues.Network.Incoming.self
        let defaultNetOut = DashDefaultValues.Network.Outgoing.self
        
        UserDefaults.standard.update(value: defaultNetIn.blacktraxPort, forKey: idNetIn.blacktraxPort)
        UserDefaults.standard.update(value: defaultNetIn.controlPort, forKey: idNetIn.controlPort)
        UserDefaults.standard.update(value: defaultNetIn.vezerPort, forKey: idNetIn.vezerPort)
        UserDefaults.standard.update(value: defaultNetOut.ds100MainIP, forKey: idNetOut.ds100MainIP)
        UserDefaults.standard.update(value: defaultNetOut.ds100MainPort, forKey: idNetOut.ds100MainPort)
        UserDefaults.standard.update(value: defaultNetOut.vezerIP, forKey: idNetOut.vezerIP)
        UserDefaults.standard.update(value: defaultNetOut.vezerPort, forKey: idNetOut.vezerPort)
        
        connectAll()
    }
    
    
    private func addObserver(_ selector: Selector, _ name: NSNotification.Name?) {
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: nil)
    }
}





// MARK: - Utility

private extension ViewController {
    
    func connectAll() {
        let result = networkManager.connectAll()
        print("Not connected: \(result)")
        
        indicatorBlackTrax.image = connectedImage(result.servers.contains(.blackTrax))
        indicatorControlIn.image = connectedImage(result.servers.contains(.control))
        indicatorDS100Main.image = connectedImage(result.clients.contains(.ds100Main))
        indicatorDS100Backup.image = connectedImage(result.clients.contains(.ds100Backup))
        indicatorVezerIn.image = connectedImage(result.servers.contains(.vezer))
        indicatorVezerOut.image = connectedImage(result.clients.contains(.vezer))
        
        networkManager.servers.printNetworks()
        networkManager.clients.printNetworks()
    }
    
    private func connectedImage(_ check: Bool) -> NSImage? {
        let str = check ? DashImage.indicatorNotConnected : DashImage.indicatorConnected
        return NSImage(named: str)
    }
    
    
    func setupDefaults() {
        let idNetIn = DashDefaultIDs.Network.Listener.self
        let idNetOut = DashDefaultIDs.Network.Client.self
        let defaultNetIn = DashDefaultValues.Network.Incoming.self
        let defaultNetOut = DashDefaultValues.Network.Outgoing.self
    
        UserDefaults.standard.register(defaults: [idNetIn.blacktraxPort: defaultNetIn.blacktraxPort])
        UserDefaults.standard.register(defaults: [idNetIn.controlPort: defaultNetIn.controlPort])
        UserDefaults.standard.register(defaults: [idNetIn.vezerPort: defaultNetIn.vezerPort])
        UserDefaults.standard.register(defaults: [idNetOut.ds100MainIP: defaultNetOut.ds100MainIP])
        UserDefaults.standard.register(defaults: [idNetOut.ds100MainPort: defaultNetOut.ds100MainPort])
        UserDefaults.standard.register(defaults: [idNetOut.vezerIP: defaultNetOut.vezerIP])
        UserDefaults.standard.register(defaults: [idNetOut.vezerPort: defaultNetOut.vezerPort])
    }
    
    
    func toggleSwitch() {
        networkManager.output = networkManager.output == .blacktrax ? .vezer : .blacktrax
        setSwitch(networkManager.output)
        print("Active input is now: \(networkManager.output)")
    }
    
    
    func setSwitch(_ output: ActiveOutput) {
        var image: NSImage?
        var color: NSColor?
        
        switch output {
        case .blacktrax:
            image = NSImage(named: DashImage.activeBlackTrax)
            color = DashColor.activeBlackTrax
        case .vezer:
            image = NSImage(named: DashImage.activeVezer)
            color = DashColor.activeVezer
        }
        
        switchButton.image = image!
        switchButton.contentTintColor = color!
    }
    
    
    func getTrackableID(_ row: Int) -> String? {
        var trackableName: String?
        
        for (key, value) in networkManager.currentTrackables where value == row {
            trackableName = key
            break
        }
        
        return trackableName
    }
    
    func checkTrackable(_ name: String) {
        if networkManager.currentTrackables[name] == nil {
            var str = name
            str.remove(at: str.startIndex)
            networkManager.currentTrackables[name] = Int(str)
        }
    }
}











