// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/6/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import Cocoa





class RttTableView: NSView {
    
    @IBOutlet weak var view: NSView!
    @IBOutlet weak var scrollView: NSScrollView!
    @IBOutlet weak var tableView: NSTableView!
    
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        Bundle.main.loadNibNamed("RttTableView", owner: self, topLevelObjects: nil)
        //TODO: - add identifier to tableView
        self.addSubview(self.view)
    }
    
    
    required init?(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
    
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        setupView(dirtyRect)
    }
}





extension RttTableView {
    
    func setupView(_ rect: NSRect) {
        Swift.print(rect.debugDescription)
        view.frame = NSRect(x: 0, y: 0, width: rect.width, height: rect.height)
        scrollView.frame = NSRect(x: 0, y: 0, width: rect.width, height: rect.height)
        
        // set column sizes
        let paramWidth: CGFloat = 52
        tableView.tableColumns[1].width = paramWidth
        tableView.tableColumns[2].width = paramWidth
        tableView.tableColumns[3].width = paramWidth
        tableView.tableColumns[0].width = rect.width - (paramWidth * 3) - 10
    }
    
    
    func reload() {
        tableView.reloadData()
    }
}
