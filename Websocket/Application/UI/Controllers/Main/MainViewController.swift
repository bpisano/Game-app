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

class MainViewController: NSViewController {

    @IBOutlet private weak var skView: SKView!
    
    private var menuScene: MenuScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presentMenuScene()
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        configureMouseEvents()
    }
    
    private func presentMenuScene() {
        guard let view = view as? SKView else { fatalError() }
        
        menuScene = MenuScene(onJoinGameTouch: { [weak self] in
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
    
    private func configureMouseEvents() {
        guard let view = view as? SKView else { fatalError() }
        
        view.window?.acceptsMouseMovedEvents = true
        view.window?.makeFirstResponder(view.scene)
    }
        
    private func showCreateGameController() {
        let controller: CreateGameViewController = CreateGameViewController.controller { [weak self] (gameSummary) in
            self?.menuScene.goToGameScene(gameSummary: gameSummary)
        }
        presentAsSheet(controller)
    }
    
    private func showJoinGameController() {
        let controller: JoinGameViewController = JoinGameViewController.controller { [weak self] (gameSummary) in
            self?.menuScene.goToGameScene(gameSummary: gameSummary)
        }
        presentAsSheet(controller)
    }
    
}
