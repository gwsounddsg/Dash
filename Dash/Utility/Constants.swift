// ==================================================================
// Created by:  GW Rodriguez
// Date:        1/6/20
// Swift:       5.0
// Copyright:   Copyright © 2020 GW Rodriguez. All rights reserved.
// ==================================================================

import Cocoa

// swiftlint:disable nesting





// MARK: - Identifiers

enum DashID {
    enum TableType {
        static let live = NSUserInterfaceItemIdentifier("rttTableLive")
        static let recorded = NSUserInterfaceItemIdentifier("rttTableRec")
    }
    
    enum Column {
        static let trackable = NSUserInterfaceItemIdentifier("trackable")
        static let x = NSUserInterfaceItemIdentifier("x")
        static let y = NSUserInterfaceItemIdentifier("y")
        static let z = NSUserInterfaceItemIdentifier("z")
    }
    
    enum Cell {
        static let trackable = NSUserInterfaceItemIdentifier("cellTrackable")
        static let x = NSUserInterfaceItemIdentifier("cellX")
        static let y = NSUserInterfaceItemIdentifier("cellY")
        static let z = NSUserInterfaceItemIdentifier("cellZ")
    }
}


enum DashNotif {
    static let blacktrax = NSNotification.Name("blacktraxDataIn")
    static let updateSwitchTo = NSNotification.Name("updateSwitchTo")
    static let toggleSwitch = NSNotification.Name("toggleSwitch")
}


enum DashNotifData {
    static let rttrp = "rttrp"
    static let switchOutputTo = "switchOutputTo"
}





// MARK: - Types

typealias ClientsServers = (clients: [DashNetworkType.Client], servers: [DashNetworkType.Server])

enum DashNetworkType {
    enum Client {
        case vezer, ds100Main, ds100Backup
    }
    
    enum Server {
        case vezer, control, blackTrax
    }
}


enum DashError: Error {
    case CantGetDefaultValueFor(String)
}


enum DashImage {
    static let indicatorConnected = "NSStatusAvailable"
    static let indicatorNotConnected = "NSStatusUnavailable"
    static let activeBlackTrax = "NSGoBackTemplate"
    static let activeVezer = "NSGoForwardTemplate"
}


enum DashColor {
    static let activeBlackTrax = NSColor.systemBlue
    static let activeVezer = NSColor.systemRed
}


enum ControlMessage {
    case switchActive
}


enum ControlOSC {
    static let switchTo = "/dash/control/switch"
}


enum ActiveOutput {
    case blacktrax, vezer
}




// MARK: - UserDefaults

enum DashDefaultIDs {
    enum Network {
        enum Incoming {
            static let blacktraxPort = "networkIncomingBlackTraxPort"
            static let controlPort = "networkIncomingControlPort"
            static let recordedPort = "netowrkIncomingRecordedPort"
        }
        
        enum Outgoing {
            static let recordedIP = "networkOutgoingRecordedIP"
            static let recordedPort = "networkOutgoingRecordedPort"
            static let liveIP = "networkOutgoingLiveIP"
            static let livePort = "networkOutgoingLivePort"
        }
    }
}


enum DashDefaultValues {
    enum Network {
        enum Incoming {
            static let blacktraxPort = "24002"
            static let controlPort = "4202"
            static let recordedPort = "8000"
        }
        
        enum Outgoing {
            static let recordedIP = "127.0.0.1"
            static let recordedPort = "1234"
            static let liveIP = "127.0.0.1" // DS100 (do I need two?)
            static let livePort = "4545" // check number
        }
    }
}
