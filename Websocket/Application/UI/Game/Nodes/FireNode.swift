//
//  FireNode.swift
//  Websocket
//
//  Created by Benjamin Pisano on 20/03/2020.
//  Copyright © 2020 Snopia. All rights reserved.
//

import SpriteKit

final class FireNode: SKSpriteNode {
    
    weak var spaceship: SpaceshipNode?

    init(spaceship: SpaceshipNode) {
        self.spaceship = spaceship
        super.init(texture: nil, color: .yellow, size: CGSize(width: 10, height: 30))
        self.name = "fire"
        self.position = spaceship.position
        self.zRotation = spaceship.zRotation
        self.physicsBody = Physics.Body.fire.physicBody(from: self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func move() {
        let referenceSpeed: TimeInterval = 0.2
        let referenceDistance: CGFloat = 1000
        let angle: CGFloat = zRotation + CGFloat.pi / 2
        let normalizedX: CGFloat = cos(angle) * referenceDistance
        let normalizedY: CGFloat = sin(angle) * referenceDistance
        let moveAction: SKAction = .moveBy(x: normalizedX, y: normalizedY, duration: referenceSpeed)
        let removeAction: SKAction = .removeFromParent()
        let sequence: SKAction = .sequence([moveAction, removeAction])
        run(sequence)
    }
    
}
