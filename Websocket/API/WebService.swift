//
//  WebService.swift
//  Websocket
//
//  Created by Benjamin Pisano on 19/03/2020.
//  Copyright © 2020 Snopia. All rights reserved.
//

import Cocoa
import Moya

enum WebService {
    
    case createGame(id: String, playerId: String, playerUsername: String)
    case joinGame(id: String, playerId: String, playerUsername: String)
    
}

extension WebService: TargetType {
    
    var baseURL: URL {
//        URL(string: "http://52.51.230.84")!
        URL(string: "http://localhost:3000")!
    }
    
    var path: String {
        switch self {
        case .createGame:
            return "/create_game"
        case .joinGame:
            return "/join_game"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .createGame, .joinGame:
            return .post
        }
    }
    
    var sampleData: Data {
        Data()
    }
    
    var task: Task {
        switch self {
        case let .createGame(id: id, playerId: playerId, playerUsername: playerUsername):
            let parameters: [String: Any] = ["gameId": id,
                                             "playerId": playerId,
                                             "playerUsername": playerUsername]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        case let .joinGame(id: id, playerId: playerId, playerUsername: playerUsername):
            let parameters: [String: Any] = ["gameId": id,
                                             "playerId": playerId,
                                             "playerUsername": playerUsername]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }
        
    var headers: [String : String]? {
        nil
    }
    
}
