//
//  ButtonNode.swift
//  Websocket
//
//  Created by Benjamin Pisano on 18/03/2020.
//  Copyright © 2020 Snopia. All rights reserved.
//

import SpriteKit

final class ButtonNode: SKSpriteNode {
    
    private var canSendTouchEvent: Bool = true
    private var title: String
    private var didTouchUpInside: (() -> Void)?

    init(title: String, color: SKColor, size: CGSize) {
        self.title = title
        super.init(texture: nil, color: color, size: size)
        self.configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        isUserInteractionEnabled = true
        addLabel()
    }
    
    private func addLabel() {
        let label: SKLabelNode = SKLabelNode(text: title)
        let xPosition: CGFloat = -label.frame.midX
        let yPositition: CGFloat = -label.frame.midY
        label.position = CGPoint(x: xPosition, y: yPositition)
        addChild(label)
    }
    
    // MARK: - Touch and mouse
    
    override func touchesBegan(with event: NSEvent) {
        super.touchesBegan(with: event)
        setSelected()
        canSendTouchEvent = true
    }
    
    override func touchesCancelled(with event: NSEvent) {
        super.touchesCancelled(with: event)
        setDeselected()
        canSendTouchEvent = false
    }
    
    override func touchesEnded(with event: NSEvent) {
        super.touchesEnded(with: event)
        setDeselected()
        if canSendTouchEvent {
            didTouchUpInside?()
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
        setSelected()
        canSendTouchEvent = true
    }
    
    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        setDeselected()
        if canSendTouchEvent {
            didTouchUpInside?()
        }
    }
    
    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)
        setSelected()
        canSendTouchEvent = true
    }
    
    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)
        setDeselected()
        canSendTouchEvent = false
    }
    
    func onTouchUpInside(_ completion: @escaping () -> Void) {
        didTouchUpInside = completion
    }
    
    // MARK: - Appearances
    
    private func setSelected() {
        alpha = 0.6
    }
    
    private func setDeselected() {
        alpha = 1
    }
    
}
