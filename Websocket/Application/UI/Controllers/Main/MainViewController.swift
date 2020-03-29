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
    
    @IBOutlet private weak var skView: SKView!
        
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
        let menuScene = MenuScene(onJoinGameTouch: { [weak self] in
            self?.showJoinGameController()
        }, onCreateGameTouch: { [weak self] in
            self?.showCreateGameController()
        })
        
        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsPhysics = true
        
        skView.presentScene(menuScene)
    }
    
    private func goToGameScene(gameSummary: APIGameSummary) {
        let gameManager: GameManager = GameManager(gameSummary: gameSummary)
        let gameScene: GameScene = GameScene(gameManager: gameManager)
        let transition: SKTransition = SKTransition.fade(with: .black, duration: 2)
        skView.presentScene(gameScene, transition: transition)
    }
    
    private func configureMouseEvents() {
        skView.window?.acceptsMouseMovedEvents = true
        skView.window?.makeFirstResponder(skView.scene)
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
