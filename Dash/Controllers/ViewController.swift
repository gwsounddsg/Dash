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
    
    // Indicators
    @IBOutlet weak var indicatorBlackTrax: NSImageView!
    @IBOutlet weak var indicatorControlIn: NSImageView!
    @IBOutlet weak var indicatorDS100Main: NSImageView!
    @IBOutlet weak var indicatorDS100Backup: NSImageView!
    @IBOutlet weak var indicatorVezerIn: NSImageView!
    @IBOutlet weak var indicatorVezerOut: NSImageView!
    
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
        
        networkManager.servers.delegate = self
        connectAll()

        _liveTable.reload()
        _recordedTable.reload()
    }
    
    
    func setupDefaults() {
        let idNetIn = DashDefaultIDs.Network.Incoming.self
        let idNetOut = DashDefaultIDs.Network.Outgoing.self
        let defaultNetIn = DashDefaultValues.Network.Incoming.self
        let defaultNetOut = DashDefaultValues.Network.Outgoing.self
    
        UserDefaults.standard.set(defaultNetIn.blacktraxPort, forKey: idNetIn.blacktraxPort)
        UserDefaults.standard.set(defaultNetIn.controlPort, forKey: idNetIn.controlPort)
        UserDefaults.standard.set(defaultNetIn.recordedPort, forKey: idNetIn.recordedPort)
        UserDefaults.standard.set(defaultNetOut.liveIP, forKey: idNetOut.liveIP)
        UserDefaults.standard.set(defaultNetOut.livePort, forKey: idNetOut.livePort)
        UserDefaults.standard.set(defaultNetOut.recordedIP, forKey: idNetOut.recordedIP)
        UserDefaults.standard.set(defaultNetOut.recordedPort, forKey: idNetOut.recordedPort)
    }
    
    
    @IBAction func refreshClicked(_ sender: Any) {
        connectAll()
    }
    
    
    func connectAll() {
        let result = networkManager.connectAll()
        print("Not connected: \(result)")
        
        indicatorBlackTrax.image = connectedImage(result.servers.contains(.blackTrax))
        indicatorControlIn.image = connectedImage(result.servers.contains(.control))
        indicatorDS100Main.image = connectedImage(result.clients.contains(.ds100Main))
        indicatorDS100Backup.image = connectedImage(result.clients.contains(.ds100Backup))
        indicatorVezerIn.image = connectedImage(result.servers.contains(.recorded))
        indicatorVezerOut.image = connectedImage(result.clients.contains(.recorded))
    }
    
    private func connectedImage(_ check: Bool) -> NSImage? {
        let str = check ? DashImage.indicatorNotConnected : DashImage.indicatorConnected
        return NSImage(named: str)
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





// MARK: - NetworkManagerDelegate
extension ViewController: ServersProtocol {
    
    func liveBlackTrax(_ data: RTTrP) {
        _liveData = data.pmPackets
        _liveTable.reload()
    }
}
