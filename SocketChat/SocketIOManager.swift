//
//  SocketIOManager.swift
//  Socket Chat
//
//  Created by Tony Saavedra on 8/8/16.
//  Copyright © 2016 Tony Saavedra. All rights reserved.
//

import UIKit
import SocketIO

class SocketIOManager: NSObject {
    static let sharedInstance = SocketIOManager()
    var socket: SocketIOClient = SocketIOClient(socketURL: URL(string: "http://localhost:3000")!)

    override init() {
        super.init()
    }

    func establishConnection() {
        socket.connect()
        listenForUsersInChatRoom()
    }

    func closeConnection() {
        socket.disconnect()
    }

    func connectUser(_ username: String) {
        socket.emit("connectUser", username)
    }

    func getOnlineUsers(_ completionHandler: @escaping (_ userList: [[String:AnyObject]]?) -> Void) {
        socket.emit("connectedUsers")
        socket.on("connectedUsers") { (dataArray, ack) -> Void in
            var users = [[String: AnyObject]]()
            var newEntry = [String: AnyObject]()
            let onlineUsers = dataArray[0] as! [AnyObject]

            for user in 0..<onlineUsers.count {
                newEntry["username"] = onlineUsers[user]["username"] as AnyObject?
                newEntry["isConnected"] = onlineUsers[user]["isConnected"] as AnyObject?
                users.append(newEntry)
            }

            completionHandler(users)
        }
    }

    func sendMessage(_ message: String, withUsername username: String) {
        socket.emit("chat message", message, username)
    }

    func getChatMessage(_ completionHandler: @escaping (_ messageInfo:[String: AnyObject]) -> Void) {
        socket.on("chat message") { (dataArray, socketAck) -> Void in
            var messageDictionary = [String: AnyObject]()
            messageDictionary["message"] = dataArray[0] as AnyObject?
            messageDictionary["username"] = dataArray[1] as AnyObject?
            messageDictionary["date"] = dataArray[2] as AnyObject?

            completionHandler(messageDictionary)
        }
    }

    func listenForUsersInChatRoom() {
        socket.on("userConnectUpdate") { (dataArray, socketAck) -> Void in
            NotificationCenter.default.post(name: Notification.Name(rawValue: "userWasConnectedNotification"), object: dataArray[0] as! String)
        }

        socket.on("userExitUpdate") { (dataArray, socketAck) -> Void in
            NotificationCenter.default.post(name: Notification.Name(rawValue: "userWasDisconnectedNotification"), object: dataArray[0] as! String)
        }
    }

    func listenForOtherMessages() {
        socket.on("userTypingUpdate") { (data, socketAck) -> Void in
            let usersTyping = data as NSArray
            NotificationCenter.default.post(name: Notification.Name(rawValue: "userTypingNotification"), object: usersTyping[0] as? [String])
        }
    }

    func sendUserStartedTypingMessage(_ username: String) {
        socket.emit("startType", username)
        listenForOtherMessages()
    }
    
    func sendStopTypingMessage(_ username: String) {
        socket.emit("stopType", username)
        listenForOtherMessages()
    }
}
