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

    func connectToServerWithUsername(username: String, completionHandler: (userList: [[String: AnyObject]]!) -> Void) {
        socket.emit("connectUser", username)

        socket.on("userList") { (dataArray, ack) -> Void in
            completionHandler(userList: dataArray[0] as! [[String: AnyObject]])
        }
    }
    
    func sendMessage(message: String, withUsername username: String) {
        socket.emit("chat message", message, username)
    }
    
    func getChatMessage(completionHandler: (messageInfo:[String: AnyObject]) -> Void) {
        socket.on("chat message") { (dataArray, socketAck) -> Void in
            var messageDictionary = [String: AnyObject]()
            messageDictionary["message"] = dataArray[0] as! String
            messageDictionary["username"] = dataArray[1] as! String
            messageDictionary["date"] = dataArray[2] as! String
            
            completionHandler(messageInfo: messageDictionary)
        }
    }
}
