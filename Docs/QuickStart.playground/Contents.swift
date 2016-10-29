//: # Just: A Quick Start
//: This is an introduction to the basics of doning HTTP via
//: [Just](http://JustHTTP.net).
//: It's available both on the
//: [web](http://docs.justhttp.net/QuickStart.html)
//: and as a
//: [playground](https://raw.githubusercontent.com/JustHTTP/Just/master/Docs/QuickStart.zip).
//: Readers are assumed to be familiar with the basics of HTTP.
//:
//: ## Simple Requests
//: Just's API is heavily influenced by [python-requests](http://python-requests.org),
//: HTTP for Humans in Python.
//:
//: Here's a simple POST request via Just:

Just.post("http://httpbin.org/post")

//: A GET request with some URL query parameters is as simple as:

Just.get("http://httpbin.org/get", params:["page": 3])

//: The URL is the only required argument when making a request. Just strives
//: for a minimum interface.
//:
//: The following methods can be done in similar ways:
//:
//: - DELETE
//: - GET
//: - HEAD
//: - OPTIONS
//: - PATCH
//: - POST
//: - PUT

//: ## Synchronous v. Asynchronous
//: When working with Swift, we tend to shun sychronous network requests because
//: they block when invoked on the main thread, which would prevent our
//: Cocoa/Cocoa Touch apps from smooth UI rendering. However, there's nothing
//: inherantly wrong with synchronous requests. In fact, synchronous code is often
//: easier to understand and, therefore, a better paradigm to explore HTTP
//: resources with.

var r = Just.get("http://httpbin.org/get", params:["page": 3])
// … "r" becomes available here
//: However, Just doesn't force you to choose. The same request can be made
//: asynchronously like this

Just.get("http://httpbin.org/get", params:["page": 3]) { (r) in
    // the same "r" is available asynchronously here
}

//: That is, you can switch between the two paradigm by adding/removing a
//: callback. When such callback is present, the result of the request becomes
//: available asynchronously as an arugment to the callback. Otherwise,
//: Just will return the very same result synchronously.
//:
//: *Note: asynchronous callbacks does not run on main thread, which is a
//: behavior inherited from NSURLSession. Be sure to dispatch code
//: properly with NSOperationQueue or GCD if you need to update UI in the
//: callback.*
//:
//: The examples in the rest of this document will be synchronous. Keep in
//: mind that all of them can easily be asynchronous.

//: ## HTTP Result
//: The result of a HTTP request is captured in a single object.
//: Let's take a look at *r* from the previous example.

// is the request successful?
r.ok
r.statusCode

//: Hopefully, that's self explainatory. **ok** is *true* if a response is
//: received and the **statusCode** is not *4xx* or *5xx*.
//:
//: Moving on:

// what did the server return?
r.headers       // response headers
r.content       // response body as NSData?
r.text          // response body as text?
r.json          // response body parsed by NSJSONSerielization
r.url           // the URL, as NSURL
r.isRedirect    // is this a redirect response

//: The **headers** property is a Swift-dictionary-like object:

for (k,v) in r.headers {
    print("\(k):\(v)")
}

//: It's different from a normal dictionary in that its values can be accessed
//: by case-insensitive keys:

r.headers["Content-Length"] == r.headers["cOnTeNt-LeNgTh"] // true

//: The original request is preserved as a *NSURLRequest*:

r.request               // NSURLRequest sent
r.request?.httpMethod   // GET

//: When things aren't going so well:
let erronous = Just.get("http://httpbin.org/does/not/exist") // oops
erronous.ok         // nope
erronous.reason     // text description of the failure
erronous.error      // NSError from NSURLSession, if any

//: The best way to "cancel" a request is to never send it. Once a request is
//: made, however, you can express intent to cancel it like so:
r.cancel()

//: ## More Complicated Requests
//:
//: To send form values, use the **data** parameter:

// body of this request will be firstName=Barry&lastName=Allen
// a Content-Type header will be added as application/x-form-www-encoded
Just.post("http://httpbin.org/post", data:["firstName":"Barry","lastName":"Allen"])

//: JSON values are similar:

// body of this request will be JSON encoded.
// Its Content-Type header has value 'application/json'
Just.post("http://httpbin.org/post", json:["firstName":"Barry","lastName":"Allen"])

//: By default, Just follows server's redirect instrution. You can supply an
//: **allowRedirects** argument to control this behavior.

// redirects
Just.get("http://httpbin.org/redirect/2").isRedirect // false

// no redirects
Just.get("http://httpbin.org/redirect/2", allowRedirects:false).isRedirect // true

//: In addition, a permanent redirect can be detected this way:
// permanent redirect
Just.get("http://httpbin.org/status/301", allowRedirects:false).isPermanentRedirect // true

// non permanent redirect
Just.get("http://httpbin.org/status/302", allowRedirects:false).isPermanentRedirect // false

//: ## Files
//: Uploading files is easy with Just:

import Foundation

let elonPhotoURL = Bundle.main.url(forResource: "elon", withExtension: "jpg")!
let uploadResult = Just.post("http://httpbin.org/post", files:["elon": .url(elonPhotoURL, nil)]) // <== that's it
print(uploadResult.text ?? "")

//: Here a file is specified with an NSURL. Alternatively, a file can be a NSData or just a string. Although in both cases, a filename is needed.
let someData = "Marco".data(using: String.Encoding.utf8)! // this shouldn't fail

if let text = Just.post(
    "http://httpbin.org/post",
    files:[
        "a":.data("marco.text", someData, nil), // file #1, an NSData
        "b":.text("polo.txt", "Polo", nil)      // file #2, a String
    ]
    ).text {
    print(text)
}


//: Two files are being uploaded here.
//:
//: The *nil* part of the argument in both examples is an optional String that can be used to specify the MIMEType of the files.
//:
//: **data** parameter can be used in conjuction with **files**. When that happens, though, the *Content-Type* of the request will be *multipart/form-data; ...*.

if let json = Just.post(
    "http://httpbin.org/post",
    data:["lastName":"Musk"],
    files:["elon":.url(elonPhotoURL, nil)]
    ).json as? [String:AnyObject] {
    print(json["form"] ?? [:])      // lastName:Musk
    print(json["files"] ?? [:])     // elon
}


//: ## Link Headers
//: Many HTTP APIs feature Link headers. They make APIs more self describing
//: and discoverable.
//:
//: Github uses these for pagination in their API, for example:

let gh = Just.head("https://api.github.com/users/dduan/repos?page=1&per_page=5")
gh.headers["link"] // <https://api.github.com/user/75067/repos?page=2&per_page=5>; rel="next", <https://api.github.com/user/75067/repos?page=9&per_page=5>; rel="last"

//: Just will automatically parse these link headers and make them easily consumable:

gh.links["next"] // ["rel": "next", "url":"https://api.github.com/user/75067/repos?page=2&per_page=5"]
gh.links["last"] // ["rel": "last", "url":"https://api.github.com/user/75067/repos?page=9&per_page=5"]

//: (be aware of Github's rate limits when you play with these)

//: ## Cookies
//:
//: If you expect the server to return some cookie, you can find them this way:

Just.get("http://httpbin.org/cookies/set/name/elon", allowRedirects:false).cookies["name"] // returns an NSHTTPCookie

//: To send requests with cookies:

Just.get("http://httpbin.org/cookies", cookies:["test":"just"]) // ok

//: ## Authentication
//:
//: If a request is to be challenged by basic or digest authentication, use the **auth** parameter to provide a tuple for username and password

Just.get("http://httpbin.org/basic-auth/flash/allen", auth:("flash", "allen")) // ok

//: ## Timeout
//:
//: You can tell Just to stop waiting for a response after a given number of seconds with the timeout parameter:

// this request won't finish
Just.get("http://httpbin.org/delay/5", timeout:0.2).reason


//: ## Upload and Download Progress
//:
//: When dealing with large files, you may be interested in knowing the progress
//: of their uploading or downloading. You can do that by supplynig a call back
//: to the parameter **asyncProgressHandler**.

Just.post(
    "http://httpbin.org/post",
    files:["large file":.text("or", "pretend this is a large file", nil)],
    asyncProgressHandler: { p in
        p.type // either .Upload or .Download
        p.bytesProcessed
        p.bytesExpectedToProcess
        p.chunk // present when type == .Download
        p.percent
    }
) { r in
    // finished
}

//: The progress handler may be called during sending the request and receiving
//: the response. You can tell them apart by checking the **type** property of the
//: callback argument. In either cases, you can use **bytesProcessed**,
//: **bytesExpectedToProcess** aned **percent** to check the actual progress.


//: ## Customization / Advanced Usage

//: Just is a thin layer with some default settings atop
//: [NSURLSession](https://developer.apple.com/library/ios/documentation/Foundation/Reference/NSURLSession_class/).
//: To change these settings, one must create a separate instance of Just instead of using the
//: default one. Doing so opens up the oppurtunity to customize NSURLSession in
//: powerful ways. A `JustSessionDefaults` can be used to provide some customization points:
//

let myJustDefaults = JustSessionDefaults(
    JSONReadingOptions: .mutableContainers, // NSJSONSerialization reading options
    JSONWritingOptions: .prettyPrinted,     // NSJSONSerialization writing options
    headers:  ["OH":"MY"],                  // headers to include in every request
    multipartBoundary: "Ju5tH77P15Aw350m3", // multipart post request boundaries
    credentialPersistence: .none,           // NSURLCredential persistence options
    encoding: String.Encoding.utf8          // en(de)coding for HTTP body
)

//: Just initializer accepts an `defaults` argement. Use it like this:

let just = JustOf<HTTP>(defaults: myJustDefaults)

just.post("http://httpbin.org/post").request?.allHTTPHeaderFields?["OH"] ?? "" // MY
