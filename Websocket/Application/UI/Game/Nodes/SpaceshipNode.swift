//
//  SpaceshipNode.swift
//  Websocket
//
//  Created by Benjamin Pisano on 20/03/2020.
//  Copyright © 2020 Snopia. All rights reserved.
//

import SpriteKit

final class SpaceshipNode: SKSpriteNode {
    
    weak var apiSpaceship: APISpaceship?
    
    init(apiSpaceship: APISpaceship) {
        self.apiSpaceship = apiSpaceship
        super.init(texture: SKTexture(imageNamed: "SpaceshipBlue"), color: .clear, size: CGSize(width: 100, height: 90))
        self.configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        guard let apiSpaceship = apiSpaceship else { return }
        name = "spaceship"
        position = apiSpaceship.position
        physicsBody = Physics.Body.spaceship.physicBody(from: self)
    }
    
    func update(withMousePosition mousePosition: CGPoint) {
        move(mousePosition: mousePosition)
    }
    
    func rotate(mousePosition: CGPoint) {
        let rotationAngle: CGFloat = atan2(mousePosition.y, mousePosition.x) - CGFloat.pi / 2
        let rotateAction: SKAction = SKAction.rotate(toAngle: rotationAngle, duration: 0)
        run(rotateAction)
    }
    
    private func move(mousePosition: CGPoint) {
        let forceVector: CGVector = CGVector(dx: mousePosition.x, dy: mousePosition.y)
        physicsBody?.applyForce(forceVector)
    }
    
}

// MARK: - Public Methods

extension SpaceshipNode {
    
    func fire(in scene: SKScene) {
        let fireNode: FireNode = FireNode(spaceship: self)
        scene.addChild(fireNode)
        fireNode.move()
    }
    
    func hit() {
        let normalTexture: SKTexture = SKTexture(imageNamed: "SpaceshipBlue")
        let hitTexture: SKTexture = SKTexture(imageNamed: "SpaceshipBlueHit")
        let setHitTexture: SKAction = .setTexture(hitTexture)
        let wait: SKAction = .wait(forDuration: 0.05)
        let setCurrentTexture: SKAction = .setTexture(normalTexture)
        let sequence: SKAction = .sequence([setHitTexture, wait, setCurrentTexture])
        run(sequence)
    }
    
    func kill(_ completion: () -> Void) {
        removeFromParent()
        completion()
    }
    
}
