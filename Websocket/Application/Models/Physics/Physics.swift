//
//  Physics.swift
//  Websocket
//
//  Created by Benjamin Pisano on 20/03/2020.
//  Copyright © 2020 Snopia. All rights reserved.
//

import SpriteKit

struct Physics {
    
    enum BitMak {
        
        case spaceship
        case fire
        
        var category: UInt32 {
            switch self {
            case .spaceship:
                return 0x01 << 1
            case .fire:
                return 0x01 << 2
            }
        }
        
        var contact: UInt32 {
            switch self {
            case .spaceship:
                return BitMak.fire.category
            default:
                return 0
            }
        }
        
        var collisions: UInt32 {
            switch self {
            case .spaceship:
                return BitMak.spaceship.category
            default:
                return 0
            }
        }
                
    }
    
    enum Body {
        
        case spaceship
        case fire
        
        func physicBody(from node: SKSpriteNode) -> SKPhysicsBody {
            switch self {
            case .spaceship:
                return spaceshipPhysicBody(from: node)
            case .fire:
                return firePhysicsBody(from: node)
            }
        }
        
        private func spaceshipPhysicBody(from node: SKSpriteNode) -> SKPhysicsBody {
            let body: SKPhysicsBody = SKPhysicsBody(circleOfRadius: node.size.width / 2 - 10)
            body.isDynamic = true
            body.affectedByGravity = false
            body.allowsRotation = false
            body.usesPreciseCollisionDetection = true
            body.linearDamping = 0.9
            body.categoryBitMask = BitMak.spaceship.category
            body.collisionBitMask = BitMak.spaceship.collisions
            body.contactTestBitMask = BitMak.spaceship.contact
            return body
        }
        
        private func firePhysicsBody(from node: SKSpriteNode) -> SKPhysicsBody {
            let body: SKPhysicsBody = SKPhysicsBody(rectangleOf: node.size)
            body.isDynamic = true
            body.affectedByGravity = false
            body.allowsRotation = false
            body.usesPreciseCollisionDetection = true
            body.categoryBitMask = BitMak.fire.category
            body.collisionBitMask = BitMak.fire.collisions
            body.contactTestBitMask = BitMak.fire.contact
            return body
        }
        
    }

}
