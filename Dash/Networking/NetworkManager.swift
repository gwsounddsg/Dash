// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/7/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import Foundation
import RTTrPSwift





class NetworkManager {
    
    let servers: Servers
    let clients: Clients
    
    var ds100Mapping = "1"
    var output: ActiveOutput = .blacktrax
    
    
    init(_ setClient: Clients = Clients(), _ setServers: Servers = Servers()) {
        clients = setClient
        servers = setServers
        servers.delegate = self
    }
}




extension NetworkManager {
    
    func connectAll(from defaults: UserDefaultsProtocol = UserDefaults.standard) -> ClientsServers {
        let badClients = clients.connectAll(from: defaults)
        let badServers = servers.connectAll(from: defaults)
        return (clients: badClients, servers: badServers)
    }
    
    
    func sendOSC(message: Message, to client: DashNetworkType.Client) -> Bool {
        return clients.sendOSC(message: message, to: client)
    }
    
    
    func send(ds100 data: [DS100], coordinates: Coordinate) -> Bool {
        return clients.send(ds100: data, coordinate: coordinates)
    }
    
    
    func redirectFromBlackTrax(data: RTTrP) {
        let ds100Data = prepareDS100Data(data)
        _ = send(ds100: ds100Data, coordinates: .all)
    }
    
    
    func redirectFromVezer(data: Message) {
        let elements = data.address.split(separator: "/")
        let name = String(elements[1])
        let coord: Coordinate = String(elements[2]) == "x" ? .x : .y
        let val = data.values[0] as? Float ?? 0.0
        
        let ds100Data = DS100(ds100Mapping, input: name, x: val, y: val, spread: 0.5)
        _ = send(ds100: [ds100Data], coordinates: coord)
    }
    
    
    func toBeRecorded(data: RTTrP) {
        let vezerData = prepareVezerData(data)
        _ = clients.send(vezer: vezerData)
    }
}





// MARK: - ServersProtocol

extension NetworkManager: ServersProtocol {
    
    func liveBlackTrax(_ data: RTTrP) {
        // send to ds100?
        if output == .blacktrax {
            redirectFromBlackTrax(data: data)
        }
        
        // send to be recorded
        toBeRecorded(data: data)
        
        // update GUI
        let dictInfo: [String: RTTrP] = [DashNotifData.rttrp: data]
        post(DashNotif.blacktrax, dictInfo)
    }
    
    func recordedVezer(_ data: Message) {
        if output == .vezer {
            redirectFromVezer(data: data)
        }
        
        let info = [DashNotifData.message: data]
        NotificationCenter.default.post(name: DashNotif.recordedVezerIn, object: nil, userInfo: info)
    }
    
    func command(control: ControlMessage, data: Any?) {
        switch control {
        case .switchActive:
            guard let str = data as? String else {
                print("Bad data for control message switchActive")
                return
            }
            
            let lowercase = str.lowercased()
            switch lowercase {
            case "blacktrax":
                output = .blacktrax
            case "vezer":
                output = .vezer
            default:
                print("Invalid value for control message switchActive. Use 'blacktrax' or 'vezer'")
                return
            }
            
            post(DashNotif.updateSwitchTo, [DashNotifData.switchOutputTo: output])
        }
    }
}





// MARK: - Utility

fileprivate extension NetworkManager {
    
    func post(_ name: Notification.Name, _ userInfo: [String: Any]? = nil) {
        NotificationCenter.default.post(name: name, object: nil, userInfo: userInfo)
    }
    
    
    func prepareVezerData(_ data: RTTrP) -> [Vezer] {
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
    
    
    func prepareDS100Data(_ data: RTTrP) -> [DS100] {
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
            
            let x = Float(centroid[0].position.x)
            let y = Float(centroid[0].position.y)
            
            ds100Data.append(DS100(ds100Mapping, input: trackable.name, x: x, y: y, spread: 0.5))
        }
        
        return ds100Data
    }
}
