//
//  APISpaceship.swift
//  Websocket
//
//  Created by Benjamin Pisano on 22/03/2020.
//  Copyright © 2020 Snopia. All rights reserved.
//

import Cocoa

class APISpaceship: Codable, Hashable {

    weak var player: APIPlayer?
    var health: CGFloat
    var position: CGPoint
    var rotation: CGFloat
    
    static func == (lhs: APISpaceship, rhs: APISpaceship) -> Bool {
        return lhs.player?.id == rhs.player?.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(player?.id)
    }
    
    static func fromJsonString(_ jsonString: String) -> APISpaceship? {
        do {
            let jsonObject: Any = try JSONSerialization.jsonObject(with: Data(jsonString.utf8), options: [])
            let jsonData: Data = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
            let apiSpaceship: APISpaceship = try JSONDecoder().decode(APISpaceship.self, from: jsonData)
            return apiSpaceship
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
}
