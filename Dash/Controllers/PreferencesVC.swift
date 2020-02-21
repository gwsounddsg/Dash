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
        
        if self.title == "Connections" {
            updateFieldsWithDefaults()
        }
    }
    
    
    @IBAction func resetDefaultsClicked(_ sender: Any) {
        post(DashNotif.resetDefaults)
        updateFieldsWithDefaults()
    }
   
    
    @IBAction func serverBlackTraxPortEntered(_ sender: Any) {
        guard let data = stringForSender(sender) else {
            print("Sender error: \(sender)")
            return
        }
        post(DashNotif.userPrefServerBlackTraxPort, data)
    }
    
    
    @IBAction func serverControlPortEntered(_ sender: Any) {
        guard let data = stringForSender(sender) else {
            print("Sender error: \(sender)")
            return
        }
        post(DashNotif.userPrefServerControlPort, data)
    }
    
    
    @IBAction func serverVezerPortEntered(_ sender: Any) {
        guard let data = stringForSender(sender) else {
            print("Sender error: \(sender)")
            return
        }
        post(DashNotif.userPrefServerVezerPort, data)
    }
    
    
    @IBAction func clientVezerIPEntered(_ sender: Any) {
        guard let data = stringForSender(sender) else {
            print("Sender error: \(sender)")
            return
        }
        post(DashNotif.userPrefClientVezerIP, data)
    }
    
    
    @IBAction func clientVezerPortEntered(_ sender: Any) {
        guard let data = stringForSender(sender) else {
            print("Sender error: \(sender)")
            return
        }
        post(DashNotif.userPrefClientVezerPort, data)
    }
    
    
    @IBAction func clientDS100MainIPEntered(_ sender: Any) {
        guard let data = stringForSender(sender) else {
            print("Sender error: \(sender)")
            return
        }
        post(DashNotif.userPrefClientDS100MainIP, data)
    }
    
    
    @IBAction func clientDS100MainPortEntered(_ sender: Any) {
        guard let data = stringForSender(sender) else {
            print("Sender error: \(sender)")
            return
        }
        post(DashNotif.userPrefClientDS100MainPort, data)
    }
    
    
    private func stringForSender(_ sender: Any) -> String? {
        guard let field = sender as? NSTextField else {
            return nil
        }
        
        return field.stringValue
    }
    
    
    private func post(_ name: Notification.Name, _ info: String = "") {
        let dict = [DashNotifData.userPref: info]
        NotificationCenter.default.post(name: name, object: nil, userInfo: dict)
    }
}





// MARK: - Defaults
extension PreferencesVC {
    
    func updateFieldsWithDefaults() {
        let idNetIn = DashDefaultIDs.Network.Server.self
        let idNetOut = DashDefaultIDs.Network.Client.self
    
        inputBlackTraxText.stringValue = get(userDefault: idNetIn.blacktraxPort)
        inputControlPortText.stringValue = get(userDefault: idNetIn.controlPort)
        inputRecordedPortText.stringValue = get(userDefault: idNetIn.vezerPort)
        outputRecordedIPText.stringValue = get(userDefault: idNetOut.vezerIP)
        outputRecordedPortText.stringValue = get(userDefault: idNetOut.vezerPort)
        outputLiveIPText.stringValue = get(userDefault: idNetOut.ds100MainIP)
        outputLivePortText.stringValue = get(userDefault: idNetOut.ds100MainPort)
    }
    
    func get(userDefault: String, from defaults: UserDefaultsProtocol = UserDefaults.standard) -> String {
        return defaults.getString(forKey: userDefault) ?? ""
    }
}
