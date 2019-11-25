//
//  PersistentMap.swift
//  
//
//  Created by Dean Thompson on 11/16/19.
//

import Foundation

/// An immutable dictionary that can be built up incrementally with
/// each instance sharing storage with its predecessors.
public protocol PersistentMap: Sequence {
    associatedtype Key: Hashable
    associatedtype Value
    
    subscript(k: Key) -> Value? { get }
    
    func with(_: Key, _: Value) -> Self
    func removing(_: Key) -> Self
}

/// A `PersistentMap` from `Key` to `Value`, implemented with `Dictionary` values
/// that shadow other `Dictionary` values. The details of the cost model are complex,
/// but operations are at worst O(log N).
public final class ShadowMap<Key: Hashable, Value>: PersistentMap
{
    public typealias Element = (Key, Value)
    public typealias Iterator = ShadowMapIterator<Key, Value>
    
    private let underlying: ShadowMap<Key, Value>?
    
    /// Present in `underlying` but removed in this map and not present in `written`.
    private let removedFromUnderlying: Set<Key>
    
    /// Added or modified with respect to `underlying`; not in `removedFromUnderlying`
    private let written: Dictionary<Key, Value>
    
    public let count: Int
    
    private let depth: Int // 1 means has no underlying
    
    public convenience init() {
        self.init(written: [:])
    }
    
    public init(written: Dictionary<Key, Value>) {
        underlying = nil
        removedFromUnderlying = Set()
        self.written = written
        depth = 1
        count = written.count
    }
    
    private init(from: ShadowMap<Key, Value>,
                 removing: Key? = nil,
                 writing: (Key, Value)? = nil) {
        var count = from.count
        var removed = Set<Key>()
        if let rk = removing, from[rk] != nil {
            removed.insert(rk)
            count -= 1
        }
        var written: Dictionary<Key, Value> = [:]
        if let (k, v) = writing {
            written[k] = v
            if from[k] == nil {
                count += 1
            }
        }
        var nextUnderlying = Optional.some(from)
        
        let depthLimit = Int(log(Double(from.count + 1)))
        if from.depth + 1 > depthLimit {
            while let u = nextUnderlying,
                u.depth + 1 > depthLimit / 2 // merge to get the depth down
                || u.count < Int(sqrt(Double(written.count))) // merge unnecessary fragmentation
            {
                // We are moving backwards in time across the underlyings,
                // so newer data and tombstones take precedence.
                let fromUnderlying = u.written.filter { (k, _) in !removed.contains(k) }
                written.merge(fromUnderlying) { (current, _) in current }
                removed.formUnion(u.removedFromUnderlying)
                nextUnderlying = u.underlying
            }
        }
        self.underlying = nextUnderlying
        self.removedFromUnderlying = removed
        self.written = written
        self.depth = (nextUnderlying?.depth ?? 0) + 1
        self.count = count
    }
    
    public subscript(k: Key) -> Value? {
        if let v = written[k] {
            return v
        } else if removedFromUnderlying.contains(k) {
            return nil
        } else if let u = underlying {
            return u[k]
        } else {
            return nil
        }
    }
    
    public func with(_ k: Key, _ v: Value) -> ShadowMap<Key, Value> {
        ShadowMap(from: self, writing: (k, v))
    }
    
    public func removing(_ k: Key) -> ShadowMap<Key, Value> {
        ShadowMap(from: self, removing: k)
    }
    
    public final class ShadowMapIterator<Key: Hashable, Value>: IteratorProtocol {
        public typealias Element = (Key, Value)
        
        private let map: ShadowMap<Key, Value>
        private var ui: ShadowMap<Key, Value>.Iterator?
        private var wi: Dictionary<Key, Value>.Iterator
        
        init(_ map: ShadowMap<Key, Value>) {
            self.map = map
            ui = map.underlying?.makeIterator()
            wi = map.written.makeIterator()
        }
        
        public func next() -> (Key, Value)? {
            while ui != nil {
                if let (k, v) = ui?.next() {
                    if !map.removedFromUnderlying.contains(k) {
                        return (k, v)
                    }
                } else {
                    ui = nil
                }
            }
            return wi.next()
        }
    }
    
    public __consuming func makeIterator() -> Iterator { ShadowMapIterator(self) }
}
