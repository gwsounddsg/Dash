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
    static let recordedVezerIn = NSNotification.Name("recordedVezerIn")
    static let updateSwitchTo = NSNotification.Name("updateSwitchTo")
    static let toggleSwitch = NSNotification.Name("toggleSwitch")
    
    static let userPrefServerBlackTraxPort = NSNotification.Name("userPrefServerBlackTraxPort")
    static let userPrefServerControlPort = NSNotification.Name("userPrefServerControlPort")
    static let userPrefServerVezerPort = NSNotification.Name("userPreferenceServerVezerPort")
    static let userPrefClientVezerIP = NSNotification.Name("userPrefClientVezerIP")
    static let userPrefClientVezerPort = NSNotification.Name("userPrefClientVezerPort")
    static let userPrefClientDS100MainIP = NSNotification.Name("userPrefClientDS100MainIP")
    static let userPrefClientDS100MainPort = NSNotification.Name("userPrefClientDS100MainPort")
    
    static let resetDefaults = NSNotification.Name("resetDefaults")
}


enum DashNotifData {
    static let rttrp = "rttrp"
    static let switchOutputTo = "switchOutputTo"
    static let userPref = "userPref"
    static let message = "message"
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


enum Coordinate {
    case x, y, z, all
}





// MARK: - UserDefaults

enum DashDefaultIDs {
    enum Network {
        enum Server {
            static let blacktraxPort = "networkIncomingBlackTraxPort"
            static let controlPort = "networkIncomingControlPort"
            static let vezerPort = "networkIncomingVezerPort"
        }
        
        enum Client {
            static let vezerIP = "networkOutgoingVezerIP"
            static let vezerPort = "networkOutgoingVezerPort"
            static let ds100MainIP = "networkOutgoingDS100MainIP"
            static let ds100MainPort = "networkOutgoingDS100MainPort"
        }
    }
}


enum DashDefaultValues {
    enum Network {
        enum Incoming {
            static let blacktraxPort: Int = 24002
            static let controlPort: Int = 4202
            static let vezerPort: Int = 8000
        }
        
        enum Outgoing {
            static let vezerIP = "127.0.0.1"
            static let vezerPort: Int = 1234
            static let ds100MainIP = "192.168.1.100"
            static let ds100MainPort: Int = 50010
        }
    }
}
