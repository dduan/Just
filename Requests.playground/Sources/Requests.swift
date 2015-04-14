import Foundation

public class HTTPResult : NSObject, Printable, DebugPrintable {
    public var data:NSData?
    public var response:NSURLResponse?
    public var error:NSError?
    public var request:NSURLRequest?
    public var encoding:NSStringEncoding = NSUTF8StringEncoding

    public override var description:String {
        if let status = statusCode {
            return "<HTTPResult [\(status)]>"
        } else {
            return "<HTTPRequest [Empty]>"
        }
    }

    public override var debugDescription:String {
        return description
    }


    init(data:NSData?, response:NSURLResponse?, error:NSError?, request:NSURLRequest?) {
        self.data = data
        self.response = response
        self.error = error
        self.request = request
    }

    public var json:AnyObject? {
        if let theData = self.data {
            return NSJSONSerialization.JSONObjectWithData(theData, options: NSJSONReadingOptions(0), error: nil)
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
        if let theData = self.data {
            return NSString(data:theData, encoding:encoding) as? String
        }
        return nil
    }

    public lazy var headers:CaseInsensitiveDictionary<String,String> = {
        return CaseInsensitiveDictionary<String,String>(dictionary: (self.response as? NSHTTPURLResponse)?.allHeaderFields as? [String:String] ?? [:])
    }()

    public var ok:Bool {
        return statusCode != nil && statusCode! >= 200 && statusCode! < 300
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

public class Requests {

    class var shared: Requests {
        struct Singleton {
            static let instance = Requests()
        }
        return Singleton.instance
    }

    var session: NSURLSession
    var invalidURLError = NSError(domain: "requests.swift", code: 0, userInfo: [NSLocalizedDescriptionKey:"[Requests] URL is invalid"])
    var syncResultAccessError = NSError(domain: "requests.swift", code: 1, userInfo: [NSLocalizedDescriptionKey:"[Requests] You are accessing asynchronous result synchronously."])
    
    init(session:NSURLSession? = nil) {
        if let initialSession = session {
            self.session = initialSession
        } else {
            self.session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        }
    }

    func percentEncodeString(originalObject: AnyObject) -> String {
        if originalObject is NSNull {
            return "null"
        } else {
            let allowedCharacterSet = NSCharacterSet(charactersInString: ":/?@!$&'()*+,;=").invertedSet
            return "\(originalObject)".stringByAddingPercentEncodingWithAllowedCharacters(allowedCharacterSet)!
        }
    }

    func constructFlatRequestBody(parameters: [String: AnyObject]) -> NSData? {
        return (join("&", Array(parameters.keys).map {
            if let value:AnyObject = parameters[$0] {
                return "\(self.percentEncodeString($0))=\(self.percentEncodeString(value))"
            } else {
                return ""
            }
            } as [String]) as NSString).dataUsingEncoding(NSUTF8StringEncoding)
    }

    func makeTask(method:String, URLString:String, data:NSData? = nil, headers:CaseInsensitiveDictionary<String,String>=[:], completionHandler:((HTTPResult) -> Void)? = nil) -> NSURLSessionDataTask? {
        if let url = NSURL(string: URLString) {
            let request = NSMutableURLRequest(URL: url)
            request.HTTPMethod = method
            if let requestData = data {
                request.HTTPBody = requestData
            }
            for (k,v) in headers {
                request.addValue(v, forHTTPHeaderField: k)
            }
            if let handler = completionHandler {
                return session.dataTaskWithRequest(request) { (data, response, error) in
                    let result = HTTPResult(data: data, response: response, error: error, request: request)
                    handler(result)
                }
            } else {
                return session.dataTaskWithRequest(request, completionHandler: nil)
            }
        }
        return nil
    }

    func request(
        method:String,
        URLString:String,
        params:[String:AnyObject]=[:],
        data:NSData?=nil,
        headers:CaseInsensitiveDictionary<String,String>=[:],
        asyncCompletionHandler:((HTTPResult!) -> Void)? = nil) -> HTTPResult {

        let isSync = asyncCompletionHandler == nil
        var semaphore = dispatch_semaphore_create(0)
        var requestResult:HTTPResult = HTTPResult(data: nil, response: nil, error: syncResultAccessError, request: nil)

        var bodyData:NSData?

        // `data` takes priority as body of the request
        if let theData = data {
            bodyData = data
        } else {
            // user indicated json
            var needJSONBody = headers["content-type"]?.lowercaseString == "application/json"

            // parameters aren't flat
            for (k,v) in params {
                if let t = v as? NSDictionary { needJSONBody = true }
                if let t = v as? NSArray { needJSONBody = true }
            }
            if needJSONBody {
                bodyData = NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions(0), error: nil)
            } else {
                bodyData = constructFlatRequestBody(params)
            }

        }


        if let task = makeTask(method, URLString: URLString, data:bodyData, headers: headers, completionHandler: { (result) in
            if let handler = asyncCompletionHandler {
                handler(result)
            }
            if isSync {
                requestResult = result
                dispatch_semaphore_signal(semaphore)
            }
        }) {
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

    public class func get(
        URLString:String,
        params:[String:AnyObject]=[:],
        headers:CaseInsensitiveDictionary<String,String>=[:],
        asyncCompletionHandler:((HTTPResult!) -> Void)? = nil) -> HTTPResult {
        return Requests.shared.request("get", URLString: URLString, params: params, headers: headers, asyncCompletionHandler: asyncCompletionHandler)
    }

    
}