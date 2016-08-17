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
        listenForUsersInChatRoom()
    }

    func closeConnection() {
        socket.disconnect()
    }

    func connectUser(username: String) {
        socket.emit("connectUser", username)
    }

    func getOnlineUsers(completionHandler: (userList: [[String:AnyObject]]!) -> Void) {
        socket.emit("connectedUsers")
        socket.on("connectedUsers") { (dataArray, ack) -> Void in
            var users = [[String: AnyObject]]()
            var newEntry = [String: AnyObject]()
            let onlineUsers = dataArray[0] as! [AnyObject]

            for user in 0..<onlineUsers.count {
                newEntry["username"] = onlineUsers[user]["username"] as! String
                newEntry["isConnected"] = onlineUsers[user]["isConnected"] as! Bool
                users.append(newEntry)
            }

            completionHandler(userList: users)
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

    func listenForUsersInChatRoom() {
        socket.on("userConnectUpdate") { (dataArray, socketAck) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("userWasConnectedNotification", object: dataArray[0] as! String)
        }

        socket.on("userExitUpdate") { (dataArray, socketAck) -> Void in
            NSNotificationCenter.defaultCenter().postNotificationName("userWasDisconnectedNotification", object: dataArray[0] as! String)
        }
    }

    func listenForOtherMessages() {
        socket.on("userTypingUpdate") { (data, socketAck) -> Void in
            let usersTyping = data as NSArray
            NSNotificationCenter.defaultCenter().postNotificationName("userTypingNotification", object: usersTyping[0] as? [String])
        }
    }

    func sendUserStartedTypingMessage(username: String) {
        socket.emit("startType", username)
        listenForOtherMessages()
    }
    
    func sendStopTypingMessage(username: String) {
        socket.emit("stopType", username)
        listenForOtherMessages()
    }
}
