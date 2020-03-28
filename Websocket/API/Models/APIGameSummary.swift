//
//  APIGameSummary.swift
//  Websocket
//
//  Created by Benjamin Pisano on 19/03/2020.
//  Copyright © 2020 Snopia. All rights reserved.
//

import Cocoa

struct APIGameSummary: Codable {
    
    var game: APIGame
    let currentPlayer: APIPlayer
    
}
