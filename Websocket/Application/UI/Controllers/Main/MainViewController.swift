//
//  MainViewController.swift
//  Websocket
//
//  Created by Benjamin Pisano on 18/03/2020.
//  Copyright © 2020 Snopia. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit
import SocketIO

final class MainViewController: NSViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        presentMenuScene()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        
        view.window?.delegate = self
        
        configureMouseEvents()
    }
    
    private func presentMenuScene() {
        guard let view = view as? SKView else { fatalError() }
        
        let menuScene = MenuScene(onJoinGameTouch: { [weak self] in
            self?.showJoinGameController()
        }, onCreateGameTouch: { [weak self] in
            self?.showCreateGameController()
        })
        
        view.ignoresSiblingOrder = true
        view.showsFPS = true
        view.showsNodeCount = true
        view.showsPhysics = true
        
        view.presentScene(menuScene)
    }
    
    private func goToGameScene(gameSummary: APIGameSummary) {
        guard let view = view as? SKView else { return }
        let gameManager: GameManager = GameManager(gameSummary: gameSummary)
        let gameScene: GameScene = GameScene(gameManager: gameManager)
        let transition: SKTransition = SKTransition.fade(with: .black, duration: 2)
        view.presentScene(gameScene, transition: transition)
    }
    
    private func configureMouseEvents() {
        guard let view = view as? SKView else { fatalError() }
        
        view.window?.acceptsMouseMovedEvents = true
        view.window?.makeFirstResponder(view.scene)
    }
        
    private func showCreateGameController() {
        let controller: CreateGameViewController = CreateGameViewController.controller(onDismiss: { [weak self] controller in
            self?.dismiss(controller)
        }, onCreateGame: { [weak self] (gameSummary) in
            self?.goToGameScene(gameSummary: gameSummary)
        })
        presentAsSheet(controller)
    }
    
    private func showJoinGameController() {
        let controller: JoinGameViewController = JoinGameViewController.controller(onDismiss: { [weak self] controller in
            self?.dismiss(controller)
        }, onJoinGame: { [weak self] (gameSummary) in
            self?.goToGameScene(gameSummary: gameSummary)
        })
        presentAsSheet(controller)
    }
    
}

extension MainViewController: NSWindowDelegate {
    
    func windowWillClose(_ notification: Notification) {
        guard let gameScene = (view as? SKView)?.scene as? GameScene else { return }
        gameScene.windowWillClose()
    }
    
}
