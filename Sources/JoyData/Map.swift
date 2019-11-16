//
//  Map.swift
//  joy-data-swift
//
//  Created by Dean Thompson on 11/11/19.
//  Copyright © 2019 felicity-todo. All rights reserved.
//

import Foundation

public struct QualifiedName: Equatable, Hashable {
    let namespace: String
    let label: String
}

fileprivate protocol NamedOnce {
    var name: QualifiedName {get}
    func setNameOnce(name: QualifiedName) throws
}

public struct AlreadyNamed: Error {
    let existingName: QualifiedName
    let newName: QualifiedName
}

public class MapKey<ValueType>: NamedOnce {
    public var _name: QualifiedName!
    public var name: QualifiedName { _name }
    
    public func setNameOnce(name: QualifiedName) throws {
        if _name == nil {
           _name = name
        } else {
            throw AlreadyNamed(existingName: _name, newName: name)
        }
    }
}

open class MapKeys {
    public private(set) var namespace: String
    
    init(namespace: String) {
        self.namespace = namespace
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let key = child.value as? NamedOnce {
                try! key.setNameOnce(name: QualifiedName(namespace: namespace,
                                                         label: child.label!))
            }
        }
    }
}
