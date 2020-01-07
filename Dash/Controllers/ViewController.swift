// ===================================================
// Created by:  GW Rodriguez
// Date:        12/24/19
// Copyright:   Copyright © 2019 GW Rodriguez. All rights reserved.
// ===================================================

import Cocoa
import RTTrPSwift





class ViewController: NSViewController {
    
    @IBOutlet weak var liveTabView: NSTabView!
    
    let networkManager = NetworkManager.instance
    
    fileprivate var _liveTable: RttTableView!
    fileprivate var _recordedTable: RttTableView!
    fileprivate var _liveData = [RTTrPM]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabViewItem = liveTabView.tabViewItem(at: 0)
        
        _liveTable = RttTableView(frame: tabViewItem.view!.frame)
        _liveTable.tableView.delegate = self
        _liveTable.tableView.dataSource = self
        tabViewItem.view = _liveTable
    }
}





//MARK: - Table View
extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return _liveData.count
    }

    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableColumn == nil || _liveData.isEmpty {return nil}
        
        let data = _liveData[row]
        var id = NSUserInterfaceItemIdentifier("")
        var text = ""
        
        switch tableColumn!.identifier {
            case DashID.Column.trackable:
                text = data.trackable?.name ?? ""
                id = DashID.Cell.trackable

            case DashID.Column.x:
                guard let packet = data.trackable?.submodules[.centroidAccVel] as? [CentroidAccVel] else {return nil}
                text = "\(packet[0].position.x)"
                id = DashID.Cell.x

            case DashID.Column.y:
                guard let packet = data.trackable?.submodules[.centroidAccVel] as? [CentroidAccVel] else {return nil}
                text = "\(packet[0].position.y)"
                id = DashID.Cell.y

            case DashID.Column.z:
                guard let packet = data.trackable?.submodules[.centroidAccVel] as? [CentroidAccVel] else {return nil}
                text = "\(packet[0].position.z)"
                id = DashID.Cell.z

            default:
                return nil
        }
        
        guard let cell = tableView.makeView(withIdentifier: id, owner: nil) as? NSTableCellView else {return nil}
        cell.textField?.stringValue = text
        
        return cell
    }
}





////MARK: - ReceiveUDP Delegate
//extension ViewController: ReceiveUDPDelegate {
//    
//    func newPacket(_ data: RTTrP) {
//        _liveData = data.pmPackets
//        _liveTable.reload()
//    }
//}
