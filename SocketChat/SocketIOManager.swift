//
//  SocketIOManager.swift
//  Socket Chat
//
//  Created by Tony Saavedra on 8/8/16.
//  Copyright © 2016 Tony Saavedra. All rights reserved.
//

import UIKit

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    var socket: SocketIOClient = SocketIOClient(socketURL: NSURL(string: "http://localhost:3000")!)

    override init() {
        super.init()
    }
    
    func establishConnection() {
        socket.connect()
    }
    
    func closeConnection() {
        socket.disconnect()
    }
}
