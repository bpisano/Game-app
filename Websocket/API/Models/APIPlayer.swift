//
//  APIPlayer.swift
//  Websocket
//
//  Created by Benjamin Pisano on 19/03/2020.
//  Copyright © 2020 Snopia. All rights reserved.
//

import Cocoa

class APIPlayer: Codable, Hashable {
    
    let id: String
    let username: String
    
    static func == (lhs: APIPlayer, rhs: APIPlayer) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func fromJsonString(_ jsonString: String) -> APIPlayer? {
        do {
            let jsonObject: Any = try JSONSerialization.jsonObject(with: Data(jsonString.utf8), options: [])
            let jsonData: Data = try JSONSerialization.data(withJSONObject: jsonObject, options: [])
            let apiPlayer: APIPlayer = try JSONDecoder().decode(APIPlayer.self, from: jsonData)
            return apiPlayer
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
}
