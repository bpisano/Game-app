//
//  MenuScene.swift
//  Websocket
//
//  Created by Benjamin Pisano on 18/03/2020.
//  Copyright © 2020 Snopia. All rights reserved.
//

import SpriteKit

final class MenuScene: SKScene {
    
    private var didTouchJoinGame: () -> Void
    private var didTouchCreateGame: () -> Void
    
    init(onJoinGameTouch: @escaping () -> Void, onCreateGameTouch: @escaping () -> Void) {
        self.didTouchJoinGame = onJoinGameTouch
        self.didTouchCreateGame = onCreateGameTouch
        super.init(size: CGSize(width: 1000, height: 1000 * 16 / 9))
        self.configureUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        scaleMode = .resizeFill
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        isUserInteractionEnabled = true
        
        addButtons()
    }
    
    private func addButtons() {
        let buttonSize: CGSize = CGSize(width: 200, height: 80)
        
        let joinGameButton: ButtonNode = ButtonNode(title: "Join Game", color: .red, size: buttonSize)
        joinGameButton.position = CGPoint(x: 0, y: 50)
        joinGameButton.onTouchUpInside { [weak self] in
            self?.didTouchJoinGame()
        }
        
        let createGameButton: ButtonNode = ButtonNode(title: "Create Game", color: .red, size: buttonSize)
        createGameButton.position = CGPoint(x: 0, y: -50)
        createGameButton.onTouchUpInside { [weak self] in
            self?.didTouchCreateGame()
        }
        
        addChild(joinGameButton)
        addChild(createGameButton)
    }
    
    func goToGameScene(gameSummary: APIGameSummary) {
        let gameManager: GameManager = GameManager(gameSummary: gameSummary)
        let gameScene: GameScene = GameScene(gameManager: gameManager)
        let transition: SKTransition = SKTransition.fade(with: .black, duration: 2)
        view?.presentScene(gameScene, transition: transition)
    }
    
}
