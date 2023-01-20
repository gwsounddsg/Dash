//
//  ExtNWListener.swift
//  Dash
//
//  Created by GW Rodriguez on 1/20/23.
//  Copyright © 2023 GW Rodriguez. All rights reserved.
//

import Foundation
import Network


extension NWListener: NWListenerProtocol {}


protocol NWListenerProtocol {
    var port: NWEndpoint.Port? { get }
    var stateUpdateHandler: ((_ newState: NWListener.State) -> Void)? { get set }
    var newConnectionHandler: ((_ connection: NWConnection) -> Void)? { get set }
    
    func cancel()
    func start(queue: DispatchQueue)
}
