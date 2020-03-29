//
//  GameScene.swift
//  Websocket
//
//  Created by Benjamin Pisano on 18/03/2020.
//  Copyright © 2020 Snopia. All rights reserved.
//

import SpriteKit
import SocketIO

final class GameScene: SKScene {
    
    static let size: CGSize = CGSize(width: 1200, height: 1200)
    
    private var gameManager: GameManager?
    private var gameCamera: GameCamera?
    private var mousePosition: CGPoint = .zero
    private var spaceships: Set<SpaceshipNode> = []
    private var currentPlayerSpaceship: SpaceshipNode? {
        return spaceships.first(where: { $0.apiSpaceship?.player.id == gameManager?.gameSummary?.currentPlayer?.id })
    }
    private var canControlSpaceship: Bool = true
        
    init(gameManager: GameManager) {
        self.gameManager = gameManager
        super.init(size: GameScene.size)
        self.configureUI()
        self.configureGameManager()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureGameManager() {
        gameManager?.delegate = self
        gameManager?.launchGame()
    }
    
    private func configureUI() {
        scaleMode = .resizeFill
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        isUserInteractionEnabled = true
        
        physicsWorld.contactDelegate = self
                        
        addBackground()
        configureCamera()
    }
    
    private func configureCamera() {
        gameCamera = GameCamera(scene: self)
    }
        
    private func addBackground() {
        let backgroundNode: SKSpriteNode = SKSpriteNode(texture: SKTexture(imageNamed: "SpaceBackground"), color: .clear, size: GameScene.size)
        backgroundNode.zPosition = -1000
        addChild(backgroundNode)
//        let xStart: CGFloat = -size.width / 2 - BackgroundNode.size.width / 2
//        let yStart: CGFloat = -size.height / 2 - BackgroundNode.size.height / 2
//        var x: CGFloat = xStart
//        var y: CGFloat = yStart
//
//        while y < size.height {
//            while x < size.width {
//                let backgroundNode: BackgroundNode = BackgroundNode()
//                backgroundNode.position = CGPoint(x: x, y: y)
//                addChild(backgroundNode)
//
//                x += BackgroundNode.size.width
//            }
//
//            y += BackgroundNode.size.height
//        }
    }
    
    private func addNewSpaceshipNode(fromApiSpaceship apiSpaceship: APISpaceship) {
        guard spaceships.first(where: { $0.apiSpaceship?.player.id == apiSpaceship.player.id }) == nil else { return }
        let newSpaceship: SpaceshipNode = SpaceshipNode(apiSpaceship: apiSpaceship)
        spaceships.insert(newSpaceship)
        addChild(newSpaceship)
    }
    
}

// MARK: - Public Methods

extension GameScene {
    
    func windowWillClose() {
        spaceships.forEach { (spaceship) in
            spaceship.removeFromParent()
            spaceships.remove(spaceship)
        }
        
        gameCamera?.removeFromParent()
        gameCamera = nil
        camera = nil
        
        gameManager?.stopGame()
        gameManager = nil
    }
    
}


// MARK: - GameManager event handler
extension GameScene {
    
    private func handleSpaceshipDidConnect(apiSpaceship: APISpaceship) {
        let newSpaceship: SpaceshipNode = SpaceshipNode(apiSpaceship: apiSpaceship)
        spaceships.insert(newSpaceship)
        addChild(newSpaceship)
        
        if apiSpaceship.player.id == gameManager?.gameSummary?.currentPlayer?.id {
            gameCamera?.nodeToFollow = newSpaceship
        }
    }
    
    private func handleSpaceshipDidUpdatePosition(apiSpaceship: APISpaceship) {
        guard let playerSpaceship = spaceships.first(where: { $0.apiSpaceship?.player.id == apiSpaceship.player.id }) else { return }
        playerSpaceship.position = apiSpaceship.position
        playerSpaceship.zRotation = apiSpaceship.rotation
    }
    
    private func handleSpaceshipDidFire(apiSpaceship: APISpaceship) {
        guard let playerSpaceship = spaceships.first(where: { $0.apiSpaceship?.player.id == apiSpaceship.player.id }) else { return }
        playerSpaceship.fire(in: self)
    }
    
    private func handleSpaceshipBeingHit(apiSpaceship: APISpaceship) {
        guard let playerSpaceship = spaceships.first(where: { $0.apiSpaceship?.player.id == apiSpaceship.player.id }) else { return }
        playerSpaceship.hit()
    }
    
}

// MARK: - Controls
extension GameScene {
        
    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)
        
        guard canControlSpaceship else { return }
        
        if let view = view {
            let mousePositionInWndow: CGPoint = event.locationInWindow
            mousePosition = CGPoint(x: mousePositionInWndow.x - view.frame.width / 2,
                                    y: mousePositionInWndow.y - view.frame.height / 2)
            currentPlayerSpaceship?.rotate(mousePosition: mousePosition)
        }
    }
    
    override func keyDown(with event: NSEvent) {
        if event.charactersIgnoringModifiers == " " {
            gameManager?.currentPlayerDidFire()
        } else if event.charactersIgnoringModifiers == "q" {
            currentPlayerSpaceship?.position = .zero
            currentPlayerSpaceship?.physicsBody?.velocity = .zero
        } else {
            if canControlSpaceship {
                canControlSpaceship = false
                currentPlayerSpaceship?.physicsBody?.velocity = .zero
            } else {
                canControlSpaceship = true
            }
        }
    }
    
}

// MARK: - Lifecycle
extension GameScene {
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        if canControlSpaceship {
            currentPlayerSpaceship?.update(withMousePosition: mousePosition)
        }
        
        if let currentPlayerSpaceship = currentPlayerSpaceship {
            gameManager?.currentPlayerDidUpdateSpaceshipPosition(position: currentPlayerSpaceship.position, rotation: currentPlayerSpaceship.zRotation)
        }
        
        gameCamera?.update()
    }
    
}

// MARK: - Contact

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        handleFireContact(contact)
    }
    
    private func handleFireContact(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node, let nodeB = contact.bodyB.node else { return }
        guard nodeA.name == "fire" || nodeB.name == "fire" else { return }
        
        let fireNode: FireNode = nodeA.name == "fire" ? nodeA as! FireNode : nodeB as! FireNode
        let spaceship: SpaceshipNode = nodeA.name == "fire" ? nodeB as! SpaceshipNode : nodeA as! SpaceshipNode
        
        if fireNode.spaceship?.apiSpaceship?.player.id != spaceship.apiSpaceship?.player.id {
            fireNode.removeFromParent()
            
            if let playerId = spaceship.apiSpaceship?.player.id, playerId != gameManager?.gameSummary?.currentPlayer?.id {
                gameManager?.currentPlayerDidHit(playerId: playerId, damage: 10)
            }
        }
    }
    
}

// MARK: - Game Manager Delegate

extension GameScene: GameManagerDelegate {
    
    func spaceshipDidConnect(apiSpaceship: APISpaceship, gameManager: GameManager) {
        addNewSpaceshipNode(fromApiSpaceship: apiSpaceship)
        if apiSpaceship.player.id == gameManager.gameSummary?.currentPlayer?.id {
            gameCamera?.nodeToFollow = currentPlayerSpaceship
        }
    }
    
    func spaceshipDidDisconnect(apiSpaceship: APISpaceship, gameManager: GameManager) {
        guard let playerSpaceship = spaceships.first(where: { $0.apiSpaceship?.player.id == apiSpaceship.player.id }) else { return }
        playerSpaceship.removeFromParent()
        spaceships.remove(playerSpaceship)
    }
    
    func spaceshipDidUpdatePosition(apiSpaceship: APISpaceship, gameManager: GameManager) {
        guard let playerSpaceship = spaceships.first(where: { $0.apiSpaceship?.player.id == apiSpaceship.player.id }) else { return }
        playerSpaceship.position = apiSpaceship.position
        playerSpaceship.zRotation = apiSpaceship.rotation
    }
    
    func spaceshipDidFire(apiSpaceship: APISpaceship, gameManager: GameManager) {
        guard let playerSpaceship = spaceships.first(where: { $0.apiSpaceship?.player.id == apiSpaceship.player.id }) else { return }
        playerSpaceship.fire(in: self)
    }
    
    func spaceshipHasBeenHit(apiSpaceship: APISpaceship, gameManager: GameManager) {
        guard let playerSpaceship = spaceships.first(where: { $0.apiSpaceship?.player.id == apiSpaceship.player.id }) else { return }
        playerSpaceship.hit()
    }
    
    func spaceshipHasBeenKilled(apiSpaceship: APISpaceship, gameManager: GameManager) {
        guard let playerSpaceship = spaceships.first(where: { $0.apiSpaceship?.player.id == apiSpaceship.player.id }) else { return }
        
        playerSpaceship.kill { [weak self] in
            self?.spaceships.remove(playerSpaceship)
        }
        
        if apiSpaceship.player.id == gameManager.gameSummary?.currentPlayer?.id {
            gameCamera?.nodeToFollow = nil
        }
    }
    
    func spaceshipTimerBeforeRespawn(apiSpaceship: APISpaceship, timer: Int, gameManager: GameManager) {
        if let timerNode = gameCamera?.alertNode as? RespawnTimerNode {
            timerNode.update(withTimer: timer)
        } else if gameCamera?.alertNode == nil {
            let timerNode: RespawnTimerNode = RespawnTimerNode(timer: timer)
            gameCamera?.alertNode = timerNode
        }
    }
    
    func spaceshipDidRespawn(apiSpaceship: APISpaceship, gameManager: GameManager) {
        addNewSpaceshipNode(fromApiSpaceship: apiSpaceship)
        
        if apiSpaceship.player.id == gameManager.gameSummary?.currentPlayer?.id {
            gameCamera?.nodeToFollow = currentPlayerSpaceship
        }
        
        if apiSpaceship.player.id == gameManager.gameSummary?.currentPlayer?.id {
            gameCamera?.alertNode = nil
        }
    }
    
}
