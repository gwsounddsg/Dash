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
    
    
    @IBAction func clearDataBlackTrax(_ sender: Any) {
        clear(.blacktrax)
    }
    
    
    @IBAction func clearDataVezer(_ sender: Any) {
        clear(.vezer)
    }
    
    
    private func clear(_ table: ActiveOutput) {
        let window = NSApp.windows[0]
        guard let vc = window.contentViewController as? ViewController else {
            print("bad view controller")
            return
        }
        
        vc.clearData(table)
    }
}

