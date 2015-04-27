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
        describe("URL query string") {
            it("should sends simple query string specified for GET") {
                let r = Just.get("http://httpbin.org/get", params:["a":1])
                if let jsonData = r.json as? [String:AnyObject],
                    let args = jsonData["args"] as? [String:String] {
                    expect(args).to(equal(["a":"1"]))
                } else {
                    fail("expected query string was not sent")
                }
            }
            it("should sends compound query string specified for GET") {
                let r = Just.get("http://httpbin.org/get", params:["a":[1,2]])
                if let jsonData = r.json as? [String:AnyObject],
                    let args = jsonData["args"] as? [String:[String]] {
                    expect(args).to(equal(["a":["1", "2"]]))
                } else {
                    fail("expected query string was not sent")
                }
            }
            it("should sends simple query string specified for POST") {
                let r = Just.post("http://httpbin.org/post", params:["a":1])
                if let jsonData = r.json as? [String:AnyObject],
                    let args = jsonData["args"] as? [String:String] {
                    expect(args).to(equal(["a":"1"]))
                } else {
                    fail("expected query string was not sent")
                }
            }
            it("should sends compound query string specified for POST") {
                let r = Just.post("http://httpbin.org/post", params:["a":[1,2]])
                if let jsonData = r.json as? [String:AnyObject],
                    let args = jsonData["args"] as? [String:[String]] {
                    expect(args).to(equal(["a":["1", "2"]]))
                } else {
                    fail("expected query string was not sent")
                }
            }
        }

        describe("sending url query as http body") {
            it("should add x-www-form-urlencoded header automatically when body is in url format") {
                let r = Just.post("http://httpbin.org/post", data:["a":1])
                if let jsonData = r.json as? [String:AnyObject],
                    let headers = jsonData["headers"] as? [String:String],
                    let contentType = headers["Content-Type"] {
                    expect(contentType).to(equal("application/x-www-form-urlencoded"))
                } else {
                    fail("expected header was not sent")
                }
            }

            // This is a case seemingly possible with python-requests but NSURLSession can not handle
            //it("should add x-www-form-urlencoded header automatically when body is in url format, even for GET requests") {
                //let r = Just.get("http://httpbin.org/get", data:["a":1])
                //if let jsonData = r.json as? [String:AnyObject],
                    //let headers = jsonData["headers"] as? [String:String],
                    //let contentType = headers["Content-Type"] {
                    //expect(contentType).to(equal("application/x-www-form-urlencoded"))
                //} else {
                    //fail("expected header was not sent")
                //}
            //}

            it("should send simple form url query when asked so") {
                let r = Just.post("http://httpbin.org/post", data:["a":1])
                if let jsonData = r.json as? [String:AnyObject],
                    let form = jsonData["form"] as? [String:String] {
                    expect(form).to(equal(["a":"1"]))
                } else {
                    fail("expected form data was not sent")
                }
            }

            it("should send compound form url query when asked so") {
                let r = Just.post("http://httpbin.org/post", data:["a":[1,2]])
                if let jsonData = r.json as? [String:AnyObject],
                    let form = jsonData["form"] as? [String:[String]] {
                    expect(form).to(equal(["a":["1","2"]]))
                } else {
                    fail("expected form data was not sent")
                }
            }
        }

        describe("redirect") {
            it("should redirect when asked to do so") {
            }
            it("should not redircet when asked to do so") {
            }
        }

        describe("JSON sending") {
            it("should not add JSON header when no JSON is supplied") {
                let r = Just.post("http://httpbin.org/post", data:["A":"a"])
                expect(r.ok).to(beTrue())
                if let jsonData = r.json as? [String:AnyObject],
                    let headers = jsonData["headers"] as? [String:String] {
                    if let contentType = headers["Content-Type"] {
                        expect(contentType).toNot(equal("application/json"))
                    }
                }
            }

            it("should add JSON header even if an empty argument is set") {
                let r = Just.post("http://httpbin.org/post", json:[:])
                expect(r.ok).to(beTrue())
                if let jsonData = r.json as? [String:AnyObject],
                    let headers = jsonData["headers"] as? [String:String] {
                    if let contentType = headers["Content-Type"] {
                    expect(contentType).to(equal("application/json"))
                    }
                } else {
                    fail("JSON header was not added when empty JSON argument is supplied")
                }
            }
            it("should send flat JSON data in JSON format") {
                let r = Just.post("http://httpbin.org/post", json:["a":1])
                expect(r.ok).to(beTrue())
                if let data = r.json as? [String:AnyObject],
                    let JSONInData = data["json"] as? [String:Int] {
                    expect(JSONInData).to(equal(["a":1]))
                } else {
                    fail("httpbin did not receive flat JSON data")
                }
            }
            it("should send compound JSON data in JSON format") {
                let r = Just.post("http://httpbin.org/post", json:["a":[1, "b"]])
                expect(r.ok).to(beTrue())
                if let data = r.json as? [String:AnyObject],
                    let JSONInData = data["json"] as? [String:[AnyObject]] {
                    expect(JSONInData).to(equal(["a":[1,"b"]]))
                } else {
                    fail("httpbin did not receive compound JSON data")
                }

            }

            it("JSON argument should override data directive") {
                let r = Just.post("http://httpbin.org/post", data:["b":2], json:["a":1])
                expect(r.ok).to(beTrue())
                if let data = r.json as? [String:AnyObject] {
                    if let JSONInData = data["json"] as? [String:Int] {
                        expect(JSONInData).to(equal(["a":1]))
                        expect(JSONInData).toNot(equal(["b":2]))
                    }
                    if let dataInData = data["data"] as? [String:Int] {
                        expect(dataInData).to(equal(["a":1]))
                        expect(dataInData).toNot(equal(["b":2]))
                    }
                    if let headersInData = data["headers"] as? [String:String] {
                        if let contentType = headersInData["Content-Type"] {
                            expect(contentType).to(equal("application/json"))
                        }
                    }
                }
            }
        }

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

        describe("result status code") {
                expect(Just.get("http://httpbin.org/status/200").statusCode).to(equal(200))
                expect(Just.get("http://httpbin.org/status/302", allowRedirects:false).statusCode).to(equal(302))
                expect(Just.get("http://httpbin.org/status/404").statusCode).to(equal(404))
                expect(Just.get("http://httpbin.org/status/501").statusCode).to(equal(501))
        }

        describe("sending headers") {
            it("should accept empty header arguments") {
                expect(Just.get("http://httpbin.org/get", headers:[:]).ok).to(beTrue())
            }

            it("should send single conventional header as provided") {
                let r = Just.get("http://httpbin.org/get", headers:["Content-Type":"application/json"])
                if let responseData = r.json as? [String:AnyObject],
                    let receivedHeaders = responseData["headers"] as? [String:String] {
                    expect(receivedHeaders["Content-Type"]).to(equal("application/json"))

                }
            }

            it("should send multiple conventional header as provided") {
                let r = Just.get("http://httpbin.org/get", headers:["Accept-Language":"*", "Content-Type":"application/json"])
                if let responseData = r.json as? [String:AnyObject],
                    let receivedHeaders = responseData["headers"] as? [String:String] {
                    expect(receivedHeaders["Content-Type"]).to(equal("application/json"))
                    expect(receivedHeaders["Accept-Language"]).to(equal("*"))
                }
            }

            it("should send multiple arbitrary header as provided") {
                let r = Just.get("http://httpbin.org/get", headers:["Winter is?":"coming", "things-know-by-Jon-Snow":"Just42awesome"])
                if let responseData = r.json as? [String:AnyObject],
                    let receivedHeaders = responseData["headers"] as? [String:String] {
                    expect(receivedHeaders["Winter is?"]).to(equal("coming"))
                    expect(receivedHeaders["things-know-by-Jon-Snow"]).to(equal("Just42awesome"))
                }
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
