// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/7/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import Foundation
import RTTrPSwift





class NetworkManager {
    
    enum Output {
        case vezer, blacktrax
    }
    
    let servers = Servers()
    let clients = Clients()
    
    var ds100Mapping = "1"
    
    var output: Output = .blacktrax {
        didSet {
            if output == .blacktrax {
                outputFunc = redirectDS100
            } else {
                outputFunc = redirectVezer
            }
        }
    }
    
    fileprivate lazy var outputFunc: (RTTrP) -> Void = redirectDS100
}




extension NetworkManager {
    
    func sendOSC(message: Message, to client: DashNetworkType.Client) -> Bool {
        return clients.sendOSC(message: message, to: client)
    }
    
    
    func send(ds100 data: [DS100]) -> Bool {
        return clients.send(ds100: data)
    }
    
    
    func connectAll(from defaults: UserDefaultsProtocol = UserDefaults.standard) -> ClientsServers {
        let badClients = clients.connectAll(from: defaults)
        let badServers = servers.connectAll(from: defaults)
        return (clients: badClients, servers: badServers)
    }
    
    
    func redirectDS100(data: RTTrP) {
        let ds100Data = prepareDS100Data(data)
        _ = clients.send(ds100: ds100Data)
    }
    
    
    func redirectVezer(data: RTTrP) {
        let vezerData = prepareVezerData(data)
        _ = clients.send(vezer: vezerData)
    }
    
    
    private func prepareDS100Data(_ data: RTTrP) -> [DS100] {
        let pmPackets = data.pmPackets
        var ds100Data = [DS100]()
    
        for packet in pmPackets {
            guard let trackable = packet.trackable else {
                continue
            }
        
            guard let centroid = trackable.submodules[.centroidAccVel] as? [CentroidAccVel] else {
                continue
            }
        
            if centroid.isEmpty {continue}
        
            let x = centroid[0].position.x
            let y = centroid[0].position.y
        
            ds100Data.append(DS100(ds100Mapping, input: trackable.name, x: x, y: y))
        }
        
        return ds100Data
    }
    
    
    private func prepareVezerData(_ data: RTTrP) -> [Vezer] {
        let pmPackets = data.pmPackets
        var vezerData = [Vezer]()
        
        for packet in pmPackets {
            guard let trackable = packet.trackable else {
                continue
            }
            
            guard let centroid = trackable.submodules[.centroidAccVel] as? [CentroidAccVel] else {
                continue
            }
            
            if centroid.isEmpty {continue}
            
            let x = centroid[0].position.x
            let y = centroid[0].position.y
            
            vezerData.append(Vezer(trackable.name, x, y))
        }
        
        return vezerData
    }
}





// MARK: - ServersProtocol

extension NetworkManager: ServersProtocol {
    
    func liveBlackTrax(_ data: RTTrP) {
        outputFunc(data)
        
        let dictInfo: [String: RTTrP] = [DashNotifData.rttrp: data]
        NotificationCenter.default.post(name: DashNotif.blacktrax, object: nil, userInfo: dictInfo)
    }
}
