//
//  RequestsTests.swift
//  RequestsTests
//
//  Created by Daniel Duan on 4/18/15.
//
//

import Requests
import Quick
import Nimble

class RequestsSpec: QuickSpec {
    override func spec() {
        describe("cookies") {
            it("should get cookies contained in responses") {
                let r = Requests.get("http://httpbin.org/cookies/set/test/requests", allowRedirects:false)
                expect(r.cookies).toNot(beEmpty())
                expect(r.cookies.keys.array).to(contain("test"))
                if let cookie = r.cookies["test"] {
                    expect(cookie.value).to(equal("requests"))
                }
            }
        }
    }
}
