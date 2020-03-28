//
//  CreateGameViewController.swift
//  Websocket
//
//  Created by Benjamin Pisano on 18/03/2020.
//  Copyright © 2020 Snopia. All rights reserved.
//

import Cocoa
import Combine
import Moya

final class CreateGameViewController: NSViewController {
    
    @IBOutlet private weak var usernameTextField: NSTextField!
    @IBOutlet private weak var gameIdTextField: NSTextField!
    @IBOutlet private weak var activityIndicator: NSProgressIndicator!
    @IBOutlet private weak var createGameButton: NSButton!
    @IBOutlet private weak var cancelButton: NSButton!
    
    private var gameId: String!
    private var playerId: String!
    private var playerUsername: String!
    private var didCreateGame: ((_ gameSummary: APIGameSummary) -> Void)?
    
    @Published private var state: DataState = .noData
    private var cancellablePublishers: [AnyCancellable] = []
    
    class func controller(onCreateGame: @escaping (_ gameSummary: APIGameSummary) -> Void) -> CreateGameViewController {
        let controller: CreateGameViewController = NSStoryboard(name: NSStoryboard.Name("CreateGame"), bundle: nil).instantiateInitialController() as! CreateGameViewController
        controller.gameId = UUID().uuidString
        controller.playerId = UUID().uuidString
        controller.didCreateGame = onCreateGame
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        observeFieldValidation()
    }
    
    // MARK: - Field Validation
    
    private func observeFieldValidation() {
        $state
            .receive(on: DispatchQueue.main)
            .sink { (receivedState) in
                self.updateState(receivedState)
            }
            .store(in: &cancellablePublishers)
    }
    
    private func configureUI() {
        gameIdTextField.stringValue = gameId
        gameIdTextField.isSelectable = true
        usernameTextField.delegate = self
        
        updateState(state)
    }
    
    private func updateState(_ state: DataState) {
        switch state {
        case .data, .error:
            usernameTextField.isEnabled = true
            cancelButton.isEnabled = true
            createGameButton.isEnabled = true
            createGameButton.isHidden = false
            activityIndicator.isHidden = true
            activityIndicator.stopAnimation(self)
        case .noData:
            usernameTextField.isEnabled = true
            cancelButton.isEnabled = true
            createGameButton.isEnabled = false
            createGameButton.isHidden = false
            activityIndicator.isHidden = true
            activityIndicator.stopAnimation(self)
        case .loading:
            usernameTextField.isEnabled = false
            cancelButton.isEnabled = false
            createGameButton.isEnabled = false
            createGameButton.isHidden = true
            activityIndicator.isHidden = false
            activityIndicator.startAnimation(self)
        }
    }
    
    // MARK: - Action
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(self)
    }
    
    @IBAction func createGame(_ sender: Any) {
        state = .loading
        
        let provider: MoyaProvider<WebService> = MoyaProvider()
        provider.request(.createGame(id: gameId, playerId: playerId, playerUsername: playerUsername)) { [weak self] (result) in
            switch result {
            case .success(let response):
                self?.handleResponse(response)
            case .failure(let error):
                self?.state = .error(error)
                print(error.localizedDescription)
            }
        }
    }
    
    private func handleResponse(_ response: Response) {
        guard let json = try? response.mapJSON() else { return }
        
        do {
            let gameSummary = try JSONDecoder().decode(APIGameSummary.self, from: response.data)
            didCreateGame?(gameSummary)
            dismiss(self)
        } catch {
            print(error.localizedDescription)
            print(json)
        }
    }
    
}

extension CreateGameViewController: NSTextFieldDelegate {
    
    func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else { return }
        
        guard textField.stringValue.count > 3 else {
            playerUsername = ""
            state = .noData
            return
        }
        
        playerUsername = textField.stringValue
        state = .data
    }
    
}
