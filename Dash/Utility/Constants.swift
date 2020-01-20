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





// MARK: - Types

enum DashNetworkType {
    enum Client {
        case recorded, ds100
    }
    
    enum Server {
        case recorded, control, blackTrax
    }
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
            static let controlPort = "53000"
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
