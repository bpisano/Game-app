//
//  BackgroundNode.swift
//  Websocket
//
//  Created by Benjamin Pisano on 20/03/2020.
//  Copyright © 2020 Snopia. All rights reserved.
//

import SpriteKit

final class BackgroundNode: SKSpriteNode {
    
    static let size: CGSize = CGSize(width: 400, height: 400)

    init() {
        super.init(texture: SKTexture(imageNamed: "SpaceBackground"), color: .clear, size: CGSize(width: 400, height: 400))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
