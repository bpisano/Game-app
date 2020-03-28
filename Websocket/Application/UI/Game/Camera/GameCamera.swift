//
//  GameCamera.swift
//  Websocket
//
//  Created by Benjamin Pisano on 20/03/2020.
//  Copyright © 2020 Snopia. All rights reserved.
//

import SpriteKit

final class GameCamera: SKCameraNode {
    
    static private let initialScale: CGFloat = 2
        
    var nodeToFollow: SKSpriteNode?
    var alertNode: SKSpriteNode? {
        willSet {
            guard let alertNode = alertNode else { return }
            alertNode.removeFromParent()
        }
        didSet {
            guard let alertNode = alertNode else { return }
            addChild(alertNode)
        }
    }

    init(scene: SKScene) {
        super.init()
        self.addToScene(scene)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
        
    private func addToScene(_ scene: SKScene) {
        scene.camera = self
    }
    
    func update() {
        follow(node: nodeToFollow)
        scale(node: nodeToFollow)
    }
        
    private func follow(node nodeToFollow: SKSpriteNode?) {
        guard let nodeToFollow = nodeToFollow else {
            position = .zero
            return
        }
        
        position = nodeToFollow.position
    }
    
    private func scale(node nodeToFollow: SKSpriteNode?) {
        guard let physicBody = nodeToFollow?.physicsBody else {
            xScale = GameCamera.initialScale
            yScale = GameCamera.initialScale
            return
        }
        
        let velocity: CGFloat = sqrt(pow(physicBody.velocity.dx, 2) + pow(physicBody.velocity.dy, 2))
        let scale = GameCamera.initialScale + velocity / 1000
        xScale = scale
        yScale = scale
    }
    
}
