//
//  HMapTests.swift
//  Tests
//
//  Created by Dean Thompson on 11/15/19.
//  Copyright © 2019 felicity-todo. All rights reserved.
//

import XCTest

@testable import JoyData

let myNamespace = "org.joy-prime.JoyData.MapTests"

struct MyStruct {
    let i: Int
    let s: String
}

class MyKeys: HMapKeys {
    let myInt: HMapKey<Int> = HMapKey()
    let myString: HMapKey<String> = HMapKey()
    let myStruct: HMapKey<MyStruct> = HMapKey()
}
let myKeys = MyKeys(namespace: myNamespace)

class HMapTests: XCTestCase {
    
    func testKeys() {
        XCTAssertEqual(myKeys.myInt.name,
                       QualifiedName(namespace: myNamespace, label: "myInt"))
        
        XCTAssertEqual(myKeys.myString.name,
                       QualifiedName(namespace: myNamespace, label: "myString"))
        
        XCTAssertEqual(myKeys.myStruct.name,
                       QualifiedName(namespace: myNamespace, label: "myStruct"))
    }
    
    func testOperations() {
        var h = HMap()
        XCTAssertNil(h[myKeys.myInt])
        
        h = h.with(myKeys.myInt, 42)
        XCTAssertEqual(h[myKeys.myInt], 42)
        
        h = h.removing(myKeys.myInt)
        XCTAssertNil(h[myKeys.myInt])
    }
}
