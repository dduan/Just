//
//  CaseInsensitiveDictionaryTests.swift
//  Just
//
//  Created by Daniel Duan on 6/16/16.
//  Copyright © 2016 JustHTTP. All rights reserved.
//

import XCTest
import Just

final class CaseInsensitiveDictionaryTests: XCTestCase {
    func testInitWithDictionaryLiteral() {
        let d: CaseInsensitiveDictionary = ["a": 1]
        XCTAssertNotNil(d["a"])
    }

    func testInitWithDictionary() {
        let d = CaseInsensitiveDictionary(dictionary: ["a": 1])
        XCTAssertNotNil(d["a"])
        XCTAssertEqual(d["a"], 1)
    }

    func testInsertingNewValueViaSubscript() {
        var d: CaseInsensitiveDictionary<String, Int> = [:]
        XCTAssertNil(d["a"])
        d["a"] = 1
        XCTAssertEqual(d["a"], 1)
    }

    func testRetainAllValueFromInitAfterMutation() {
        var d = CaseInsensitiveDictionary(dictionary: ["a": 1])
        XCTAssertEqual(d["a"], 1)
        d["b"] = 2
        XCTAssertEqual(d["a"], 1)
        XCTAssertEqual(d["b"], 2)
    }

    func testRetainAllValueFromLiteralAfterMutation() {
        var d: CaseInsensitiveDictionary = ["a": 1]
        XCTAssertEqual(d["a"], 1)
        d["b"] = 2
        XCTAssertEqual(d["a"], 1)
        XCTAssertEqual(d["b"], 2)
    }

    func testMutatingCopyDoesNotMutateTheOriginal() {
        var d0: CaseInsensitiveDictionary = ["a": 1]
        var d1 = d0
        d1["a"] = 2
        XCTAssertEqual(d0["a"], 1)
        XCTAssertEqual(d1["a"], 2)
    }

    func testMutatingOriginalDoesNotMutateTheCopy() {
        var d0: CaseInsensitiveDictionary = ["a": 1]
        var d1 = d0
        d0["a"] = 2
        XCTAssertEqual(d0["a"], 2)
        XCTAssertEqual(d1["a"], 1)
    }

    func testValueCasesAreKept() {
        var d: CaseInsensitiveDictionary = ["a": "aAaA", "b": "bbBb"]
        XCTAssertEqual(d["a"], "aAaA")
        XCTAssertEqual(d["b"], "bbBb")
    }

    func testCaseInsensitivityForKeys() {
        var d: CaseInsensitiveDictionary = ["aAaA": "a"]
        XCTAssertEqual(d["aAaA"], "a")
        XCTAssertEqual(d["aaaa"], "a")
        XCTAssertEqual(d["AAAA"], "a")
        XCTAssertEqual(d["AaAa"], "a")
    }
}
