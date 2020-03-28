//
//  SocketTarget.swift
//  Websocket
//
//  Created by Benjamin Pisano on 22/03/2020.
//  Copyright © 2020 Snopia. All rights reserved.
//

import Cocoa
import SocketIO

protocol SocketTarget {
    
    var name: String { get }
    
    var items: [SocketData] { get }
    
}
