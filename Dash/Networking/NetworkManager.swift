// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/7/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import Foundation
import RTTrPSwift





class NetworkManager {
    
    // Singleton
    static let instance = NetworkManager()
    
    fileprivate let _blackTrax = ReceiveUDP()
//    fileprivate let _oscServerControl: DashOSCServer
//    fileprivate let _oscServerRecorded: DashOSC
    
    
    init() {
        _blackTrax.delegate = self
    }
}





//MARK: - Receive BlackTrax
extension NetworkManager: ReceiveUDPDelegate {
    
    func newPacket(_ data: RTTrP) {
        
    }
}
