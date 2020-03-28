//
//  GameSocketTarget.swift
//  Websocket
//
//  Created by Benjamin Pisano on 22/03/2020.
//  Copyright © 2020 Snopia. All rights reserved.
//

import Cocoa
import SocketIO

enum GameSocketTarget {
    
    case spaceshipDidConnect(playerId: String)
    case spaceshipDidDisconnect(playerId: String)
    case spaceshipDidUpdatePosition(playerId: String, position: CGPoint, rotation: CGFloat)
    case spaceshipDidFire(playerId: String)
    case spaceshipHasBeenHit(playerId: String, damage: CGFloat)
    case spaceshipHasBeenKilled
    case spaceshipTimerBeforeRespawn
    case spaceshipDidRespawn

}

extension GameSocketTarget: SocketTarget {    
    
    var name: String {
        switch self {
        case .spaceshipDidConnect:
            return "spaceshipDidConnect"
        case .spaceshipDidDisconnect:
            return "spaceshipDidDisconnect"
        case .spaceshipDidUpdatePosition:
            return "spaceshipDidUpdatePosition"
        case .spaceshipDidFire:
            return "spaceshipDidFire"
        case .spaceshipHasBeenHit:
            return "spaceshipHasBeenHit"
        case .spaceshipHasBeenKilled:
            return "spaceshipHasBeenKilled"
        case .spaceshipTimerBeforeRespawn:
            return "spaceshipTimerBeforeRespawn"
        case .spaceshipDidRespawn:
            return "spaceshipDidRespawn"
        }
    }
    
    var items: [SocketData] {
        switch self {
        case .spaceshipHasBeenKilled, .spaceshipTimerBeforeRespawn, .spaceshipDidRespawn:
            return []
        case .spaceshipDidConnect(playerId: let playerId):
            return [playerId]
        case .spaceshipDidDisconnect(playerId: let playerId):
            return [playerId]
        case let .spaceshipDidUpdatePosition(playerId: playerId, position: position, rotation: rotation):
            return [playerId, Int(position.x), Int(position.y), Double(rotation)]
        case .spaceshipDidFire(playerId: let playerId):
            return [playerId]
        case let .spaceshipHasBeenHit(playerId: playerId, damage: damage):
            return [playerId, Double(damage)]
        }
    }
        
}
