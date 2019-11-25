//
//  PersistentMapTests.swift
//  Tests
//
//  Created by Dean Thompson on 11/23/19.
//  Copyright © 2019 felicity-todo. All rights reserved.
//

import XCTest

@testable import JoyData

class PersistentMapTests: XCTestCase {
    
    func testMeandering() {
        let modulus = 11
        for salt in 0..<10 {
            var dict = Dictionary<Int, Int>()
            var map = ShadowMap<Int, Int>()
            var operations = ""
            for v in 0..<30 {
                let k = (v ^ salt) % modulus
                // It's important to split the cases on a mixture of k and v to avoid
                // consistent patterns of inserts and deletes.
                if (k + v) % 2 == 1 {
                    dict[k] = v
                    map = map.with(k, v)
                    operations += "with(\(k), \(v))\n"
                } else {
                    dict.removeValue(forKey: k)
                    map = map.removing(k)
                    operations += "remove(\(k))\n"
                }
            }
            let dictPairs = dict.map { Pair($0, $1) }
            let mapPairs = map.map { Pair($0, $1) }
            XCTAssertEqual(Set(dictPairs), Set(mapPairs), "\n" + operations)
        }
    }
}
