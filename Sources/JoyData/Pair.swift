//
//  Pair.swift
//  
//
//  Created by Dean Thompson on 11/24/19.
//

import Foundation

struct Pair<X:Hashable,Y:Hashable> : Hashable {
    let x: X
    let y: Y
    
    init(_ x: X, _ y: Y) {
        self.x = x
        self.y = y
    }
}
