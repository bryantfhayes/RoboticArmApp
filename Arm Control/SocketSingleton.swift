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
    var client: UDPClient?
    
    //
    // Functions
    //
    private init() {
        self.client = UDPClient(addr: self.addr, port: self.port)
    }
    
    func sendXYZ(coordinates: [Int]) {
        self.sendPacket("xyz:\(coordinates[0]),\(coordinates[1]),\(coordinates[2])\0\n")
    }
    
    func sendPacket(message: String){
        self.client?.send(str: message)
        print("Sent message: \(message)")
    }
}