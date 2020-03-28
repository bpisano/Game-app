//
//  DataState.swift
//  Websocket
//
//  Created by Benjamin Pisano on 19/03/2020.
//  Copyright © 2020 Snopia. All rights reserved.
//

import Cocoa

enum DataState {
    
    case loading
    case noData
    case data
    case error(_ error: Error)

}
