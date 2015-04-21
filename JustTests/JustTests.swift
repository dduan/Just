//
//  JustTests.swift
//  JustTests
//
//  Created by Daniel Duan on 4/21/15.
//  Copyright (c) 2015 JustHTTP. All rights reserved.
//

import Just
import Quick
import Nimble

class JustSpec: QuickSpec {
    override func spec() {

        describe("result ok-ness") {
            it("should be ok with non-error status codes") {
                expect(Just.get("http://httpbin.org/status/200").ok).to(beTrue())
                expect(Just.get("http://httpbin.org/status/299").ok).to(beTrue())
                expect(Just.get("http://httpbin.org/status/301", allowRedirects:false).ok).to(beTrue())
                expect(Just.get("http://httpbin.org/status/302", allowRedirects:false).ok).to(beTrue())
            }

            it("should not be ok with 4xx status codes") {
                expect(Just.get("http://httpbin.org/status/400").ok).toNot(beTrue())
                expect(Just.get("http://httpbin.org/status/401").ok).toNot(beTrue())
                expect(Just.get("http://httpbin.org/status/404").ok).toNot(beTrue())
                expect(Just.get("http://httpbin.org/status/499").ok).toNot(beTrue())
            }

            it("should not be ok with 5xx status codes") {
                expect(Just.get("http://httpbin.org/status/500").ok).toNot(beTrue())
                expect(Just.get("http://httpbin.org/status/501").ok).toNot(beTrue())
                expect(Just.get("http://httpbin.org/status/599").ok).toNot(beTrue())
            }
        }
        describe("basic authentication") {
            it("should fail at a challenge when auth is missing") {
                let r = Just.get("http://httpbin.org/basic-auth/dan/pass")
                expect(r.ok).to(beFalse())
            }
            it("should succeed at a challenge when auth info is correct") {
                let username = "dan"
                let password = "password"
                let r = Just.get("http://httpbin.org/basic-auth/\(username)/\(password)", auth:(username, password))
                expect(r.ok).to(beTrue())
            }
            it("should fail a challenge when auth contains wrong value") {
                let username = "dan"
                let password = "password"
                let r = Just.get("http://httpbin.org/basic-auth/\(username)/\(password)x", auth:(username, password))
                expect(r.ok).to(beFalse())
                expect(r.statusCode).to(equal(401))
            }
        }

        describe("digest authentication") {
            it("should fail at a challenge when auth is missing") {
                let r = Just.get("http://httpbin.org/digest-auth/auth/dan/pass")
                expect(r.ok).to(beFalse())
            }
            it("should succeed at a challenge when auth info is correct") {
                let username = "dan"
                let password = "password"
                let r = Just.get("http://httpbin.org/digest-auth/auth/\(username)/\(password)", auth:(username, password))
                expect(r.ok).to(beTrue())
            }
            it("should fail a challenge when auth contains wrong value") {
                let username = "dan"
                let password = "password"
                let r = Just.get("http://httpbin.org/digest-auth/auth/\(username)/\(password)x", auth:(username, password))
                expect(r.ok).to(beFalse())
                expect(r.statusCode).to(equal(401))
            }
        }



        describe("cookies") {
            it("should get cookies contained in responses") {
                let r = Just.get("http://httpbin.org/cookies/set/test/just", allowRedirects:false)
                expect(r.cookies).toNot(beEmpty())
                expect(r.cookies.keys.array).to(contain("test"))
                if let cookie = r.cookies["test"] {
                    expect(cookie.value).to(equal("just"))
                }
            }
            it("sends cookies in specified in requests") {
                Just.get("http://httpbin.org/cookies/delete?test")
                let r = Just.get("http://httpbin.org/cookies", cookies:["test":"just"])

                if let cookieValue = (r.json as! [String:[String:String]])["cookies"]?["test"] {
                    expect(cookieValue).to(equal("just"))
                } else {
                    fail("httpbin did not find specified cookies")
                }
            }
        }
    }
}
