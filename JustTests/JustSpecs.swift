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
                expect(r.json).toNot(beNil())
                if let jsonData = r.json as? [String:AnyObject] {
                    expect(jsonData["args"]).toNot(beNil())
                    if let args = jsonData["args"] as? [String:String] {
                        expect(args).to(equal(["a":"1"]))
                    }
                }
            }
            it("should sends compound query string specified for GET") {
                let r = Just.get("http://httpbin.org/get", params:["a":[1,2]])
                expect(r.json).toNot(beNil())
                if let jsonData = r.json as? [String:AnyObject] {
                    expect(jsonData["args"]).toNot(beNil())
                    if let args = jsonData["args"] as? [String:String] {
                        expect(args).to(equal(["a":["1", "2"]]))
                    }
                }
            }

            it("should sends simple query string specified for POST") {
                let r = Just.post("http://httpbin.org/post", params:["a":1])
                expect(r.json).toNot(beNil())
                if let jsonData = r.json as? [String:AnyObject] {
                    expect(jsonData["args"]).toNot(beNil())
                    if let args = jsonData["args"] as? [String:String] {
                        expect(args).to(equal(["a":"1"]))
                    }
                }
            }

            it("should sends compound query string specified for POST") {
                let r = Just.post("http://httpbin.org/post", params:["a":[1,2]])
                expect(r.json).toNot(beNil())
                if let jsonData = r.json as? [String:AnyObject] {
                    expect(jsonData["args"]).toNot(beNil())
                    if let args = jsonData["args"] as? [String:String] {
                        expect(args).to(equal(["a":["1", "2"]]))
                    }
                }
            }
        }

        describe("sending url query as http body") {
            it("should add x-www-form-urlencoded header automatically when body is in url format") {
                let r = Just.post("http://httpbin.org/post", data:["a":1])
                expect(r.json).toNot(beNil())
                if let jsonData = r.json as? [String:AnyObject] {
                    expect(jsonData["headers"]).toNot(beNil())
                    if let headers = jsonData["headers"] as? [String:String] {
                        expect(headers["Content-Type"]).toNot(beNil())
                        if let contentType = headers["Content-Type"] {
                            expect(contentType).to(equal("application/x-www-form-urlencoded"))
                        }
                    }

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
                expect(r.json).toNot(beNil())
                if let jsonData = r.json as? [String:AnyObject] {
                    expect(jsonData["form"]).toNot(beNil())
                    if let form = jsonData["form"] as? [String:String] {
                        expect(form).to(equal(["a":"1"]))
                    }
                }
            }

            it("should send compound form url query when asked so") {
                let r = Just.post("http://httpbin.org/post", data:["a":[1,2]])
                expect(r.json).toNot(beNil())
                if let jsonData = r.json as? [String:AnyObject] {
                    expect(jsonData["form"]).toNot(beNil())
                    if let form = jsonData["form"] as? [String:String] {
                        expect(form).to(equal(["a":["1","2"]]))
                    }
                }
            }
        }

        describe("redirect") {
            it("should redirect by default") {
                let r = Just.get("http://httpbin.org/redirect/2")
                expect(r.statusCode).to(equal(200))
                expect(r.statusCode).toNot(equal(302))
            }
            it("should redirect when asked to do so") {
                let r = Just.get("http://httpbin.org/redirect/2", allowRedirects:true)
                expect(r.statusCode).to(equal(200))
                expect(r.statusCode).toNot(equal(302))
            }
            it("should not redircet when asked to do so") {
                let r = Just.get("http://httpbin.org/redirect/2", allowRedirects:false)
                expect(r.statusCode).toNot(equal(200))
                expect(r.statusCode).to(equal(302))
            }
            it("should report isRedirect as false when it performs redirect") {
                expect(Just.get("http://httpbin.org/redirect/2").isRedirect).to(beFalse())
            }
            it("should report isRedirect as true when it encounters redirect") {
                expect(Just.get("http://httpbin.org/redirect/2", allowRedirects:false).isRedirect).to(beTrue())
            }
            it("should report isPermanentRedirect as false when it performs redirect") {
                expect(Just.get("http://httpbin.org/redirect/2").isPermanentRedirect).to(beFalse())
            }
            it("should report isPermanentRedirect as false when it encounters non permanent redirect") {
                let r = Just.get("http://httpbin.org/status/302", allowRedirects:false)
                expect(r.isRedirect).to(beTrue())
                expect(r.isPermanentRedirect).to(beFalse())
            }
            it("should report isPermanentRedirect as true when it encounters permanent redirect") {
                let r = Just.get("http://httpbin.org/status/301", allowRedirects:false)
                expect(r.isRedirect).to(beTrue())
                expect(r.isPermanentRedirect).to(beTrue())
            }
        }

        describe("JSON sending") {
            it("should not add JSON header when no JSON is supplied") {
                let r = Just.post("http://httpbin.org/post", data:["A":"a"])
                expect(r.json).toNot(beNil())
                if let jsonData = r.json as? [String:AnyObject] {
                    expect(jsonData["headers"]).toNot(beNil())
                    if let headers = jsonData["headers"] as? [String:String] {
                        expect(headers["Content-Type"]).toNot(beNil())
                        if let contentType = headers["Content-Type"] {
                            expect(contentType).toNot(equal("application/json"))
                        }
                    }
                }
            }

            it("should add JSON header even if an empty argument is set") {
                let r = Just.post("http://httpbin.org/post", json:[:])
                expect(r.json).toNot(beNil())
                if let jsonData = r.json as? [String:AnyObject] {
                    expect(jsonData["headers"]).toNot(beNil())
                    if let headers = jsonData["headers"] as? [String:String] {
                        expect(headers["Content-Type"]).toNot(beNil())
                        if let contentType = headers["Content-Type"] {
                            expect(contentType).to(equal("application/json"))
                        }
                    }
                }
            }

            it("should send flat JSON data in JSON format") {
                let r = Just.post("http://httpbin.org/post", json:["a":1])
                expect(r.json).toNot(beNil())
                if let data = r.json as? [String:AnyObject] {
                    expect(data["json"]).toNot(beNil())
                    if let JSONInData = data["json"] as? [String:Int] {
                        expect(JSONInData).to(equal(["a":1]))
                    }
                }
            }

            it("should send compound JSON data in JSON format") {
                let r = Just.post("http://httpbin.org/post", json:["a":[1, "b"]])
                expect(r.json).toNot(beNil())
                if let data = r.json as? [String:AnyObject] {
                    expect(data["json"]).toNot(beNil())
                    if let JSONInData = data["json"] as? [String:[AnyObject]] {
                        expect(JSONInData).to(equal(["a":[1,"b"]]))
                    }
                }

            }

            it("JSON argument should override data directive") {
                let r = Just.post("http://httpbin.org/post", data:["b":2], json:["a":1])
                expect(r.json).toNot(beNil())
                if let data = r.json as? [String:AnyObject] {
                    expect(data["json"]).toNot(beNil())
                    if let JSONInData = data["json"] as? [String:Int] {
                        expect(JSONInData).to(equal(["a":1]))
                        expect(JSONInData).toNot(equal(["b":2]))
                    }
                    expect(data["data"]).toNot(beNil())
                    if let dataInData = data["data"] as? [String:Int] {
                        expect(dataInData).to(equal(["a":1]))
                        expect(dataInData).toNot(equal(["b":2]))
                    }
                    expect(data["headers"]).toNot(beNil())
                    if let headersInData = data["headers"] as? [String:String] {
                        expect(headersInData["Content-Type"]).toNot(beNil())
                        if let contentType = headersInData["Content-Type"] {
                            expect(contentType).to(equal("application/json"))
                        }
                    }
                }
            }
        }

        describe("sending files") {
            it("should not include a multipart header when empty files were specified") {
                let r = Just.post("http://httpbin.org/post", files:[:])
                expect(r.json).toNot(beNil())
                if let data = r.json as? [String:AnyObject] {
                    expect(data["headers"]).toNot(beNil())
                    if let headersInData = data["headers"] as? [String:String] {
                        if let contentType = headersInData["Content-Type"] {
                            expect(contentType).toNot(beginWith("multipart/form-data; boundary="))
                        }
                    }
                }
            }

            it("should be able to send a single file specified by URL without mimetype") {
                if let elonPhotoURL = NSBundle(forClass: JustSpec.self).URLForResource("elon",  withExtension:"jpg") {
                    let r = Just.post("http://httpbin.org/post", files:["elon":.URL(elonPhotoURL,nil)])
                    expect(r.json).toNot(beNil())
                    if let data = r.json as? [String:AnyObject] {
                        expect(data["files"]).toNot(beNil())
                        if let files = data["files"] as? [String:String] {
                            expect(files["elon"]).toNot(beNil())
                        }
                    }
                } else {
                    fail("resource needed for this test can't be found")
                }
            }

            it("should be able to send a single file specified by URL and mimetype") {
                if let elonPhotoURL = NSBundle(forClass: JustSpec.self).URLForResource("elon",  withExtension:"jpg") {
                    let r = Just.post("http://httpbin.org/post", files:["elon":.URL(elonPhotoURL, "image/jpeg")])
                    expect(r.json).toNot(beNil())
                    if let data = r.json as? [String:AnyObject] {
                        expect(data["files"]).toNot(beNil())
                        if let files = data["files"] as? [String:String] {
                            expect(files["elon"]).toNot(beNil())
                        }
                    }
                } else {
                    fail("resource needed for this test can't be found")
                }
            }

            it("should be able to send a single file specified by data without mimetype") {
                if let dataToSend = "haha not really".dataUsingEncoding(NSUTF8StringEncoding) {
                    let r = Just.post("http://httpbin.org/post", files:["elon":.Data("JustTests.swift", dataToSend, nil)])
                    expect(r.json).toNot(beNil())
                    if let data = r.json as? [String:AnyObject] {
                        expect(data["files"]).toNot(beNil())
                        if let files = data["files"] as? [String:String] {
                            expect(files["elon"]).toNot(beNil())
                        }
                    }
                } else {
                    fail("can't encode text as data")
                }
            }

            it("should be able to send a single file specified by data and mimetype") {
                if let dataToSend = "haha not really".dataUsingEncoding(NSUTF8StringEncoding) {
                    let r = Just.post("http://httpbin.org/post", files:["elon":.Data("JustTests.swift", dataToSend, "text/plain")])
                    expect(r.json).toNot(beNil())
                    if let data = r.json as? [String:AnyObject] {
                        expect(data["files"]).toNot(beNil())
                        if let files = data["files"] as? [String:String] {
                            expect(files["elon"]).toNot(beNil())
                        }
                    }
                } else {
                    fail("can't encode text as data")
                }
            }

            it("should be able to send a single file specified by text without mimetype") {
                let r = Just.post("http://httpbin.org/post", files:["test":.Text("JustTests.swift", "haha not really", nil)])
                expect(r.json).toNot(beNil())
                if let data = r.json as? [String:AnyObject] {
                    expect(data["files"]).toNot(beNil())
                    if let files = data["files"] as? [String:String] {
                        expect(files["test"]).toNot(beNil())
                    }
                }
            }

            it("should be able to send a single file specified by text and mimetype") {
                let r = Just.post("http://httpbin.org/post", files:["test":.Text("JustTests.swift", "haha not really", "text/plain")])
                expect(r.json).toNot(beNil())
                if let data = r.json as? [String:AnyObject] {
                    expect(data["files"]).toNot(beNil())
                    if let files = data["files"] as? [String:String] {
                        expect(files["test"]).toNot(beNil())
                    }
                }
            }

            it("should be able to send multiple files specified the same way") {
                let r = Just.post(
                    "http://httpbin.org/post",
                    files:[
                        "elon1": .Text("JustTests.swift", "haha not really", nil),
                        "elon2": .Text("JustTests.swift", "haha not really", nil),
                        "elon3": .Text("JustTests.swift", "haha not really", nil),
                    ]
                )
                expect(r.json).toNot(beNil())
                if let data = r.json as? [String:AnyObject] {
                    expect(data["files"]).toNot(beNil())
                    if let files = data["files"] as? [String:String] {
                        expect(files["elon1"]).toNot(beNil())
                        expect(files["elon2"]).toNot(beNil())
                        expect(files["elon3"]).toNot(beNil())
                    }
                }
            }

            it("should be able to send multiple files specified in different ways") {
                if let dataToSend = "haha not really".dataUsingEncoding(NSUTF8StringEncoding) {
                    let r = Just.post(
                        "http://httpbin.org/post",
                        files: [
                            "elon1": .Text("JustTests.swift", "haha not really", nil),
                            "elon2": .Data("JustTests.swift", dataToSend, nil)
                        ]
                    )
                    expect(r.json).toNot(beNil())
                    if let data = r.json as? [String:AnyObject] {
                        expect(data["files"]).toNot(beNil())
                        if let files = data["files"] as? [String:String] {
                            expect(files["elon1"]).toNot(beNil())
                            expect(files["elon2"]).toNot(beNil())
                        }
                    }
                } else {
                    fail("can't encode text as data")
                }
            }

            it("should be able to send a file along with some data") {
                let r = Just.post(
                    "http://httpbin.org/post",
                    data:["a":1, "b":2],
                    files:[
                        "elon1": .Text("JustTests.swift", "haha not really", nil),
                    ]
                )
                expect(r.json).toNot(beNil())
                if let data = r.json as? [String:AnyObject] {
                    expect(data["files"]).toNot(beNil())
                    if let files = data["files"] as? [String:String] {
                        expect(files["elon1"]).toNot(beNil())
                    }
                    expect(data["form"]).toNot(beNil())
                    if let form = data["form"] as? [String:String] {
                        expect(form).to(equal(["a":"1", "b":"2"]))
                    }
                }
            }

            it("should be able to send multiple files along with some data") {
                if let dataToSend = "haha not really".dataUsingEncoding(NSUTF8StringEncoding) {
                    let r = Just.post(
                        "http://httpbin.org/post",
                        data:["a":1, "b":2],
                        files: [
                            "elon1": .Text("JustTests.swift", "haha not really", nil),
                            "elon2": .Data("JustTests.swift", dataToSend, nil)
                        ]
                    )
                    expect(r.json).toNot(beNil())
                    if let data = r.json as? [String:AnyObject] {
                        expect(data["files"]).toNot(beNil())
                        if let files = data["files"] as? [String:String] {
                            expect(files["elon1"]).toNot(beNil())
                            expect(files["elon2"]).toNot(beNil())
                        }
                        expect(data["form"]).toNot(beNil())
                        if let form = data["form"] as? [String:String] {
                            expect(form).to(equal(["a":"1", "b":"2"]))
                        }
                    }
                } else {
                    fail("can't encode text as data")
                }
            }

            it("should override JSON when files are specified") {
                if let dataToSend = "haha not really".dataUsingEncoding(NSUTF8StringEncoding) {
                    let r = Just.post(
                        "http://httpbin.org/post",
                        json:["a":1, "b":2],
                        files: [
                            "elon1": .Text("JustTests.swift", "haha not really", nil),
                            "elon2": .Data("JustTests.swift", dataToSend, nil)
                        ]
                    )
                    expect(r.json).toNot(beNil())
                    if let data = r.json as? [String:AnyObject] {
                        expect(data["json"]).toNot(beNil())
                        if let json = data["json"] as? NSNull {
                            expect(json).to(beAnInstanceOf(NSNull))
                        }
                        expect(data["files"]).toNot(beNil())
                        if let files = data["files"] as? [String:String] {
                            expect(files["elon1"]).toNot(beNil())
                            expect(files["elon2"]).toNot(beNil())
                        }
                        expect(data["form"]).toNot(beNil())
                        if let form = data["form"] as? [String:String] {
                            expect(form).to(equal([:]))
                        }
                    }
                } else {
                    fail("can't encode text as data")
                }
            }
        }


        describe("result url") {
            it("should contain url from the response") {
                let targetURLString = "http://httpbin.org/get"
                let r = Just.get(targetURLString)
                expect(r.url).toNot(beNil())
                if let urlString = r.url?.absoluteString {
                    expect(urlString).to(equal(targetURLString))
                }
            }
        }

        describe("result ok-ness") {
            it("should be ok with non-error status codes") {
                expect(Just.get("http://httpbin.org/status/200").ok).to(beTrue())
                expect(Just.get("http://httpbin.org/status/299").ok).to(beTrue())
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
                expect(r.json).toNot(beNil())
                if let responseData = r.json as? [String:AnyObject] {
                    expect(responseData["headers"]).toNot(beNil())
                    if let receivedHeaders = responseData["headers"] as? [String:String] {
                        expect(receivedHeaders["Content-Type"]).to(equal("application/json"))
                    }
                }
            }

            it("should send multiple conventional header as provided") {
                let r = Just.get("http://httpbin.org/get", headers:["Accept-Language":"*", "Content-Type":"application/json"])
                expect(r.json).toNot(beNil())
                if let responseData = r.json as? [String:AnyObject] {
                    expect(responseData["headers"]).toNot(beNil())
                    if let receivedHeaders = responseData["headers"] as? [String:String] {
                        expect(receivedHeaders["Content-Type"]).to(equal("application/json"))
                        expect(receivedHeaders["Accept-Language"]).to(equal("*"))
                    }
                }
            }

            it("should send multiple arbitrary header as provided") {
                let r = Just.get("http://httpbin.org/get", headers:["Winter-is":"coming", "things-know-by-Jon-Snow":"Just42awesome"])
                expect(r.json).toNot(beNil())
                if let responseData = r.json as? [String:AnyObject] {
                    expect(responseData["headers"]).toNot(beNil())
                    if let receivedHeaders = responseData["headers"] as? [String:String] {
                        expect(receivedHeaders["Winter-Is"]).to(equal("coming"))
                        expect(receivedHeaders["Things-Know-By-Jon-Snow"]).to(equal("Just42awesome"))
                    }
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

                expect(r.json).toNot(beNil())
                if let jsonData = r.json as? [String:AnyObject] {
                    expect((jsonData["cookies"] as? [String:String])?["test"]).toNot(beNil())
                    if let cookieValue = (jsonData["cookies"] as? [String:String])?["test"] {
                        expect(cookieValue).to(equal("just"))
                    }
                }
            }
        }

        describe("supported request types") {
            it("should include OPTIONS") {
                expect(Just.options("http://httpbin.org/get").ok).to(beTrue())
            }

            it("should include HEAD") {
                expect(Just.head("http://httpbin.org/get").ok).to(beTrue())
            }

            it("should include GET") {
                expect(Just.get("http://httpbin.org/get").ok).to(beTrue())
            }

            it("should include HEAD") {
                expect(Just.head("http://httpbin.org/get").ok).to(beTrue())
            }

            it("should include POST") {
                expect(Just.post("http://httpbin.org/post").ok).to(beTrue())
            }

            it("should include PUT") {
                expect(Just.put("http://httpbin.org/put").ok).to(beTrue())
            }

            it("should include PATCH") {
                expect(Just.patch("http://httpbin.org/patch").ok).to(beTrue())
            }

            it("should include DELETE") {
                expect(Just.delete("http://httpbin.org/delete").ok).to(beTrue())
            }
        }

        describe("timeout") {
            it("should timeout when response is taking longer than specified") {
                let r = Just.get("http://httpbin.org/delay/10", timeout:0.5)
                expect(r.ok).to(beFalse())
            }

            it("should not timeout when response is taking shorter than specified") {
                let r = Just.get("http://httpbin.org/delay/1", timeout:2)
                expect(r.ok).to(beTrue())
            }
        }
    }
}
