//
//  Tests.swift
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

class MyKeys: JoyData.MapKeys {
    let myInt: MapKey<Int> = MapKey()
    let myString: MapKey<String> = MapKey()
    let myStruct: MapKey<MyStruct> = MapKey()
}
let myKeys = MyKeys(namespace: myNamespace)

class Tests: XCTestCase {
    
    func testMapKeys() {
        XCTAssert(myKeys.myInt.name == QualifiedName(namespace: myNamespace,
                                                     label: "myInt"))
        XCTAssert(myKeys.myString.name == QualifiedName(namespace: myNamespace,
                                                        label: "myString"))
        XCTAssert(myKeys.myStruct.name == QualifiedName(namespace: myNamespace,
                                                        label: "myStruct"))
    }
}
