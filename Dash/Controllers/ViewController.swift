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
    fileprivate var _liveData = [RTTrPM]()
    
    
    override func viewWillAppear() {
        super.viewWillAppear()
        setupDefaults()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        let idNetIn = DashDefaultIDs.Network.Incoming.self
        let idNetOut = DashDefaultIDs.Network.Outgoing.self
        let defaultNetIn = DashDefaultValues.Network.Incoming.self
        let defaultNetOut = DashDefaultValues.Network.Outgoing.self
        
        UserDefaults.standard.set(defaultNetIn.blacktraxPort, forKey: idNetIn.blacktraxPort)
        UserDefaults.standard.set(defaultNetIn.controlPort, forKey: idNetIn.controlPort)
        UserDefaults.standard.set(defaultNetIn.vezerPort, forKey: idNetIn.recordedPort)
        UserDefaults.standard.set(defaultNetOut.ds100MainIP, forKey: idNetOut.liveIP)
        UserDefaults.standard.set(defaultNetOut.ds100MainPort, forKey: idNetOut.livePort)
        UserDefaults.standard.set(defaultNetOut.vezerIP, forKey: idNetOut.recordedIP)
        UserDefaults.standard.set(defaultNetOut.vezerPort, forKey: idNetOut.recordedPort)
    }
}





// MARK: - Table View
extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        switch tableView.identifier {
        case DashID.TableType.live:
            return _liveData.count
        case DashID.TableType.recorded:
            return 10 //TODO
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
            return createViewForRecorded(tableView, tableColumn!.identifier, row)
        
        default:
            return nil
        }
    }
    
    
    private func createViewForBlackTrax(_ tableView: NSTableView, _ columnIdentifier: NSUserInterfaceItemIdentifier, _ row: Int) -> NSView? {
        if _liveData.isEmpty {return nil}
        
        var id = NSUserInterfaceItemIdentifier("")
        var text = ""
        let data = _liveData[row]
        
        switch columnIdentifier {
        case DashID.Column.trackable:
            text = data.trackable?.name ?? ""
            id = DashID.Cell.trackable
            
        case DashID.Column.x:
            guard let packet = data.trackable?.submodules[.centroidAccVel] as? [CentroidAccVel] else {return nil}
            text = String(format: "%.3f", packet[0].position.x)
            id = DashID.Cell.x
            
        case DashID.Column.y:
            guard let packet = data.trackable?.submodules[.centroidAccVel] as? [CentroidAccVel] else {return nil}
            text = String(format: "%.3f", packet[0].position.y)
            id = DashID.Cell.y
            
        case DashID.Column.z:
            guard let packet = data.trackable?.submodules[.centroidAccVel] as? [CentroidAccVel] else {return nil}
            text = String(format: "%.3f", packet[0].position.z)
            id = DashID.Cell.z
            
        default:
            return nil
        }
        
        guard let cell = tableView.makeView(withIdentifier: id, owner: nil) as? NSTableCellView else {return nil}
        cell.textField?.stringValue = text
        
        return cell
    }
    
    
    private func createViewForRecorded(_ tableView: NSTableView, _ columnIdentifier: NSUserInterfaceItemIdentifier, _ row: Int) -> NSView? {
        var id = NSUserInterfaceItemIdentifier("")
        var text = ""
        
        switch columnIdentifier {
        case DashID.Column.trackable:
            text = "Trackable \(row)"
            id = DashID.Cell.trackable
            
        case DashID.Column.x:
            text = "x\(row)"
            id = DashID.Cell.x
            
        case DashID.Column.y:
            text = "y\(row)"
            id = DashID.Cell.y
            
        case DashID.Column.z:
            text = "z\(row)"
            id = DashID.Cell.z
            
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
    }
    
    
    @objc
    func liveBlackTrax(_ notif: Notification) {
        guard let data = notif.userInfo?[DashNotifData.rttrp] as? RTTrP else {
            return
        }
        
        _liveData = data.pmPackets
        _liveTable.reload()
    }
    
    
    @objc
    func changingActive(_ notif: Notification) {
        guard let output = notif.userInfo?[DashNotifData.switchOutputTo] as? ActiveOutput else {
            return
        }
        
        setSwitch(output)
    }
    
    
    private func addObserver(_ selector: Selector, _ name: NSNotification.Name?) {
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: nil)
    }
}
