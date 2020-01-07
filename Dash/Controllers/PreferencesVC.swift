// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/7/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import Cocoa

class PreferencesVC: NSViewController {

    @IBOutlet weak var inputBlackTraxText: NSTextField!
    @IBOutlet weak var inputControlPortText: NSTextField!
    @IBOutlet weak var inputRecordedPortText: NSTextField!
    @IBOutlet weak var outputRecordedIPText: NSTextField!
    @IBOutlet weak var outputRecordedPortText: NSTextField!
    @IBOutlet weak var outputLiveIPText: NSTextField!
    @IBOutlet weak var outputLivePortText: NSTextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize = NSMakeSize(self.view.frame.width, self.view.frame.height)
    }
    
    
    override func viewDidAppear() {
        // update window title with active tabview title
        self.parent?.view.window?.title = self.title!
        
        // update textFields
        let idNetIn = DashDefaultIDs.Network.Incoming.self
        let idNetOut = DashDefaultIDs.Network.Outgoing.self
        
        inputBlackTraxText.stringValue = get(userDefault: idNetIn.blacktraxPort)
        inputControlPortText.stringValue = get(userDefault: idNetIn.controlPort)
        inputRecordedPortText.stringValue = get(userDefault: idNetIn.recordedPort)
        outputRecordedIPText.stringValue = get(userDefault: idNetOut.recordedIP)
        outputRecordedPortText.stringValue = get(userDefault: idNetOut.recordedPort)
        outputLiveIPText.stringValue = get(userDefault: idNetOut.liveIP)
        outputLivePortText.stringValue = get(userDefault: idNetOut.livePort)
    }
    
    
    @IBAction func resetDefaultsClicked(_ sender: Any) {
        
    }
}





//MARK: - Defaults
extension PreferencesVC {
    
    func setDefaults() {
        
    }
    
    
    func get(userDefault: String) -> String {
        guard let str = UserDefaults.standard.string(forKey: userDefault) else {return ""}
        return str
    }
}
