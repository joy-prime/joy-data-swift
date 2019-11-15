//
//  Map.swift
//  joy-data-swift
//
//  Created by Dean Thompson on 11/11/19.
//  Copyright © 2019 felicity-todo. All rights reserved.
//

import Foundation

public class MapKey<ValueType> {
    public let definitions: MapKeyDefinitions
    public fileprivate(set) var name = "<tbd>"
    
    init(definitions: MapKeyDefinitions) {
        self.definitions = definitions
    }
}

open class MapKeyDefinitions {
    public private(set) var namespace: String
    
    init(namespace: String) {
        self.namespace = namespace
    }

    func key<ValueType>() -> MapKey<ValueType> {
        MapKey(definitions: self)
    }
}
