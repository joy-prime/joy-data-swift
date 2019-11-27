//
//  HMap.swift
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

public class HMapKey<ValueType>: NamedOnce {
    // This has to be a class to make it mutable when it is the value of an immutable member.
    
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

open class HMapKeys {
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

public struct HMap: Sequence {
    public typealias Element = (QualifiedName, Any)
    public typealias Iterator = DefaultPersistentMap<QualifiedName, Any>.Iterator
    
    private typealias Storage = DefaultPersistentMap<QualifiedName, Any>
    private let storage: Storage
    
    public init() {
        storage = Storage()
    }
    
    public init<S: Sequence>(_ seq: S) where S.Element == Element {
        storage = seq.reduce(Storage(),
                             { (s, kv) in s.with(kv.0, kv.1) })
    }
    
    private init(storage: Storage) {
        self.storage = storage
    }
    
    public func with<Value>(_ hkey: HMapKey<Value>, _ value: Value) -> HMap {
        HMap(storage.with(hkey.name, value))
    }
    
    public func removing<Value>(_ hkey: HMapKey<Value>) -> HMap {
        HMap(storage.removing(hkey.name))
    }
    
    public __consuming func makeIterator() -> HMap.Iterator {
        storage.makeIterator()
    }
    
    public subscript<Value>(hkey: HMapKey<Value>) -> Value? {
        if let a = storage[hkey.name] {
            return a as? Value
        } else {
            return nil
        }

    }
}
