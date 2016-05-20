//
//  CaseInsensitiveDictionarySpecs.swift
//  Just
//
//  Created by Daniel Duan on 4/30/15.
//  Copyright (c) 2015 JustHTTP. All rights reserved.
//

import Nimble
import Quick
import Just

class CaseInsensitiveDictionarySpecs: QuickSpec {

    override func spec() {
        describe("behaving like a dictionary") {
            it("should be initialized by assigining dictionary literals") {
                let d:CaseInsensitiveDictionary<String, Int> = ["a" : 1]
                expect(d["a"]).toNot(beNil())
            }
            it("should accecpt a dictionary in init()") {
                let d = CaseInsensitiveDictionary<String,Int>(dictionary:["a":1])
                expect(d["a"]).toNot(beNil())
                expect(d["a"]).to(equal(1))
            }
            it("should allow insertion of new value via subscript") {
                var d:CaseInsensitiveDictionary<String, Int> = [:]
                expect(d["a"]).to(beNil())
                d["a"] = 1
                expect(d["a"]).toNot(beNil())
                expect(d["a"]).to(equal(1))

            }
            it("should retain all values after mutation when initialized by a dictionary in init()") {
                var d = CaseInsensitiveDictionary<String,Int>(dictionary:["a":1])
                expect(d["a"]).toNot(beNil())
                expect(d["a"]).to(equal(1))
                d["b"] = 2
                expect(d["a"]).toNot(beNil())
                expect(d["a"]).to(equal(1))
                expect(d["b"]).toNot(beNil())
                expect(d["b"]).to(equal(2))
            }
            it("should retain all values after mutation when initialized with dictionary literal") {
                var d:CaseInsensitiveDictionary<String,Int> = ["a":1]
                expect(d["a"]).toNot(beNil())
                expect(d["a"]).to(equal(1))
                d["b"] = 2
                expect(d["a"]).toNot(beNil())
                expect(d["a"]).to(equal(1))
                expect(d["b"]).toNot(beNil())
                expect(d["b"]).to(equal(2))
            }
            it("obeys value semantics, keeps a copy of assigned value") {
                let d1:CaseInsensitiveDictionary<String,Int> = ["a":1]
                let d2 = d1
                expect(d2["a"]).toNot(beNil())
                expect(d2["a"]).to(equal(1))
            }
            it("obeys value semantics, would not mutate when the original does") {
                var d1:CaseInsensitiveDictionary<String,Int> = ["a":1]
                let d2 = d1
                d1["a"] = 2
                expect(d2["a"]).toNot(beNil())
                expect(d2["a"]).to(equal(1))
            }
            it("obeys value semantics, would not mutate the original") {
                var d1:CaseInsensitiveDictionary<String,Int> = ["a":1]
                var d2 = d1
                d2["a"] = 2
                expect(d2["a"]).toNot(beNil())
                expect(d2["a"]).to(equal(2))
                expect(d1["a"]).toNot(beNil())
                expect(d1["a"]).to(equal(1))
            }
            it("obeys value semantics, would not mutate the original with new value") {
                var d1:CaseInsensitiveDictionary<String,Int> = ["a":1]
                var d2 = d1
                d2["b"] = 2
                expect(d2["a"]).toNot(beNil())
                expect(d2["a"]).to(equal(1))
                expect(d2["b"]).toNot(beNil())
                expect(d2["b"]).to(equal(2))
                expect(d1["a"]).toNot(beNil())
                expect(d1["a"]).to(equal(1))
                expect(d1["b"]).to(beNil())
            }
            it("obeys value semantics, retains muliple value from original after mutation") {
                let d1:CaseInsensitiveDictionary<String,Int> = ["a":1, "b": 2]
                var d2 = d1
                expect(d2["a"]).toNot(beNil())
                expect(d2["a"]).to(equal(1))
                expect(d2["b"]).toNot(beNil())
                expect(d2["b"]).to(equal(2))
                d2["b"] = 42
                expect(d2["a"]).toNot(beNil())
                expect(d2["a"]).to(equal(1))
                expect(d2["b"]).toNot(beNil())
                expect(d2["b"]).to(equal(42))
            }
        }

        describe("being case insensitive") {
            it("should keep cases of values") {
                var d:CaseInsensitiveDictionary<String,String> = ["a":"aAaA", "b": "BbBb"]
                expect(d["a"]).toNot(beNil())
                expect(d["a"]).to(equal("aAaA"))
                expect(d["b"]).toNot(beNil())
                expect(d["b"]).to(equal("BbBb"))
            }
            it("should allow access of value regardless of cases of keys") {
                var d:CaseInsensitiveDictionary<String,String> = ["aAaA":"a"]
                expect(d["aAaA"]).to(equal("a"))
                expect(d["AAAA"]).to(equal("a"))
                expect(d["aaaa"]).to(equal("a"))
                expect(d["AaAa"]).to(equal("a"))
            }
        }
    }
}
