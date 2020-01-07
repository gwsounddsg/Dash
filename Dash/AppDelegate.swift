// ===================================================
// Created by:  GW Rodriguez
// Date:        12/24/19
// Copyright:   Copyright © 2019 GW Rodriguez. All rights reserved.
// ===================================================

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var preferencesController: NSWindowController?
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // register user defaults
        
        let idNetIn = DashDefaultIDs.Network.Incoming.self
        let idNetOut = DashDefaultIDs.Network.Outgoing.self
        let defaultNetIn = DashDefaultValues.Network.Incoming.self
        let defaultNetOut = DashDefaultValues.Network.Outgoing.self
        
        UserDefaults.standard.register(defaults: [
                idNetIn.blacktraxPort :     defaultNetIn.blacktraxPort,
                idNetIn.controlPort :       defaultNetIn.controlPort,
                idNetIn.recordedPort :      defaultNetIn.recordedPort,
                idNetOut.liveIP :           defaultNetOut.liveIP,
                idNetOut.livePort :         defaultNetOut.livePort,
                idNetOut.recordedIP :       defaultNetOut.recordedIP,
                idNetOut.recordedPort :     defaultNetOut.recordedPort
        ])
    }

    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


    @IBAction func showPreferences(_ sender: Any) {
        if !(preferencesController != nil) {
            let storyboard = NSStoryboard(name: NSStoryboard.Name("Preferences"), bundle: nil)
            preferencesController = storyboard.instantiateInitialController() as? NSWindowController
        }
        
        if preferencesController != nil {
            preferencesController!.showWindow(sender)
        }
    }
}

