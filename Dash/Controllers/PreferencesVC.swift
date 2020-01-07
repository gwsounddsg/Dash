// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/7/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import Cocoa

class PreferencesVC: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.preferredContentSize = NSMakeSize(self.view.frame.width, self.view.frame.height)
    }
    
    
    override func viewDidAppear() {
        // update window title with active tabview title
        self.parent?.view.window?.title = self.title!
    }
}
