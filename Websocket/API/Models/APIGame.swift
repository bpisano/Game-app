//
//  APIGame.swift
//  Websocket
//
//  Created by Benjamin Pisano on 22/03/2020.
//  Copyright © 2020 Snopia. All rights reserved.
//

import Cocoa

struct APIGame: Codable {
    
    let id: String
    var players: Set<APIPlayer>
    var spaceships: Set<APISpaceship>

}
