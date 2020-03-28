//
//  RespawnTimerNode.swift
//  Websocket
//
//  Created by Benjamin Pisano on 28/03/2020.
//  Copyright © 2020 Snopia. All rights reserved.
//

import Cocoa
import SpriteKit

final class RespawnTimerNode: SKSpriteNode {
    
    static let size: CGSize = CGSize(width: 200, height: 200)
    
    private var label: SKLabelNode!

    init(timer: Int) {
        super.init(texture: nil, color: .black, size: RespawnTimerNode.size)
        self.configureLabel(withTimer: timer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLabel(withTimer timer: Int) {
        self.label = SKLabelNode()
        self.label.fontSize = 19
        self.label.fontColor = .white
        self.label.text = "\(timer)"
        addChild(label)
    }
    
    func update(withTimer timer: Int) {
        label.text = "\(timer)"
    }
    
}
