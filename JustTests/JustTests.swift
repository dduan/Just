//
//  JustTests.swift
//  Just
//
//  Created by Daniel Duan on 6/17/16.
//  Copyright © 2016 JustHTTP. All rights reserved.
//

import XCTest
import Just

final class JustQueryStringTests: XCTestCase {
    func testDownloadingFileWithProgress() {
        var count = 0
        let expectation = self.expectation(withDescription: "download a large file")
        _ = Just.get("http://www.math.mcgill.ca/triples/Barr-Wells-ctcs.pdf", asyncProgressHandler:{ p in
            count += 1
        }) { _ in
            expectation.fulfill()
        }
        waitForExpectations(withTimeout: 10) { error in
            if let _ = error {
                XCTFail("downloading error")
            } else {
                XCTAssert(count > 0)
            }
        }
    }

    func testSendSimpleQueryStringWithGet() {
        let r = Just.get("http://httpbin.org/get", params:["a": 1])
        XCTAssert(r.json != nil)
        if let jsonData = r.json as? [String:AnyObject] {
            XCTAssert(jsonData["args"] != nil)
            if let args = jsonData["args"] as? [String: String] {
                XCTAssertEqual(args, ["a":"1"])
            }
        }
    }

    func testSendCompoundQueryStringWithGet() {
        let r = Just.get("http://httpbin.org/get", params:["a":[1,2]])
        XCTAssert(r.json != nil)
        if let jsonData = r.json as? [String:AnyObject] {
            XCTAssert(jsonData["args"] != nil)
            if let args = jsonData["args"] as? [String: String] {
                XCTAssertEqual(args, ["a": ["1", "2"]])
            }
        }
    }

    func testSendSimpleQueryStringWithPost() {
        let r = Just.post("http://httpbin.org/post", params:["a": 1])
        XCTAssert(r.json != nil)
        if let jsonData = r.json as? [String:AnyObject] {
            XCTAssert(jsonData["args"] != nil)
            if let args = jsonData["args"] as? [String: String] {
                XCTAssertEqual(args, ["a":"1"])
            }
        }
    }

    func testSendCompoundQueryStringWithPost() {
        let r = Just.post("http://httpbin.org/post", params:["a":[1,2]])
        XCTAssertNotNil(r.json)
        if let jsonData = r.json as? [String:AnyObject] {
            XCTAssert(jsonData["args"] != nil)
            if let args = jsonData["args"] as? [String: String] {
                XCTAssertEqual(args, ["a": ["1", "2"]])
            }
        }
    }
}


final class JustSimpleRequestTests: XCTestCase {
    func testSimpleRequestWithDifferentMethods() {
        var r = Just.delete("http://httpbin.org/delete")
        XCTAssertTrue(r.ok)
        XCTAssertEqual(r.request?.httpMethod, "DELETE")

        r = Just.get("http://httpbin.org/get")
        XCTAssertTrue(r.ok)
        XCTAssertEqual(r.request?.httpMethod, "GET")

        r = Just.head("http://httpbin.org/get")
        XCTAssertTrue(r.ok)
        XCTAssertEqual(r.request?.httpMethod, "HEAD")

        r = Just.options("http://httpbin.org")
        XCTAssertTrue(r.ok)
        XCTAssertEqual(r.request?.httpMethod, "OPTIONS")

        r = Just.patch("http://httpbin.org/patch")
        XCTAssertTrue(r.ok)
        XCTAssertEqual(r.request?.httpMethod, "PATCH")

        r = Just.post("http://httpbin.org/post")
        XCTAssertTrue(r.ok)
        XCTAssertEqual(r.request?.httpMethod, "POST")

        r = Just.put("http://httpbin.org/put")
        XCTAssertTrue(r.ok)
        XCTAssertEqual(r.request?.httpMethod, "PUT")
    }
}

final class JustSendURLQueryAsHTTPBody: XCTestCase {
    func testAddFormHeaderWhenBodyIsInURLFormat() {
        let r = Just.post("http://httpbin.org/post", data:["a": 1])
        XCTAssertNotNil(r.json)
        if let jsonData = r.json as? [String:AnyObject] {
            XCTAssertNotNil(jsonData["headers"])
            if let headers = jsonData["headers"] as? [String: String] {
                XCTAssertNotNil(headers["Content-Type"])
                if let contentType = headers["Content-Type"] {
                    XCTAssertEqual(contentType, "application/x-www-form-urlencoded")
                }
            }
        }
    }

    func testSendSimpleFormURLQueryByDemand() {
        let r = Just.post("http://httpbin.org/post", data: ["a": 1])
        XCTAssertNotNil(r.json)
        if let jsonData = r.json as? [String:AnyObject] {
            XCTAssertNotNil(jsonData["form"])
            if let form = jsonData["form"] as? [String:String] {
                XCTAssertEqual(form, ["a": "1"])
            }
        }
    }

    func testSendCompoundFormURLQueryByDemand() {
        let r = Just.post("http://httpbin.org/post", data: ["a": [1, 2]])
        XCTAssertNotNil(r.json)
        if let jsonData = r.json as? [String: AnyObject] {
            XCTAssertNotNil(jsonData["form"])
            if let form = jsonData["form"] as? [String: String] {
                XCTAssertEqual(form, ["a": ["1", "2"]])
            }
        }
    }
}

final class JustRedirections: XCTestCase {
    func testRedirectByDefault() {
        let r = Just.get("http://httpbin.org/redirect/2")
        XCTAssertNotEqual(r.statusCode, 302)
        XCTAssertEqual(r.statusCode, 200)
    }

    func testRedirectByDemand() {
        let r = Just.get("http://httpbin.org/redirect/2", allowRedirects: true)
        XCTAssertNotEqual(r.statusCode, 302)
        XCTAssertEqual(r.statusCode, 200)
        XCTAssertFalse(r.isRedirect)
        XCTAssertFalse(r.isPermanentRedirect)
    }

    func testNoRedirectByDemand() {
        let r = Just.get("http://httpbin.org/redirect/2", allowRedirects: false)
        XCTAssertNotEqual(r.statusCode, 200)
        XCTAssertEqual(r.statusCode, 302)
        XCTAssertTrue(r.isRedirect)
        XCTAssertFalse(r.isPermanentRedirect)
    }

    func testPermanantRedirect() {
        var r = Just.get("http://httpbin.org/status/302", allowRedirects:false)
        XCTAssertTrue(r.isRedirect)
        XCTAssertFalse(r.isPermanentRedirect)

        r = Just.get("http://httpbin.org/status/301", allowRedirects:false)
        XCTAssertTrue(r.isRedirect)
        XCTAssertTrue(r.isPermanentRedirect)
    }
}

final class JustSendingJSON: XCTestCase {
    func testNoJSONHeaderIfNoJSONIsSupplied() {
        let r = Just.post("http://httpbin.org/post", data:["A":"a"])
        XCTAssertNotNil(r.json)
        if let jsonData = r.json as? [String: AnyObject] {
            XCTAssertNotNil(jsonData["headers"])
            if let headers = jsonData["headers"] as? [String :String] {
                XCTAssertNotNil(headers["Content-Type"])
                if let contentType = headers["Content-Type"] {
                    XCTAssertNotEqual(contentType, "application/json")
                }
            }
        }
    }

    func testShouldAddJSONHeaderForEvenEmptyJSONArgument() {
        let r = Just.post("http://httpbin.org/post", json:[:])
        XCTAssertNotNil(r.json)
        if let jsonData = r.json as? [String: AnyObject] {
            XCTAssertNotNil(jsonData["headers"])
            if let headers = jsonData["headers"] as? [String :String] {
                XCTAssertNotNil(headers["Content-Type"])
                if let contentType = headers["Content-Type"] {
                    XCTAssertEqual(contentType, "application/json")
                }
            }
        }
    }

    func testSendingFlatJSONData() {
        let r = Just.post("http://httpbin.org/post", json:["a": 1])
        XCTAssertNotNil(r.json)
        if let data = r.json as? [String:AnyObject] {
            XCTAssertNotNil(data["json"])
            if let JSONInData = data["json"] as? [String: Int] {
                XCTAssertEqual(JSONInData, ["a": 1])
            }
        }
    }

    func testSendingNestedJSONData() {
        let r = Just.post("http://httpbin.org/post", json:["a": [1, "b"]])
        XCTAssertNotNil(r.json)
        if let data = r.json as? [String:AnyObject] {
            XCTAssertNotNil(data["json"])
            if let JSONInData = data["json"] as? [String: Int] {
                XCTAssertEqual(JSONInData, ["a": [1, "b"]])
            }
        }
    }

    func testJSONArgumentShouldOverrideDataArgument() {
        let r = Just.post("http://httpbin.org/post", data:["b":2], json:["a":1])
        XCTAssertNotNil(r.json)
        if let data = r.json as? [String: AnyObject] {
            XCTAssertNotNil(data["json"])
            if let JSONInData = data["json"] as? [String: Int] {
                XCTAssertEqual(JSONInData, ["a":1])
                XCTAssertNotEqual(JSONInData, ["b":2])
            }
            XCTAssertNotNil(data["data"])
            if let dataInData = data["data"] as? [String: Int] {
                XCTAssertEqual(dataInData, ["a": 1])
                XCTAssertNotEqual(dataInData, ["b": 2])
            }
            XCTAssertNotNil(data["headers"])
            if let headersInData = data["headers"] as? [String: String] {
                XCTAssertNotNil(headersInData["Content-Type"])
                if let contentType = headersInData["Content-Type"] {
                    XCTAssertEqual(contentType, "application/json")
                }
            }
        }
    }
}

final class JustSendingFiles: XCTestCase {
    func testNotIncludeMultipartHeaderForEmptyFiles() {
        let r = Just.post("http://httpbin.org/post", files:[:])
        XCTAssertNotNil(r.json)
        if let data = r.json as? [String: AnyObject] {
            XCTAssertNotNil(data["headers"])
            if let headersInData = data["headers"] as? [String: String] {
                if let contentType = headersInData["Content-Type"] {
                    XCTAssertFalse(contentType.hasPrefix("multipart/form-data; boundary="))
                }
            }
        }
    }

    func testSendingAFileSpecifiedByURLWithoutMimetype() {
        if let elonPhotoURL = Bundle(for: JustSendingFiles.self)
            .urlForResource("elon",  withExtension:"jpg")
        {
            let r = Just.post("http://httpbin.org/post", files:["elon":.url(elonPhotoURL,nil)])
            XCTAssertNotNil(r.json)
            if let data = r.json as? [String: AnyObject] {
                XCTAssertNotNil(data["files"])
                if let files = data["files"] as? [String: String] {
                    XCTAssertNotNil(files["elon"])
                }
            }
        } else {
            XCTFail("resource needed for this test can't be found")
        }
    }

    func testSendingAFileSpecifiedByURLWithMimetype() {
        if let elonPhotoURL = Bundle(for: JustSendingFiles.self)
            .urlForResource("elon",  withExtension:"jpg")
        {
            let r = Just.post("http://httpbin.org/post", files:["elon":.url(elonPhotoURL, "image/jpeg")])
            XCTAssertNotNil(r.json)
            if let data = r.json as? [String: AnyObject] {
                XCTAssertNotNil(data["files"])
                if let files = data["files"] as? [String: String] {
                    XCTAssertNotNil(files["elon"])
                }
            }
        } else {
            XCTFail("resource needed for this test can't be found")
        }
    }

    func testSendingAFileSpecifiedByDataWithoutMimetype() {
        if let dataToSend = "haha not really".data(using: String.Encoding.utf8) {
            let r = Just.post("http://httpbin.org/post", files:["elon":.data("JustTests.swift", dataToSend, nil)])
            XCTAssertNotNil(r.json)
            if let data = r.json as? [String: AnyObject] {
                XCTAssertNotNil(data["files"])
                if let files = data["files"] as? [String:String] {
                    XCTAssertNotNil(files["elon"])
                }
            }
        } else {
            XCTFail("can't encode text as data")
        }
    }

    func testSendingAFileSpecifiedByDataWithMimetype() {
        if let dataToSend = "haha not really".data(using: String.Encoding.utf8) {
            let r = Just.post("http://httpbin.org/post", files:["elon":.data("JustTests.swift", dataToSend, "text/plain")])
            XCTAssertNotNil(r.json)
            if let data = r.json as? [String: AnyObject] {
                XCTAssertNotNil(data["files"])
                if let files = data["files"] as? [String:String] {
                    XCTAssertNotNil(files["elon"])
                }
            }
        } else {
            XCTFail("can't encode text as data")
        }
    }

    func testSendAFileSpecifiedByTextWithoutMimetype() {
        let r = Just.post("http://httpbin.org/post", files:["test":.text("JustTests.swift", "haha not really", nil)])
        XCTAssertNotNil(r.json)
        if let data = r.json as? [String: AnyObject] {
            XCTAssertNotNil(data["files"])
            if let files = data["files"] as? [String: String] {
                XCTAssertNotNil(files["test"])
            }
        }
    }

    func testSendAFileSpecifiedByTextWithMimetype() {
        let r = Just.post("http://httpbin.org/post", files:["test":.text("JustTests.swift", "haha not really", "text/plain")])
        XCTAssertNotNil(r.json)
        if let data = r.json as? [String: AnyObject] {
            XCTAssertNotNil(data["files"])
            if let files = data["files"] as? [String: String] {
                XCTAssertNotNil(files["test"])
            }
        }
    }

    func testSendingMultipleFilesSpecifiedTheSameWay() {
        let r = Just.post(
            "http://httpbin.org/post",
            files:[
                "elon1": .text("JustTests.swift", "haha not really", nil),
                "elon2": .text("JustTests.swift", "haha not really", nil),
                "elon3": .text("JustTests.swift", "haha not really", nil),
                ]
        )
        XCTAssertNotNil(r.json)
        if let data = r.json as? [String: AnyObject] {
            XCTAssertNotNil(data["files"])
            if let files = data["files"] as? [String: String] {
                XCTAssertNotNil(files["elon1"])
                XCTAssertNotNil(files["elon2"])
                XCTAssertNotNil(files["elon3"])
            }
        }
    }

    func testSendingMultipleFilesSpecifiedInDifferentWays() {
        if let dataToSend = "haha not really".data(using: String.Encoding.utf8) {
            let r = Just.post(
                "http://httpbin.org/post",
                files: [
                    "elon1": .text("JustTests.swift", "haha not really", nil),
                    "elon2": .data("JustTests.swift", dataToSend, nil)
                ]
            )
            XCTAssertNotNil(r.json)
            if let data = r.json as? [String: AnyObject] {
                XCTAssertNotNil(data["files"])
                if let files = data["files"] as? [String: String] {
                    XCTAssertNotNil(files["elon1"])
                    XCTAssertNotNil(files["elon2"])
                }
            }
        } else {
            XCTFail("can't encode text as data")
        }
    }

    func testSendingAFileAlongWithSomeData() {
        let r = Just.post(
            "http://httpbin.org/post",
            data:["a":1, "b":2],
            files:["elon1": .text("JustTests.swift", "haha not really", nil)]
        )
        XCTAssertNotNil(r.json)
        if let data = r.json as? [String: AnyObject] {
            XCTAssertNotNil(data["files"])
            if let files = data["files"] as? [String: String] {
                XCTAssertNotNil(files["elon1"])
            }
            XCTAssertNotNil(data["form"])
            if let form = data["form"] as? [String: String] {
                XCTAssertEqual(form, ["a":"1", "b":"2"])
            }
        }
    }

    func testSendingMultipleFilesWithSomeData() {
        if let dataToSend = "haha not really".data(using: String.Encoding.utf8) {
            let r = Just.post(
                "http://httpbin.org/post",
                data:["a":1, "b":2],
                files: [
                    "elon1": .text("JustTests.swift", "haha not really", nil),
                    "elon2": .data("JustTests.swift", dataToSend, nil)
                ]
            )
            XCTAssertNotNil(r.json)
            if let data = r.json as? [String: AnyObject] {
                XCTAssertNotNil(data["files"])
                if let files = data["files"] as? [String: String] {
                    XCTAssertNotNil(files["elon1"])
                    XCTAssertNotNil(files["elon2"])
                }
                XCTAssertNotNil(data["form"])
                if let form = data["form"] as? [String: String] {
                    XCTAssertEqual(form, ["a":"1", "b":"2"])
                }
            }
        } else {
            XCTFail("can't encode text as data")
        }
    }

    func testSendingFilesOveridesJSON() {
        if let dataToSend = "haha not really".data(using: String.Encoding.utf8) {
            let r = Just.post(
                "http://httpbin.org/post",
                json:["a": 1, "b": 2],
                files: [
                    "elon1": .text("JustTests.swift", "haha not really", nil),
                    "elon2": .data("JustTests.swift", dataToSend, nil)
                ]
            )
            XCTAssertNotNil(r.json)
            if let data = r.json as? [String: AnyObject] {
                XCTAssertNotNil(data["json"])
                XCTAssertTrue(data["json"] is NSNull)

                XCTAssertNotNil(data["files"])
                if let files = data["files"] as? [String: String] {
                    XCTAssertNotNil(files["elon1"])
                    XCTAssertNotNil(files["elon2"])
                }
                XCTAssertNotNil(data["form"])
                if let form = data["form"] as? [String:String] {
                    XCTAssertEqual(form, [:])
                }
            }
        } else {
            XCTFail("can't encode text as data")
        }
    }
}
