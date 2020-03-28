//
//  GameSocketManger.swift
//  Websocket
//
//  Created by Benjamin Pisano on 22/03/2020.
//  Copyright © 2020 Snopia. All rights reserved.
//

import Cocoa
import SocketIO

final class GameSocketManger<T: SocketTarget> {

    private let socketManager: SocketManager
    private let roomSocket: SocketIOClient
    
    init(url: URL, room: String) {
        self.socketManager = SocketManager(socketURL: url, config: [.compress])
        self.roomSocket = socketManager.socket(forNamespace: "/\(room)")
    }
    
    func connect() {
        roomSocket.connect()
    }
    
    func emit(event: T) {
        roomSocket.emit(event.name, event.items)
    }
    
    func on(event: T, _ completion: @escaping (_ data: [Any]) -> Void) {
        roomSocket.on(event.name) { (data, _) in
            completion(data)
        }
    }
    
}
