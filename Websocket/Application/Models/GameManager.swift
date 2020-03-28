//
//  GameManager.swift
//  Websocket
//
//  Created by Benjamin Pisano on 19/03/2020.
//  Copyright © 2020 Snopia. All rights reserved.
//

import Cocoa
import SpriteKit
import SocketIO

final class GameManager {
        
    private let socketManager: GameSocketManger<GameSocketTarget>
    
    var gameSummary: APIGameSummary
    var delegate: GameManagerDelegate?
    
    init(gameSummary: APIGameSummary) {
        self.gameSummary = gameSummary
        self.socketManager = GameSocketManger(url: URL(string: "http://localhost:3000")!, room: gameSummary.game.id)
    }
    
    func launchGame() {
        configureSpaceships()
        configureSockets()
    }
    
    private func configureSpaceships() {
        gameSummary.game.spaceships.forEach { (apiSpaceship) in
            self.delegate?.spaceshipDidConnect(apiSpaceship: apiSpaceship, gameManager: self)
        }
    }
    
    private func configureSockets() {
        socketManager.connect()
        
        socketManager.on(event: .spaceshipDidConnect(playerId: "")) { [weak self] (data) in
            guard let newPlayerString = data[0] as? String, let newSpaceshipString = data[1] as? String else { return }
            guard let newPlayer = APIPlayer.fromJsonString(newPlayerString), let newSpaceship = APISpaceship.fromJsonString(newSpaceshipString) else { return }
            
            if newPlayer.id != self?.gameSummary.currentPlayer.id {
                self?.gameSummary.game.players.insert(newPlayer)
                self?.gameSummary.game.spaceships.insert(newSpaceship)
            }
            
            self?.handleSpaceshipDidConnect(newPlayer: newPlayer, newSpaceship: newSpaceship)
        }
        
        socketManager.on(event: .spaceshipDidDisconnect(playerId: "")) { [weak self] (data) in
            guard let fetchedPlayerId = data[0] as? String else { return }
            guard let apiSpaceship = self?.gameSummary.game.spaceships.first(where: { $0.player.id == fetchedPlayerId }) else { return }
            self?.handleSpaceshipDidDisconnect(apiSpaceship: apiSpaceship)
        }
        
        socketManager.on(event: .spaceshipDidUpdatePosition(playerId: "", position: .zero, rotation: 0)) { [weak self] (data) in
            guard let fetchedPlayerId = data[0] as? String, let xPosition = data[1] as? Double, let yPosition = data[2] as? Double, let fetchedRotation = data[3] as? Double else { return }
            guard let apiSpaceship = self?.gameSummary.game.spaceships.first(where: { $0.player.id == fetchedPlayerId }) else { return }
            self?.handleSpaceshipDidUpdatePosition(apiSpaceship: apiSpaceship, position: CGPoint(x: xPosition, y: yPosition), rotation: CGFloat(fetchedRotation))
        }
        
        socketManager.on(event: .spaceshipDidFire(playerId: "")) { [weak self] (data) in
            guard let fetchedPlayerId = data[0] as? String else { return }
            guard let apiSpaceship = self?.gameSummary.game.spaceships.first(where: { $0.player.id == fetchedPlayerId }) else { return }
            self?.handleSpaceshipDidFire(apiSpaceship: apiSpaceship)
        }
        
        socketManager.on(event: .spaceshipHasBeenHit(playerId: "", damage: 0)) { [weak self] (data) in
            guard let fetchedPlayerId = data[0] as? String, let damage = data[1] as? Int else { return }
            guard let apiSpaceship = self?.gameSummary.game.spaceships.first(where: { $0.player.id == fetchedPlayerId }) else { return }
            self?.handleSpaceshipBeingHit(apiSpaceship: apiSpaceship, damage: damage)
        }
        
        socketManager.on(event: .spaceshipHasBeenKilled) { [weak self] (data) in
            guard let fetchedPlayerId = data[0] as? String else { return }
            guard let apiSpaceship = self?.gameSummary.game.spaceships.first(where: { $0.player.id == fetchedPlayerId }) else { return }
            self?.handleSpaceshipHasBeenKilled(apiSpaceship: apiSpaceship)
        }
        
        socketManager.on(event: .spaceshipTimerBeforeRespawn) { [weak self] (data) in
            guard let fetchedPlayerId = data[0] as? String, let timer = data[1] as? Int else { return }
            guard let apiSpaceship = self?.gameSummary.game.spaceships.first(where: { $0.player.id == fetchedPlayerId }) else { return }
            self?.handleSpaceshipTimerBeforeRespawn(apiSpaceship: apiSpaceship, timer: timer)
        }
        
        socketManager.on(event: .spaceshipDidRespawn) { [weak self] (data) in
            guard let fetchedPlayerId = data[0] as? String, let xPosition = data[1] as? Double, let yPosition = data[2] as? Double, let health = data[3] as? Double else { return }
            guard let apiSpaceship = self?.gameSummary.game.spaceships.first(where: { $0.player.id == fetchedPlayerId }) else { return }
            self?.handleSpaceshipDidRespawn(apiSpaceship: apiSpaceship, position: CGPoint(x: xPosition, y: yPosition), health: CGFloat(health))
        }
    }
        
}

// MARK: - Event Handler

extension GameManager {
    
    private func handleSpaceshipDidConnect(newPlayer: APIPlayer, newSpaceship: APISpaceship) {
        gameSummary.game.players.insert(newPlayer)
        delegate?.spaceshipDidConnect(apiSpaceship: newSpaceship, gameManager: self)
    }
    
    private func handleSpaceshipDidDisconnect(apiSpaceship: APISpaceship) {
        delegate?.spaceshipDidDisconnect(apiSpaceship: apiSpaceship, gameManager: self)
        gameSummary.game.spaceships.remove(apiSpaceship)
        gameSummary.game.players.remove(apiSpaceship.player)
    }
    
    private func handleSpaceshipDidUpdatePosition(apiSpaceship: APISpaceship, position: CGPoint, rotation: CGFloat) {
        apiSpaceship.position = position
        apiSpaceship.rotation = rotation
        
        if apiSpaceship.player.id != gameSummary.currentPlayer.id {
            delegate?.spaceshipDidUpdatePosition(apiSpaceship: apiSpaceship, gameManager: self)
        }
    }
    
    private func handleSpaceshipDidFire(apiSpaceship: APISpaceship) {
        delegate?.spaceshipDidFire(apiSpaceship: apiSpaceship, gameManager: self)
    }
    
    private func handleSpaceshipBeingHit(apiSpaceship: APISpaceship, damage: Int) {
        apiSpaceship.health -= 10
        delegate?.spaceshipHasBeenHit(apiSpaceship: apiSpaceship, gameManager: self)
    }
    
    private func handleSpaceshipHasBeenKilled(apiSpaceship: APISpaceship) {
        delegate?.spaceshipHasBeenKilled(apiSpaceship: apiSpaceship, gameManager: self)
    }
    
    private func handleSpaceshipTimerBeforeRespawn(apiSpaceship: APISpaceship, timer: Int) {
        guard apiSpaceship.player.id == gameSummary.currentPlayer.id else { return }
        delegate?.spaceshipTimerBeforeRespawn(apiSpaceship: apiSpaceship, timer: timer, gameManager: self)
    }
    
    private func handleSpaceshipDidRespawn(apiSpaceship: APISpaceship, position: CGPoint, health: CGFloat) {
        apiSpaceship.position = position
        apiSpaceship.health = health
        delegate?.spaceshipDidRespawn(apiSpaceship: apiSpaceship, gameManager: self)
    }
    
}

// MARK: - Public Methods

extension GameManager {
    
    func currentPlayerDidUpdateSpaceshipPosition(position: CGPoint, rotation: CGFloat) {
        socketManager.emit(event: .spaceshipDidUpdatePosition(playerId: gameSummary.currentPlayer.id, position: position, rotation: rotation))
    }
    
    func currentPlayerDidFire() {
        socketManager.emit(event: .spaceshipDidFire(playerId: gameSummary.currentPlayer.id))
    }
    
    func currentPlayerDidHit(playerId: String, damage: CGFloat) {
        socketManager.emit(event: .spaceshipHasBeenHit(playerId: playerId, damage: damage))
    }
        
}
