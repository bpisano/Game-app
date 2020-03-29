//
//  GameManagerDelegate.swift
//  Websocket
//
//  Created by Benjamin Pisano on 28/03/2020.
//  Copyright © 2020 Snopia. All rights reserved.
//

import Cocoa

protocol GameManagerDelegate: class {
    
    func spaceshipDidConnect(apiSpaceship: APISpaceship, gameManager: GameManager)
    func spaceshipDidDisconnect(apiSpaceship: APISpaceship, gameManager: GameManager)
    func spaceshipDidUpdatePosition(apiSpaceship: APISpaceship, gameManager: GameManager)
    func spaceshipDidFire(apiSpaceship: APISpaceship, gameManager: GameManager)
    func spaceshipHasBeenHit(apiSpaceship: APISpaceship, gameManager: GameManager)
    func spaceshipHasBeenKilled(apiSpaceship: APISpaceship, gameManager: GameManager)
    func spaceshipTimerBeforeRespawn(apiSpaceship: APISpaceship, timer: Int, gameManager: GameManager)
    func spaceshipDidRespawn(apiSpaceship: APISpaceship, gameManager: GameManager)
    
}
