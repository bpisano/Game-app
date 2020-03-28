//
//  JoinGameViewController.swift
//  Websocket
//
//  Created by Benjamin Pisano on 20/03/2020.
//  Copyright © 2020 Snopia. All rights reserved.
//

import Cocoa
import Combine
import Moya

final class JoinGameViewController: NSViewController {
    
    @IBOutlet private weak var usernameTextField: NSTextField!
    @IBOutlet private weak var gameIdTextField: NSTextField!
    @IBOutlet private weak var activityIndicator: NSProgressIndicator!
    @IBOutlet private weak var joinGameButton: NSButton!
    @IBOutlet private weak var cancelButton: NSButton!
    
    private var gameId: String = ""
    private var playerId: String!
    private var playerUsername: String = ""
    private var didJoinGame: ((_ gameSummary: APIGameSummary) -> Void)?
    
    @Published private var state: DataState = .noData
    private var cancellablePublishers: [AnyCancellable] = []

    class func controller(onJoinGame: @escaping (_ gameSummary: APIGameSummary) -> Void) -> JoinGameViewController {
        let controller: JoinGameViewController = NSStoryboard(name: NSStoryboard.Name("JoinGame"), bundle: nil).instantiateInitialController() as! JoinGameViewController
        controller.playerId = UUID().uuidString
        controller.didJoinGame = onJoinGame
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
        gameIdTextField.delegate = self
        usernameTextField.delegate = self
        
        updateState(state)
    }
    
    private func updateState(_ state: DataState) {
        switch state {
        case .data, .error:
            usernameTextField.isEnabled = true
            cancelButton.isEnabled = true
            joinGameButton.isEnabled = true
            joinGameButton.isHidden = false
            activityIndicator.isHidden = true
            activityIndicator.stopAnimation(self)
        case .noData:
            usernameTextField.isEnabled = true
            cancelButton.isEnabled = true
            joinGameButton.isEnabled = false
            joinGameButton.isHidden = false
            activityIndicator.isHidden = true
            activityIndicator.stopAnimation(self)
        case .loading:
            usernameTextField.isEnabled = false
            cancelButton.isEnabled = false
            joinGameButton.isEnabled = false
            joinGameButton.isHidden = true
            activityIndicator.isHidden = false
            activityIndicator.startAnimation(self)
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(self)
    }
    
    @IBAction func joinGame(_ sender: Any) {
        state = .loading
        
        let provider: MoyaProvider<WebService> = MoyaProvider()
        provider.request(.joinGame(id: gameId, playerId: playerId, playerUsername: playerUsername)) { [weak self] (result) in
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
            didJoinGame?(gameSummary)
            dismiss(self)
        } catch {
            print(error.localizedDescription)
            print(json)
        }
    }
    
}

extension JoinGameViewController: NSTextFieldDelegate {
    
    func controlTextDidChange(_ obj: Notification) {
        guard let textField = obj.object as? NSTextField else { return }
        
        if textField == usernameTextField {
            if textField.stringValue.count > 3 {
                playerUsername = textField.stringValue
            } else {
                playerUsername = ""
            }
        } else if textField == gameIdTextField {
            if textField.stringValue.count == 36 {
                gameId = textField.stringValue
            } else {
                gameId = ""
            }
        }
        
        if !playerUsername.isEmpty && !gameId.isEmpty {
            state = .data
        }
    }
    
}
