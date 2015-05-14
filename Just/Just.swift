//
//  Just.swift
//  Just
//
//  Created by Daniel Duan on 4/21/15.
//  Copyright (c) 2015 JustHTTP. All rights reserved.
//

import Foundation

// stolen from python-requests
let statusCodeDescriptions = [
    // Informational.
    100: "continue"                      , 101: "switching protocols"             , 102: "processing"                           ,
    103: "checkpoint"                    , 122: "uri too long"                    , 200: "ok"                                   ,
    201: "created"                       , 202: "accepted"                        , 203: "non authoritative info"               ,
    204: "no content"                    , 205: "reset content"                   , 206: "partial content"                      ,
    207: "multi status"                  , 208: "already reported"                , 226: "im used"                              ,

    // Redirection.
    300: "multiple choices"              , 301: "moved permanently"               , 302: "found"                                ,
    303: "see other"                     , 304: "not modified"                    , 305: "use proxy"                            ,
    306: "switch proxy"                  , 307: "temporary redirect"              , 308: "permanent redirect"                   ,

    // Client Error.
    400: "bad request"                   , 401: "unauthorized"                    , 402: "payment required"                     ,
    403: "forbidden"                     , 404: "not found"                       , 405: "method not allowed"                   ,
    406: "not acceptable"                , 407: "proxy authentication required"   , 408: "request timeout"                      ,
    409: "conflict"                      , 410: "gone"                            , 411: "length required"                      ,
    412: "precondition failed"           , 413: "request entity too large"        , 414: "request uri too large"                ,
    415: "unsupported media type"        , 416: "requested range not satisfiable" , 417: "expectation failed"                   ,
    418: "im a teapot"                   , 422: "unprocessable entity"            , 423: "locked"                               ,
    424: "failed dependency"             , 425: "unordered collection"            , 426: "upgrade required"                     ,
    428: "precondition required"         , 429: "too many requests"               , 431: "header fields too large"              ,
    444: "no response"                   , 449: "retry with"                      , 450: "blocked by windows parental controls" ,
    451: "unavailable for legal reasons" , 499: "client closed request"           ,

    // Server Error.
    500: "internal server error"         , 501: "not implemented"                 , 502: "bad gateway"                          ,
    503: "service unavailable"           , 504: "gateway timeout"                 , 505: "http version not supported"           ,
    506: "variant also negotiates"       , 507: "insufficient storage"            , 509: "bandwidth limit exceeded"             ,
    510: "not extended"                  ,
]

extension Just {
    public class func delete(
        URLString:String,
        params:[String:AnyObject] = [:],
        data:[String:AnyObject] = [:],
        json:[String:AnyObject]? = nil,
        headers:[String:String] = [:],
        files:[String:HTTPFile] = [:],
        auth:(String,String)? = nil,
        cookies:[String:String] = [:],
        allowRedirects:Bool = true,
        timeout:Double? = nil,
        URLQuery:String? = nil,
        requestBody:NSData? = nil,
        asyncCompletionHandler:((HTTPResult!) -> Void)? = nil
        ) -> HTTPResult {

            return Just.shared.request(
                .DELETE,
                URLString: URLString,
                params: params,
                data: data,
                json: json,
                headers: headers,
                files:files,
                auth: auth,
                cookies: cookies,
                redirects: allowRedirects,
                timeout:timeout,
                URLQuery: URLQuery,
                requestBody: requestBody,
                asyncCompletionHandler: asyncCompletionHandler
            )

    }

    public class func get(
        URLString:String,
        params:[String:AnyObject] = [:],
        data:[String:AnyObject] = [:],
        json:[String:AnyObject]? = nil,
        headers:[String:String] = [:],
        files:[String:HTTPFile] = [:],
        auth:(String,String)? = nil,
        allowRedirects:Bool = true,
        cookies:[String:String] = [:],
        timeout:Double? = nil,
        requestBody:NSData? = nil,
        URLQuery:String? = nil,
        asyncCompletionHandler:((HTTPResult!) -> Void)? = nil
        ) -> HTTPResult {

            return Just.shared.request(
                .GET,
                URLString: URLString,
                params: params,
                data: data,
                json: json,
                headers: headers,
                files:files,
                auth: auth,
                cookies: cookies,
                redirects: allowRedirects,
                timeout:timeout,
                URLQuery: URLQuery,
                requestBody: requestBody,
                asyncCompletionHandler: asyncCompletionHandler
            )

    }

    public class func head(
        URLString:String,
        params:[String:AnyObject] = [:],
        data:[String:AnyObject] = [:],
        json:[String:AnyObject]? = nil,
        headers:[String:String] = [:],
        files:[String:HTTPFile] = [:],
        auth:(String,String)? = nil,
        cookies:[String:String] = [:],
        allowRedirects:Bool = true,
        timeout:Double? = nil,
        requestBody:NSData? = nil,
        URLQuery:String? = nil,
        asyncCompletionHandler:((HTTPResult!) -> Void)? = nil
        ) -> HTTPResult {

            return Just.shared.request(
                .HEAD,
                URLString: URLString,
                params: params,
                data: data,
                json: json,
                headers: headers,
                files:files,
                auth: auth,
                cookies: cookies,
                redirects: allowRedirects,
                timeout: timeout,
                URLQuery: URLQuery,
                requestBody: requestBody,
                asyncCompletionHandler: asyncCompletionHandler
            )

    }

    public class func options(
        URLString:String,
        params:[String:AnyObject] = [:],
        data:[String:AnyObject] = [:],
        json:[String:AnyObject]? = nil,
        headers:[String:String] = [:],
        files:[String:HTTPFile] = [:],
        auth:(String,String)? = nil,
        cookies:[String:String] = [:],
        allowRedirects:Bool = true,
        timeout:Double? = nil,
        requestBody:NSData? = nil,
        URLQuery:String? = nil,
        asyncCompletionHandler:((HTTPResult!) -> Void)? = nil
        ) -> HTTPResult {

            return Just.shared.request(
                .OPTIONS,
                URLString: URLString,
                params: params,
                data: data,
                json: json,
                headers: headers,
                files:files,
                auth: auth,
                cookies: cookies,
                redirects: allowRedirects,
                timeout: timeout,
                URLQuery: URLQuery,
                requestBody: requestBody,
                asyncCompletionHandler: asyncCompletionHandler
            )

    }

    public class func patch(
        URLString:String,
        params:[String:AnyObject] = [:],
        data:[String:AnyObject] = [:],
        json:[String:AnyObject]? = nil,
        headers:[String:String] = [:],
        files:[String:HTTPFile] = [:],
        auth:(String,String)? = nil,
        cookies:[String:String] = [:],
        allowRedirects:Bool = true,
        timeout:Double? = nil,
        requestBody:NSData? = nil,
        URLQuery:String? = nil,
        asyncCompletionHandler:((HTTPResult!) -> Void)? = nil
        ) -> HTTPResult {

            return Just.shared.request(
                .OPTIONS,
                URLString: URLString,
                params: params,
                data: data,
                json: json,
                headers: headers,
                files:files,
                auth: auth,
                cookies: cookies,
                redirects: allowRedirects,
                timeout: timeout,
                URLQuery: URLQuery,
                requestBody: requestBody,
                asyncCompletionHandler: asyncCompletionHandler
            )

    }

    public class func post(
        URLString:String,
        params:[String:AnyObject] = [:],
        data:[String:AnyObject] = [:],
        json:[String:AnyObject]? = nil,
        headers:[String:String] = [:],
        files:[String:HTTPFile] = [:],
        auth:(String,String)? = nil,
        cookies:[String:String] = [:],
        allowRedirects:Bool = true,
        timeout:Double? = nil,
        requestBody:NSData? = nil,
        URLQuery:String? = nil,
        asyncCompletionHandler:((HTTPResult!) -> Void)? = nil
        ) -> HTTPResult {

            return Just.shared.request(
                .POST,
                URLString: URLString,
                params: params,
                data: data,
                json: json,
                headers: headers,
                files:files,
                auth: auth,
                cookies: cookies,
                redirects: allowRedirects,
                timeout: timeout,
                URLQuery: URLQuery,
                requestBody: requestBody,
                asyncCompletionHandler: asyncCompletionHandler
            )

    }

    public class func put(
        URLString:String,
        params:[String:AnyObject] = [:],
        data:[String:AnyObject] = [:],
        json:[String:AnyObject]? = nil,
        headers:[String:String] = [:],
        files:[String:HTTPFile] = [:],
        auth:(String,String)? = nil,
        cookies:[String:String] = [:],
        allowRedirects:Bool = true,
        timeout:Double? = nil,
        requestBody:NSData? = nil,
        URLQuery:String? = nil,
        asyncCompletionHandler:((HTTPResult!) -> Void)? = nil
        ) -> HTTPResult {

            return Just.shared.request(
                .PUT,
                URLString: URLString,
                params: params,
                data: data,
                json: json,
                headers: headers,
                files:files,
                auth: auth,
                cookies: cookies,
                redirects: allowRedirects,
                timeout: timeout,
                URLQuery: URLQuery,
                requestBody: requestBody,
                asyncCompletionHandler: asyncCompletionHandler
            )

    }
}

public enum HTTPFile {
    case URL(NSURL,String?) // URL to a file, mimetype
    case Data(String,NSData,String?) // filename, data, mimetype
    case Text(String,String,String?) // filename, text, mimetype
}

// Supported request types
enum HTTPMethod: String {
    case DELETE = "DELETE"
    case GET = "GET"
    case HEAD = "HEAD"
    case OPTIONS = "OPTIONS"
    case PATCH = "PATCH"
    case POST = "POST"
    case PUT = "PUT"
}

public class HTTPResult : NSObject, Printable, DebugPrintable {
    public var content:NSData?
    public var response:NSURLResponse?
    public var error:NSError?
    public var request:NSURLRequest?
    public var encoding = NSUTF8StringEncoding
    public var JSONReadingOptions = NSJSONReadingOptions(0)

    public var reason:String {
        if let code = self.statusCode,
            let text = statusCodeDescriptions[code] {
            return text
        }
        if let error = self.error {
            return error.localizedDescription
        }
        return "Unkown"
    }
    public var isRedirect:Bool {
        if let code = self.statusCode {
            return code >= 300 && code < 400
        }
        return false
    }

    public var isPermanentRedirect:Bool {
        return self.statusCode == 301
    }

    public override var description:String {
        if let status = statusCode,
            urlString = request?.URL?.absoluteString,
            method = request?.HTTPMethod
        {
            return "\(method) \(urlString) \(status)"
        } else {
            return "<Empty>"
        }
    }

    public override var debugDescription:String {
        return description
    }

    init(data:NSData?, response:NSURLResponse?, error:NSError?, request:NSURLRequest?) {
        self.content = data
        self.response = response
        self.error = error
        self.request = request
    }

    public var json:AnyObject? {
        if let theData = self.content {
            return NSJSONSerialization.JSONObjectWithData(theData, options: JSONReadingOptions, error: nil)
        }
        return nil
    }
    public var statusCode: Int? {
        if let theResponse = self.response as? NSHTTPURLResponse {
            return theResponse.statusCode
        }
        return nil
    }

    public var text:String? {
        if let theData = self.content {
            return NSString(data:theData, encoding:encoding) as? String
        }
        return nil
    }

    public lazy var headers:CaseInsensitiveDictionary<String,String> = {
        return CaseInsensitiveDictionary<String,String>(dictionary: (self.response as? NSHTTPURLResponse)?.allHeaderFields as? [String:String] ?? [:])
    }()

    public lazy var cookies:[String:NSHTTPCookie] = {
        let foundCookies: [NSHTTPCookie]
        if let responseHeaders = (self.response as? NSHTTPURLResponse)?.allHeaderFields {
            foundCookies = NSHTTPCookie.cookiesWithResponseHeaderFields(responseHeaders, forURL:NSURL(string:"")!) as! [NSHTTPCookie]
        } else {
            foundCookies = []
        }
        var result:[String:NSHTTPCookie] = [:]
        for cookie in foundCookies {
            result[cookie.name] = cookie
        }
        return result
        }()

    public var ok:Bool {
        return statusCode != nil && !(statusCode! >= 400 && statusCode! < 600)
    }

    public var url:NSURL? {
        return response?.URL
    }
}


public struct CaseInsensitiveDictionary<Key: Hashable, Value>: CollectionType, DictionaryLiteralConvertible {
    private var _data:[Key: Value] = [:]
    private var _keyMap: [String: Key] = [:]

    typealias Element = (Key, Value)
    typealias Index = DictionaryIndex<Key, Value>
    public var startIndex: Index
    public var endIndex: Index

    var count: Int {
        assert(_data.count == _keyMap.count, "internal keys out of sync")
        return _data.count
    }

    var isEmpty: Bool {
        return _data.isEmpty
    }

    init() {
        startIndex = _data.startIndex
        endIndex = _data.endIndex
    }

    public init(dictionaryLiteral elements: (Key, Value)...) {
        for (key, value) in elements {
            _keyMap["\(key)".lowercaseString] = key
            _data[key] = value
        }
        startIndex = _data.startIndex
        endIndex = _data.endIndex
    }

    public init(dictionary:[Key:Value]) {
        for (key, value) in dictionary {
            _keyMap["\(key)".lowercaseString] = key
            _data[key] = value
        }
        startIndex = _data.startIndex
        endIndex = _data.endIndex
    }
    public subscript (position: Index) -> Element {
        return _data[position]
    }

    public subscript (key: Key) -> Value? {
        get {
            if let realKey = _keyMap["\(key)".lowercaseString] {
                return _data[realKey]
            }
            return nil
        }
        set(newValue) {
            let lowerKey = "\(key)".lowercaseString
            if _keyMap[lowerKey] == nil {
                _keyMap[lowerKey] = key
            }
            _data[_keyMap[lowerKey]!] = newValue
        }
    }

    public func generate() -> DictionaryGenerator<Key, Value> {
        return _data.generate()
    }

    var keys: LazyForwardCollection<MapCollectionView<[Key : Value], Key>> {
        return _data.keys
    }
    var values: LazyForwardCollection<MapCollectionView<[Key : Value], Value>> {
        return _data.values
    }
}

typealias TaskID = Int
struct TaskConfiguration {
    var credential:(String, String)?
    var redirects:Bool
}

public struct JustSessionDefaults {
    public var JSONReadingOptions = NSJSONReadingOptions(0)
    public var JSONWritingOptions = NSJSONWritingOptions(0)
    public var headers:[String:String] = [:]
    public var multipartBoundary = "Ju5tH77P15Aw350m3"
    public var encoding = NSUTF8StringEncoding
}

public class Just: NSObject, NSURLSessionDelegate, NSURLSessionTaskDelegate {

    class var shared: Just {
        struct Singleton {
            static let instance = Just()
        }
        return Singleton.instance
    }

    var credentials:[Int:(String,String)]=[:]
    var taskConfigs:[TaskID:TaskConfiguration]=[:]
    var defaults:JustSessionDefaults!
    var session: NSURLSession!
    var invalidURLError = NSError(domain: "net.justhttp", code: 0, userInfo: [NSLocalizedDescriptionKey:"[Just] URL is invalid"])
    var syncResultAccessError = NSError(domain: "net.justhttp", code: 1, userInfo: [NSLocalizedDescriptionKey:"[Just] You are accessing asynchronous result synchronously."])
    let errorDomain = "net.justhttp.Just"

    init(session:NSURLSession? = nil, defaults:JustSessionDefaults? = nil) {
        super.init()
        if let initialSession = session {
            self.session = initialSession
        } else {
            self.session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate:self, delegateQueue:nil)
        }
        if let initialDefaults = defaults {
            self.defaults = initialDefaults
        } else {
            self.defaults = JustSessionDefaults()
        }
    }

    func queryComponents(key: String, _ value: AnyObject) -> [(String, String)] {
        var components: [(String, String)] = []
        if let dictionary = value as? [String: AnyObject] {
            for (nestedKey, value) in dictionary {
                components += queryComponents("\(key)[\(nestedKey)]", value)
            }
        } else if let array = value as? [AnyObject] {
            for value in array {
                components += queryComponents("\(key)", value)
            }
        } else {
            components.extend([(percentEncodeString(key), percentEncodeString("\(value)"))])
        }

        return components
    }

    func query(parameters: [String: AnyObject]) -> String {
        var components: [(String, String)] = []
        for key in sorted(Array(parameters.keys), <) {
            let value: AnyObject! = parameters[key]
            components += self.queryComponents(key, value)
        }

        return join("&", components.map{"\($0)=\($1)"} as [String])
    }

    func percentEncodeString(originalObject: AnyObject) -> String {
        if originalObject is NSNull {
            return "null"
        } else {
            let legalURLCharactersToBeEscaped: CFStringRef = ":&=;+!@#$()',*"
            return CFURLCreateStringByAddingPercentEscapes(nil, "\(originalObject)", nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue) as String
        }
    }


    func makeTask(request:NSURLRequest, configuration: TaskConfiguration, completionHandler:((HTTPResult) -> Void)? = nil) -> NSURLSessionDataTask {
        let task:NSURLSessionDataTask
        if let handler = completionHandler {
            task = session.dataTaskWithRequest(request) { (data, response, error) in
                let result = HTTPResult(data: data, response: response, error: error, request: request)
                result.JSONReadingOptions = self.defaults.JSONReadingOptions
                result.encoding = self.defaults.encoding
                handler(result)
            }
        } else {
            task = session.dataTaskWithRequest(request, completionHandler: nil)
        }
        taskConfigs[task.taskIdentifier] = configuration
        return task
    }

    func synthesizeMultipartBody(data:[String:AnyObject], files:[String:HTTPFile]) -> NSData? {
        var body = NSMutableData()
        let boundary = "--\(self.defaults.multipartBoundary)\r\n".dataUsingEncoding(defaults.encoding)!
        for (k,v) in data {
            let valueToSend:AnyObject = v is NSNull ? "null" : v
            body.appendData(boundary)
            body.appendData("Content-Disposition: form-data; name=\"\(k)\"\r\n\r\n".dataUsingEncoding(defaults.encoding)!)
            body.appendData("\(valueToSend)\r\n".dataUsingEncoding(defaults.encoding)!)
        }

        for (k,v) in files {
            body.appendData(boundary)
            var partContent: NSData? = nil
            var partFilename:String? = nil
            var partMimetype:String? = nil
            switch v {
            case let .URL(URL, mimetype):
                if let component = URL.lastPathComponent {
                    partFilename = component
                }
                if let URLContent = NSData(contentsOfURL: URL) {
                    partContent = URLContent
                }
                partMimetype = mimetype
            case let .Text(filename, text, mimetype):
                partFilename = filename
                if let textData = text.dataUsingEncoding(defaults.encoding) {
                    partContent = textData
                }
                partMimetype = mimetype
            case let .Data(filename, data, mimetype):
                partFilename = filename
                partContent = data
                partMimetype = mimetype
            }
            if let content = partContent, let filename = partFilename {
                body.appendData(NSData(data: "Content-Disposition: form-data; name=\"\(k)\"; filename=\"\(filename)\"\r\n".dataUsingEncoding(defaults.encoding)!))
                if let type = partMimetype {
                    body.appendData("Content-Type: \(type)\r\n\r\n".dataUsingEncoding(defaults.encoding)!)
                } else {
                    body.appendData("\r\n".dataUsingEncoding(defaults.encoding)!)
                }
                body.appendData(content)
                body.appendData("\r\n".dataUsingEncoding(defaults.encoding)!)
            }
        }
        if body.length > 0 {
            body.appendData("--\(self.defaults.multipartBoundary)--\r\n".dataUsingEncoding(defaults.encoding)!)
        }
        return body
    }

    func synthesizeRequest(
        method:HTTPMethod,
        URLString:String,
        params:[String:AnyObject],
        data:[String:AnyObject],
        json:[String:AnyObject]?,
        headers:CaseInsensitiveDictionary<String,String>,
        files:[String:HTTPFile],
        timeout:Double?,
        requestBody:NSData?,
        URLQuery:String?
        ) -> NSURLRequest? {
            if let urlComponent = NSURLComponents(string: URLString) {
                var queryString = query(params)

                if count(queryString) > 0 {
                    urlComponent.percentEncodedQuery = queryString
                }

                var finalHeaders = headers
                var contentType:String? = nil
                var body:NSData?

                if let requestData = requestBody {
                    body = requestData
                } else if files.count > 0 {
                    body = synthesizeMultipartBody(data, files:files)
                    contentType = "multipart/form-data; boundary=\(self.defaults.multipartBoundary)"
                } else {
                    if let requestJSON = json {
                        contentType = "application/json"
                        body = NSJSONSerialization.dataWithJSONObject(requestJSON, options: defaults.JSONWritingOptions, error: nil)
                    } else {
                        if data.count > 0 {
                            if headers["content-type"]?.lowercaseString == "application/json" { // assume user wants JSON if she is using this header
                                body = NSJSONSerialization.dataWithJSONObject(data, options: defaults.JSONWritingOptions, error: nil)
                            } else {
                                contentType = "application/x-www-form-urlencoded"
                                body = query(data).dataUsingEncoding(defaults.encoding)
                            }
                        }
                    }
                }

                if let contentTypeValue = contentType {
                    finalHeaders["Content-Type"] = contentTypeValue
                }

                if let URL = urlComponent.URL {
                    let request = NSMutableURLRequest(URL: URL)
                    request.cachePolicy = .ReloadIgnoringLocalCacheData
                    request.HTTPBody = body
                    request.HTTPMethod = method.rawValue
                    if let requestTimeout = timeout {
                        request.timeoutInterval = requestTimeout
                    }

                    for (k,v) in defaults.headers {
                        request.addValue(v, forHTTPHeaderField: k)
                    }

                    for (k,v) in finalHeaders {
                        request.addValue(v, forHTTPHeaderField: k)
                    }
                    return request
                }

            }
            return nil
    }

    func request(
        method:HTTPMethod,
        URLString:String,
        params:[String:AnyObject],
        data:[String:AnyObject],
        json:[String:AnyObject]?,
        headers:[String:String],
        files:[String:HTTPFile],
        auth:(String, String)?,
        cookies: [String:String],
        redirects:Bool,
        timeout:Double?,
        URLQuery:String?,
        requestBody:NSData?,
        asyncCompletionHandler:((HTTPResult!) -> Void)?) -> HTTPResult {

            let isSync = asyncCompletionHandler == nil
            var semaphore = dispatch_semaphore_create(0)
            var requestResult:HTTPResult = HTTPResult(data: nil, response: nil, error: syncResultAccessError, request: nil)

            let config = TaskConfiguration(credential:auth, redirects:redirects)
            let caseInsensitiveHeaders = CaseInsensitiveDictionary<String,String>(dictionary:headers)
            if let request = synthesizeRequest(
                method,
                URLString: URLString,
                params: params,
                data: data,
                json: json,
                headers: caseInsensitiveHeaders,
                files: files,
                timeout:timeout,
                requestBody:requestBody,
                URLQuery: URLQuery
            ) {
                addCookies(request.URL!, newCookies: cookies)
                let task = makeTask(request, configuration:config) { (result) in
                    if let handler = asyncCompletionHandler {
                        handler(result)
                    }
                    if isSync {
                        requestResult = result
                        dispatch_semaphore_signal(semaphore)
                    }
                }
                task.resume()
                if isSync {
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
                    return requestResult
                }
            } else {
                let erronousResult = HTTPResult(data: nil, response: nil, error: invalidURLError, request: nil)
                if let handler = asyncCompletionHandler {
                    handler(erronousResult)
                } else {
                    return erronousResult
                }
            }
            return requestResult

    }

    func addCookies(URL:NSURL, newCookies:[String:String]) {
        for (k,v) in newCookies {
            if let cookie = NSHTTPCookie(properties: [
                NSHTTPCookieName: k,
                NSHTTPCookieValue: v,
                NSHTTPCookieOriginURL: URL,
                NSHTTPCookiePath: "/"
                ]) {
                    session.configuration.HTTPCookieStorage?.setCookie(cookie)
            }
        }
    }

    public func URLSession(
        session: NSURLSession,
        task: NSURLSessionTask,
        didReceiveChallenge challenge: NSURLAuthenticationChallenge,
        completionHandler: (NSURLSessionAuthChallengeDisposition, NSURLCredential!) -> Void
    ) {
        var endCredential:NSURLCredential? = nil

        if let credential = taskConfigs[task.taskIdentifier]?.credential {
            if challenge.previousFailureCount > 0 {
            } else {
                endCredential = NSURLCredential(user: credential.0, password: credential.1, persistence: .ForSession)
            }
        }

        completionHandler(.UseCredential, endCredential)
    }

    public func URLSession(
        session: NSURLSession,
        task: NSURLSessionTask,
        willPerformHTTPRedirection response: NSHTTPURLResponse,
        newRequest request: NSURLRequest, completionHandler: (NSURLRequest!) -> Void
    ) {
        if let allowRedirects = taskConfigs[task.taskIdentifier]?.redirects {
            if !allowRedirects {
                completionHandler(nil)
                return
            }
            completionHandler(request)
        } else {
            completionHandler(request)
        }
    }
}

