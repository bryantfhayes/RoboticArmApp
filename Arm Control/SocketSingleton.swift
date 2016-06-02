//
//  SocketSingleton.swift
//  Arm Control
//
//  Created by BryantHayes on 4/28/16.
//  Copyright © 2016 wipwopgames. All rights reserved.
//

import Foundation

class SocketSingleton {
    //
    // Singleton Creation
    //
    static let sharedInstance = SocketSingleton()
    
    //
    // Variables
    //
    var addr: String =  "edison.local"
    var port: Int = 21224
    var sender: UDPClient?
    var receiver: UDPServer?
    let recvLen: Int = 255
    
    //
    // Functions
    //
    private init() {
        self.sender = UDPClient(addr: self.addr, port: self.port)
        self.receiver = UDPServer(addr: "", port: 21224)
    }
    
    func ping() -> Bool {
        self.sendPacket("hello")
        let (data, _, _) = (self.receiver?.recv(recvLen))!
        if data == "hello,ok" {
            return true;
        } else {
            return false
        }
    }
    
    func setCommand(str: String) -> Bool {
        self.sendPacket(str)
        let (data, _, _) = (self.receiver?.recv(recvLen))!
        if data == "\(str.componentsSeparatedByString(",")[0]),ok" {
            return true;
        } else {
            return false
        }
    }
    
    func getCommand(str: String) -> (Bool, String) {
        self.sendPacket(str)
        let (data, _, _) = (self.receiver?.recv(recvLen))!
        if data == "" {
            return (false, "Timeout error")
        } else {
            return (true, data)
        }
    }
    
    func flushBuffer() {
        let (_, _, _) = (self.receiver?.recv(recvLen))!
        return
    }
    
    func readPacket() -> (Bool, String) {
        let (data, _, _) = (self.receiver?.recv(recvLen))!
        if data == "" {
            return (false, "timeout")
        } else {
            return (true, data)
        }

    }
    
    func sendPacket(message: String){
        self.sender?.send(str: message)
        print("Sent message: \(message)")
    }
}