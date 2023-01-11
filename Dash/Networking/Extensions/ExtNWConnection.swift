//
//  ExtNWConnection.swift
//  Dash
//
//  Created by GW Rodriguez on 1/11/23.
//  Copyright © 2023 GW Rodriguez. All rights reserved.
//

import Foundation
import Network



extension NWConnection: NWConnectionProtocol {}


protocol NWConnectionProtocol {
    var stateUpdateHandler: ((_ state: NWConnection.State) -> Void)? { get set }
    
    func receiveMessage(completion: @escaping (_ completeContent: Data?, _ contentContext: NWConnection.ContentContext?, _ isComplete: Bool, _ error: NWError?) -> Void)
}
