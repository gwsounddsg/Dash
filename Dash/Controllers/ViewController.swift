// ===================================================
// Created by:  GW Rodriguez
// Date:        12/24/19
// Copyright:   Copyright © 2019 GW Rodriguez. All rights reserved.
// ===================================================

import Cocoa
import RTTrPSwift





class ViewController: NSViewController {
    
    @IBOutlet weak var liveTabView: NSTabView!
    
    fileprivate var _blackTrax: ReceiveUDP?
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
        if tableColumn == nil || _liveData.isEmpty {return NSTextField()}
        
        let textView = NSTextField()
        let data = _liveData[row]
        
        switch tableColumn!.identifier {
            case COLUMN_TRACKABLE:
                textView.stringValue = data.trackable?.name ?? ""
            
            case COLUMN_X:
                guard let packet = data.trackable?.submodules[.centroidAccVel] as? [CentroidAccVel] else {return textView}
                textView.stringValue = "\(packet[0].position.x)"
            
            case COLUMN_Y:
                guard let packet = data.trackable?.submodules[.centroidAccVel] as? [CentroidAccVel] else {return textView}
                textView.stringValue = "\(packet[0].position.y)"
            
            case COLUMN_Z:
                guard let packet = data.trackable?.submodules[.centroidAccVel] as? [CentroidAccVel] else {return textView}
                textView.stringValue = "\(packet[0].position.y)"
            
            default:
                break
        }
        
        return textView
    }
}





//MARK: - ReceiveUDP Delegate
extension ViewController: ReceiveUDPDelegate {
    
    func newPacket(_ data: RTTrP) {
        _liveData = data.pmPackets
        _liveTable.reload()
    }
}
