import Foundation

// stolen from python-requests
let statusCodeDescriptions = [
  // Informational.
  100: "continue",
  101: "switching protocols",
  102: "processing",
  103: "checkpoint",
  122: "uri too long",
  200: "ok",
  201: "created",
  202: "accepted",
  203: "non authoritative info",
  204: "no content",
  205: "reset content",
  206: "partial content",
  207: "multi status",
  208: "already reported",
  226: "im used",

  // Redirection.
  300: "multiple choices",
  301: "moved permanently",
  302: "found",
  303: "see other",
  304: "not modified",
  305: "use proxy",
  306: "switch proxy",
  307: "temporary redirect",
  308: "permanent redirect",

  // Client Error.
  400: "bad request",
  401: "unauthorized",
  402: "payment required",
  403: "forbidden",
  404: "not found",
  405: "method not allowed",
  406: "not acceptable",
  407: "proxy authentication required",
  408: "request timeout",
  409: "conflict",
  410: "gone",
  411: "length required",
  412: "precondition failed",
  413: "request entity too large",
  414: "request uri too large",
  415: "unsupported media type",
  416: "requested range not satisfiable",
  417: "expectation failed",
  418: "im a teapot",
  422: "unprocessable entity",
  423: "locked",
  424: "failed dependency",
  425: "unordered collection",
  426: "upgrade required",
  428: "precondition required",
  429: "too many requests",
  431: "header fields too large",
  444: "no response",
  449: "retry with",
  450: "blocked by windows parental controls",
  451: "unavailable for legal reasons",
  499: "client closed request",

  // Server Error.
  500: "internal server error",
  501: "not implemented",
  502: "bad gateway",
  503: "service unavailable",
  504: "gateway timeout",
  505: "http version not supported",
  506: "variant also negotiates",
  507: "insufficient storage",
  509: "bandwidth limit exceeded",
  510: "not extended",
]

public enum HTTPFile {
  case url(URL, String?) // URL to a file, mimetype
  case data(String, Foundation.Data, String?) // filename, data, mimetype
  case text(String, String, String?) // filename, text, mimetype
}

// Supported request types
public enum HTTPMethod: String {
  case DELETE = "DELETE"
  case GET = "GET"
  case HEAD = "HEAD"
  case OPTIONS = "OPTIONS"
  case PATCH = "PATCH"
  case POST = "POST"
  case PUT = "PUT"
}

extension URLResponse {
  var HTTPHeaders: [String: String] {
    return (self as? HTTPURLResponse)?.allHeaderFields as? [String: String]
      ?? [:]
  }
}

/// The only reason this is not a struct is the requirements for
/// lazy evaluation of `headers` and `cookies`, which is mutating the
/// struct. This would make those properties unusable with `HTTPResult`s
/// declared with `let`
public final class HTTPResult : NSObject {
  public final var content: Data?
  public var response: URLResponse?
  public var error: Error?
  public var request: URLRequest? { return task?.originalRequest }
  public var task: URLSessionTask?
  public var encoding = String.Encoding.utf8
  public var JSONReadingOptions = JSONSerialization.ReadingOptions(rawValue: 0)

  public var reason: String {
    if let code = self.statusCode, let text = statusCodeDescriptions[code] {
      return text
    }

    if let error = self.error {
      return error.localizedDescription
    }
    return "Unknown"
  }

  public var isRedirect: Bool {
    if let code = self.statusCode {
      return code >= 300 && code < 400
    }
    return false
  }

  public var isPermanentRedirect: Bool {
    return self.statusCode == 301
  }

  public override var description: String {
    if let status = statusCode,
      let urlString = request?.url?.absoluteString,
      let method = request?.httpMethod
    {
      return "\(method) \(urlString) \(status)"
    } else {
      return "<Empty>"
    }
  }

  public init(data: Data?, response: URLResponse?, error: Error?,
              task: URLSessionTask?)
  {
    self.content = data
    self.response = response
    self.error = error
    self.task = task
  }

  public var json: Any? {
    return content.flatMap {
      try? JSONSerialization.jsonObject(with: $0, options: JSONReadingOptions)
    }
  }

  public var statusCode: Int? {
    return (self.response as? HTTPURLResponse)?.statusCode
  }

  public var text: String? {
    return content.flatMap { String(data: $0, encoding: encoding) }
  }

  public lazy var headers: CaseInsensitiveDictionary<String, String> = {
    return CaseInsensitiveDictionary<String, String>(
      dictionary: self.response?.HTTPHeaders ?? [:])
  }()

  public lazy var cookies: [String: HTTPCookie] = {
    let foundCookies: [HTTPCookie]
    if let headers = self.response?.HTTPHeaders, let url = self.response?.url {
      foundCookies = HTTPCookie.cookies(withResponseHeaderFields: headers,
                                        for: url) as [HTTPCookie]
    } else {
      foundCookies = []
    }
    var result: [String: HTTPCookie] = [:]
    for cookie in foundCookies {
      result[cookie.name] = cookie
    }
    return result
  }()

  public var ok: Bool {
    return statusCode != nil && !(statusCode! >= 400 && statusCode! < 600)
  }

  public var url: URL? {
    return response?.url
  }

  public lazy var links: [String: [String: String]] = {
    var result = [String: [String: String]]()
    guard let content = self.headers["link"] else {
      return result
    }
    content.components(separatedBy: ", ").forEach { s in
      let linkComponents = s.components(separatedBy: ";")
        .map {
          ($0 as NSString).trimmingCharacters(in: CharacterSet.whitespaces)
      }
      // although a link without a rel is valid, there's no way to reference it.
      if linkComponents.count > 1 {
        let url = linkComponents.first!
        let start = url.characters.index(url.startIndex, offsetBy: 1)
        let end = url.characters.index(url.endIndex, offsetBy: -1)
        let urlRange = start..<end
        var link: [String: String] = ["url": String(url.characters[urlRange])]
        linkComponents.dropFirst().forEach { s in
          if let equalIndex = s.characters.index(of: "=") {
            let componentKey = String(s.characters[s.startIndex..<equalIndex])
            let range = s.index(equalIndex, offsetBy: 1)..<s.endIndex
            let value = s.characters[range]
            if value.first == "\"" && value.last == "\"" {
              let start = value.index(value.startIndex, offsetBy: 1)
              let end = value.index(value.endIndex, offsetBy: -1)
              link[componentKey] = String(value[start..<end])
            } else {
              link[componentKey] = String(value)
            }
          }
        }
        if let rel = link["rel"] {
          result[rel] = link
        }
      }
    }
    return result
  }()

  public func cancel() {
    task?.cancel()
  }
}

public struct CaseInsensitiveDictionary<Key: Hashable, Value>: Collection,
  ExpressibleByDictionaryLiteral
{
  private var _data: [Key: Value] = [:]
  private var _keyMap: [String: Key] = [:]

  public typealias Element = (key: Key, value: Value)
  public typealias Index = DictionaryIndex<Key, Value>
  public var startIndex: Index {
    return _data.startIndex
  }
  public var endIndex: Index {
    return _data.endIndex
  }
  public func index(after: Index) -> Index {
    return _data.index(after: after)
  }

  public var count: Int {
    assert(_data.count == _keyMap.count, "internal keys out of sync")
    return _data.count
  }

  public var isEmpty: Bool {
    return _data.isEmpty
  }

  public init(dictionaryLiteral elements: (Key, Value)...) {
    for (key, value) in elements {
      _keyMap["\(key)".lowercased()] = key
      _data[key] = value
    }
  }

  public init(dictionary: [Key: Value]) {
    for (key, value) in dictionary {
      _keyMap["\(key)".lowercased()] = key
      _data[key] = value
    }
  }

  public subscript (position: Index) -> Element {
    return _data[position]
  }

  public subscript (key: Key) -> Value? {
    get {
      if let realKey = _keyMap["\(key)".lowercased()] {
        return _data[realKey]
      }
      return nil
    }
    set(newValue) {
      let lowerKey = "\(key)".lowercased()
      if _keyMap[lowerKey] == nil {
        _keyMap[lowerKey] = key
      }
      _data[_keyMap[lowerKey]!] = newValue
    }
  }

  public func makeIterator() -> DictionaryIterator<Key, Value> {
    return _data.makeIterator()
  }

  public var keys: LazyMapCollection<[Key : Value], Key> {
    return _data.keys
  }
  public var values: LazyMapCollection<[Key : Value], Value> {
    return _data.values
  }
}

typealias TaskID = Int
public typealias Credentials = (username: String, password: String)
public typealias TaskProgressHandler = (HTTPProgress) -> Void
typealias TaskCompletionHandler = (HTTPResult) -> Void

struct TaskConfiguration {
  let credential: Credentials?
  let redirects: Bool
  let originalRequest: URLRequest?
  var data: NSMutableData
  let progressHandler: TaskProgressHandler?
  let completionHandler: TaskCompletionHandler?
}

public struct JustSessionDefaults {
  public var JSONReadingOptions: JSONSerialization.ReadingOptions
  public var JSONWritingOptions: JSONSerialization.WritingOptions
  public var headers: [String: String]
  public var multipartBoundary: String
  public var credentialPersistence: URLCredential.Persistence
  public var encoding: String.Encoding
  public var cachePolicy: NSURLRequest.CachePolicy
  public init(
    JSONReadingOptions: JSONSerialization.ReadingOptions =
    JSONSerialization.ReadingOptions(rawValue: 0),
    JSONWritingOptions: JSONSerialization.WritingOptions =
    JSONSerialization.WritingOptions(rawValue: 0),
    headers: [String: String] = [:],
    multipartBoundary: String = "Ju5tH77P15Aw350m3",
    credentialPersistence: URLCredential.Persistence = .forSession,
    encoding: String.Encoding = String.Encoding.utf8,
    cachePolicy: NSURLRequest.CachePolicy = .reloadIgnoringLocalCacheData)
  {
    self.JSONReadingOptions = JSONReadingOptions
    self.JSONWritingOptions = JSONWritingOptions
    self.headers = headers
    self.multipartBoundary = multipartBoundary
    self.encoding = encoding
    self.credentialPersistence = credentialPersistence
    self.cachePolicy = cachePolicy
  }
}


public struct HTTPProgress {
  public enum `Type` {
    case upload
    case download
  }

  public let type: Type
  public let bytesProcessed: Int64
  public let bytesExpectedToProcess: Int64
  public var chunk: Data?
  public var percent: Float {
    return Float(bytesProcessed) / Float(bytesExpectedToProcess)
  }
}

let errorDomain = "net.justhttp.Just"

public protocol JustAdaptor {
  func request(
    _ method: HTTPMethod,
    URLString: String,
    params: [String: Any],
    data: [String: Any],
    json: Any?,
    headers: [String: String],
    files: [String: HTTPFile],
    auth: Credentials?,
    cookies: [String: String],
    redirects: Bool,
    timeout: Double?,
    URLQuery: String?,
    requestBody: Data?,
    asyncProgressHandler: TaskProgressHandler?,
    asyncCompletionHandler: ((HTTPResult) -> Void)?
    ) -> HTTPResult

  init(session: URLSession?, defaults: JustSessionDefaults?)
}

public struct JustOf<Adaptor: JustAdaptor> {
  let adaptor: Adaptor
  public init(session: URLSession? = nil,
              defaults: JustSessionDefaults? = nil)
  {
    adaptor = Adaptor(session: session, defaults: defaults)
  }
}

extension JustOf {

  @discardableResult
  public func request(
    _ method: HTTPMethod,
    URLString: String,
    params: [String: Any] = [:],
    data: [String: Any] = [:],
    json: Any? = nil,
    headers: [String: String] = [:],
    files: [String: HTTPFile] = [:],
    auth: (String, String)? = nil,
    cookies: [String: String] = [:],
    allowRedirects: Bool = true,
    timeout: Double? = nil,
    URLQuery: String? = nil,
    requestBody: Data? = nil,
    asyncProgressHandler: (TaskProgressHandler)? = nil,
    asyncCompletionHandler: ((HTTPResult) -> Void)? = nil
    ) -> HTTPResult {
    return adaptor.request(
      method,
      URLString: URLString,
      params: params,
      data: data,
      json: json,
      headers: headers,
      files: files,
      auth: auth,
      cookies: cookies,
      redirects: allowRedirects,
      timeout: timeout,
      URLQuery: URLQuery,
      requestBody: requestBody,
      asyncProgressHandler: asyncProgressHandler,
      asyncCompletionHandler: asyncCompletionHandler
    )
  }

  @discardableResult
  public func delete(
    _ URLString: String,
    params: [String: Any] = [:],
    data: [String: Any] = [:],
    json: Any? = nil,
    headers: [String: String] = [:],
    files: [String: HTTPFile] = [:],
    auth: (String, String)? = nil,
    cookies: [String: String] = [:],
    allowRedirects: Bool = true,
    timeout: Double? = nil,
    URLQuery: String? = nil,
    requestBody: Data? = nil,
    asyncProgressHandler: (TaskProgressHandler)? = nil,
    asyncCompletionHandler: ((HTTPResult) -> Void)? = nil
    ) -> HTTPResult {

    return adaptor.request(
      .DELETE,
      URLString: URLString,
      params: params,
      data: data,
      json: json,
      headers: headers,
      files: files,
      auth: auth,
      cookies: cookies,
      redirects: allowRedirects,
      timeout: timeout,
      URLQuery: URLQuery,
      requestBody: requestBody,
      asyncProgressHandler: asyncProgressHandler,
      asyncCompletionHandler: asyncCompletionHandler
    )
  }

  @discardableResult
  public func get(
    _ URLString: String,
    params: [String: Any] = [:],
    data: [String: Any] = [:],
    json: Any? = nil,
    headers: [String: String] = [:],
    files: [String: HTTPFile] = [:],
    auth: (String, String)? = nil,
    cookies: [String: String] = [:],
    allowRedirects: Bool = true,
    timeout: Double? = nil,
    URLQuery: String? = nil,
    requestBody: Data? = nil,
    asyncProgressHandler: (TaskProgressHandler)? = nil,
    asyncCompletionHandler: ((HTTPResult) -> Void)? = nil
    ) -> HTTPResult {

    return adaptor.request(
      .GET,
      URLString: URLString,
      params: params,
      data: data,
      json: json,
      headers: headers,
      files: files,
      auth: auth,
      cookies: cookies,
      redirects: allowRedirects,
      timeout: timeout,
      URLQuery: URLQuery,
      requestBody: requestBody,
      asyncProgressHandler: asyncProgressHandler,
      asyncCompletionHandler: asyncCompletionHandler
    )
  }

  @discardableResult
  public func head(
    _ URLString: String,
    params: [String: Any] = [:],
    data: [String: Any] = [:],
    json: Any? = nil,
    headers: [String: String] = [:],
    files: [String: HTTPFile] = [:],
    auth: (String, String)? = nil,
    cookies: [String: String] = [:],
    allowRedirects: Bool = true,
    timeout: Double? = nil,
    URLQuery: String? = nil,
    requestBody: Data? = nil,
    asyncProgressHandler: (TaskProgressHandler)? = nil,
    asyncCompletionHandler: ((HTTPResult) -> Void)? = nil
    ) -> HTTPResult {

    return adaptor.request(
      .HEAD,
      URLString: URLString,
      params: params,
      data: data,
      json: json,
      headers: headers,
      files: files,
      auth: auth,
      cookies: cookies,
      redirects: allowRedirects,
      timeout: timeout,
      URLQuery: URLQuery,
      requestBody: requestBody,
      asyncProgressHandler: asyncProgressHandler,
      asyncCompletionHandler: asyncCompletionHandler
    )
  }

  @discardableResult
  public func options(
    _ URLString: String,
    params: [String: Any] = [:],
    data: [String: Any] = [:],
    json: Any? = nil,
    headers: [String: String] = [:],
    files: [String: HTTPFile] = [:],
    auth: (String, String)? = nil,
    cookies: [String: String] = [:],
    allowRedirects: Bool = true,
    timeout: Double? = nil,
    URLQuery: String? = nil,
    requestBody: Data? = nil,
    asyncProgressHandler: (TaskProgressHandler)? = nil,
    asyncCompletionHandler: ((HTTPResult) -> Void)? = nil
    ) -> HTTPResult {
    return adaptor.request(
      .OPTIONS,
      URLString: URLString,
      params: params,
      data: data,
      json: json,
      headers: headers,
      files: files,
      auth: auth,
      cookies: cookies,
      redirects: allowRedirects,
      timeout: timeout,
      URLQuery: URLQuery,
      requestBody: requestBody,
      asyncProgressHandler: asyncProgressHandler,
      asyncCompletionHandler: asyncCompletionHandler
    )
  }

  @discardableResult
  public func patch(
    _ URLString: String,
    params: [String: Any] = [:],
    data: [String: Any] = [:],
    json: Any? = nil,
    headers: [String: String] = [:],
    files: [String: HTTPFile] = [:],
    auth: (String, String)? = nil,
    cookies: [String: String] = [:],
    allowRedirects: Bool = true,
    timeout: Double? = nil,
    URLQuery: String? = nil,
    requestBody: Data? = nil,
    asyncProgressHandler: (TaskProgressHandler)? = nil,
    asyncCompletionHandler: ((HTTPResult) -> Void)? = nil
    ) -> HTTPResult {

    return adaptor.request(
      .PATCH,
      URLString: URLString,
      params: params,
      data: data,
      json: json,
      headers: headers,
      files: files,
      auth: auth,
      cookies: cookies,
      redirects: allowRedirects,
      timeout: timeout,
      URLQuery: URLQuery,
      requestBody: requestBody,
      asyncProgressHandler: asyncProgressHandler,
      asyncCompletionHandler: asyncCompletionHandler
    )
  }

  @discardableResult
  public func post(
    _ URLString: String,
    params: [String: Any] = [:],
    data: [String: Any] = [:],
    json: Any? = nil,
    headers: [String: String] = [:],
    files: [String: HTTPFile] = [:],
    auth: (String, String)? = nil,
    cookies: [String: String] = [:],
    allowRedirects: Bool = true,
    timeout: Double? = nil,
    URLQuery: String? = nil,
    requestBody: Data? = nil,
    asyncProgressHandler: (TaskProgressHandler)? = nil,
    asyncCompletionHandler: ((HTTPResult) -> Void)? = nil
    ) -> HTTPResult {

    return adaptor.request(
      .POST,
      URLString: URLString,
      params: params,
      data: data,
      json: json,
      headers: headers,
      files: files,
      auth: auth,
      cookies: cookies,
      redirects: allowRedirects,
      timeout: timeout,
      URLQuery: URLQuery,
      requestBody: requestBody,
      asyncProgressHandler: asyncProgressHandler,
      asyncCompletionHandler: asyncCompletionHandler
    )
  }

  @discardableResult
  public func put(
    _ URLString: String,
    params: [String: Any] = [:],
    data: [String: Any] = [:],
    json: Any? = nil,
    headers: [String: String] = [:],
    files: [String: HTTPFile] = [:],
    auth: (String, String)? = nil,
    cookies: [String: String] = [:],
    allowRedirects: Bool = true,
    timeout: Double? = nil,
    URLQuery: String? = nil,
    requestBody: Data? = nil,
    asyncProgressHandler: (TaskProgressHandler)? = nil,
    asyncCompletionHandler: ((HTTPResult) -> Void)? = nil
    ) -> HTTPResult {

    return adaptor.request(
      .PUT,
      URLString: URLString,
      params: params,
      data: data,
      json: json,
      headers: headers,
      files: files,
      auth: auth,
      cookies: cookies,
      redirects: allowRedirects,
      timeout: timeout,
      URLQuery: URLQuery,
      requestBody: requestBody,
      asyncProgressHandler: asyncProgressHandler,
      asyncCompletionHandler: asyncCompletionHandler
    )
  }
}

public final class HTTP: NSObject, URLSessionDelegate, JustAdaptor {

  public init(session: Foundation.URLSession? = nil,
    defaults: JustSessionDefaults? = nil)
  {
    super.init()
    if let initialSession = session {
      self.session = initialSession
    } else {
      self.session = URLSession(configuration: URLSessionConfiguration.default,
        delegate: self, delegateQueue: nil)
    }

    if let initialDefaults = defaults {
      self.defaults = initialDefaults
    } else {
      self.defaults = JustSessionDefaults()
    }
  }

  var taskConfigs: [TaskID: TaskConfiguration]=[:]
  var defaults: JustSessionDefaults!
  var session: URLSession!
  var invalidURLError = NSError(
    domain: errorDomain,
    code: 0,
    userInfo: [NSLocalizedDescriptionKey: "[Just] URL is invalid"]
  )

  var syncResultAccessError = NSError(
    domain: errorDomain,
    code: 1,
    userInfo: [
      NSLocalizedDescriptionKey:
        "[Just] You are accessing asynchronous result synchronously."
    ]
  )

  func queryComponents(_ key: String, _ value: Any) -> [(String, String)] {
    var components: [(String, String)] = []
    if let dictionary = value as? [String: Any] {
      for (nestedKey, value) in dictionary {
        components += queryComponents("\(key)[\(nestedKey)]", value)
      }
    } else if let array = value as? [Any] {
      for value in array {
        components += queryComponents("\(key)", value)
      }
    } else {
      components.append((
        percentEncodeString(key),
        percentEncodeString("\(value)"))
      )
    }

    return components
  }

  func query(_ parameters: [String: Any]) -> String {
    var components: [(String, String)] = []
    for key in Array(parameters.keys).sorted(by: <) {
      let value: Any! = parameters[key]
      components += self.queryComponents(key, value)
    }

    return (components.map{"\($0)=\($1)"} as [String]).joined(separator: "&")
  }

  func percentEncodeString(_ originalObject: Any) -> String {
    if originalObject is NSNull {
      return "null"
    } else {
      var reserved = CharacterSet.urlQueryAllowed
      reserved.remove(charactersIn: ": #[]@!$&'()*+, ;=")
      return String(describing: originalObject)
        .addingPercentEncoding(withAllowedCharacters: reserved) ?? ""
    }
  }


  func makeTask(_ request: URLRequest, configuration: TaskConfiguration)
    -> URLSessionDataTask?
  {
    let task = session.dataTask(with: request)
    taskConfigs[task.taskIdentifier] = configuration
    return task
  }

  func synthesizeMultipartBody(_ data: [String: Any], files: [String: HTTPFile])
    -> Data?
  {
    var body = Data()
    let boundary = "--\(self.defaults.multipartBoundary)\r\n"
      .data(using: defaults.encoding)!
    for (k, v) in data {
      let valueToSend: Any = v is NSNull ? "null" : v
      body.append(boundary)
      body.append("Content-Disposition: form-data; name=\"\(k)\"\r\n\r\n"
        .data(using: defaults.encoding)!)
      body.append("\(valueToSend)\r\n".data(using: defaults.encoding)!)
    }

    for (k, v) in files {
      body.append(boundary)
      var partContent: Data? = nil
      var partFilename: String? = nil
      var partMimetype: String? = nil
      switch v {
      case let .url(URL, mimetype):
        partFilename = URL.lastPathComponent
        if let URLContent = try? Data(contentsOf: URL) {
          partContent = URLContent
        }
        partMimetype = mimetype
      case let .text(filename, text, mimetype):
        partFilename = filename
        if let textData = text.data(using: defaults.encoding) {
          partContent = textData
        }
        partMimetype = mimetype
      case let .data(filename, data, mimetype):
        partFilename = filename
        partContent = data
        partMimetype = mimetype
      }
      if let content = partContent, let filename = partFilename {
        let dispose = "Content-Disposition: form-data; name=\"\(k)\"; filename=\"\(filename)\"\r\n"
        body.append(dispose.data(using: defaults.encoding)!)
        if let type = partMimetype {
          body.append(
            "Content-Type: \(type)\r\n\r\n".data(using: defaults.encoding)!)
        } else {
          body.append("\r\n".data(using: defaults.encoding)!)
        }
        body.append(content)
        body.append("\r\n".data(using: defaults.encoding)!)
      }
    }

    if body.count > 0 {
      body.append("--\(self.defaults.multipartBoundary)--\r\n"
        .data(using: defaults.encoding)!)
    }

    return body
  }

  public func synthesizeRequest(
    _ method: HTTPMethod,
    URLString: String,
    params: [String: Any],
    data: [String: Any],
    json: Any?,
    headers: CaseInsensitiveDictionary<String, String>,
    files: [String: HTTPFile],
    auth: Credentials?,
    timeout: Double?,
    URLQuery: String?,
    requestBody: Data?
    ) -> URLRequest? {
    if let urlComponent = NSURLComponents(string: URLString) {
      let queryString = query(params)

      if queryString.characters.count > 0 {
        urlComponent.percentEncodedQuery = queryString
      }

      var finalHeaders = headers
      var contentType: String? = nil
      var body: Data?

      if let requestData = requestBody {
        body = requestData
      } else if files.count > 0 {
        body = synthesizeMultipartBody(data, files: files)
        let bound = self.defaults.multipartBoundary
        contentType = "multipart/form-data; boundary=\(bound)"
      } else {
        if let requestJSON = json {
          contentType = "application/json"
          body = try? JSONSerialization.data(withJSONObject: requestJSON,
            options: defaults.JSONWritingOptions)

        } else {
          if data.count > 0 {
            // assume user wants JSON if she is using this header
            if headers["content-type"]?.lowercased() == "application/json" {
              body = try? JSONSerialization.data(withJSONObject: data,
                options: defaults.JSONWritingOptions)
            } else {
              contentType = "application/x-www-form-urlencoded"
              body = query(data).data(using: defaults.encoding)
            }
          }
        }
      }

      if let contentTypeValue = contentType {
        finalHeaders["Content-Type"] = contentTypeValue
      }

      if let auth = auth,
        let utf8 = "\(auth.0):\(auth.1)".data(using: String.Encoding.utf8)
      {
        finalHeaders["Authorization"] = "Basic \(utf8.base64EncodedString())"
      }
      if let URL = urlComponent.url {
        var request = URLRequest(url: URL)
        request.cachePolicy = defaults.cachePolicy
        request.httpBody = body
        request.httpMethod = method.rawValue
        if let requestTimeout = timeout {
          request.timeoutInterval = requestTimeout
        }

        for (k, v) in defaults.headers {
          request.addValue(v, forHTTPHeaderField: k)
        }

        for (k, v) in finalHeaders {
          request.addValue(v, forHTTPHeaderField: k)
        }
        return request as URLRequest
      }

    }
    return nil
  }

  public func request(
    _ method: HTTPMethod,
    URLString: String,
    params: [String: Any],
    data: [String: Any],
    json: Any?,
    headers: [String: String],
    files: [String: HTTPFile],
    auth: Credentials?,
    cookies: [String: String],
    redirects: Bool,
    timeout: Double?,
    URLQuery: String?,
    requestBody: Data?,
    asyncProgressHandler: TaskProgressHandler?,
    asyncCompletionHandler: ((HTTPResult) -> Void)?) -> HTTPResult {

    let isSynchronous = asyncCompletionHandler == nil
    let semaphore = DispatchSemaphore(value: 0)
    var requestResult: HTTPResult = HTTPResult(data: nil, response: nil,
      error: syncResultAccessError, task: nil)

    let caseInsensitiveHeaders = CaseInsensitiveDictionary<String, String>(
      dictionary: headers)
    guard let request = synthesizeRequest(method, URLString: URLString,
      params: params, data: data, json: json, headers: caseInsensitiveHeaders,
      files: files, auth: auth, timeout: timeout, URLQuery: URLQuery,
      requestBody: requestBody) else
    {
      let erronousResult = HTTPResult(data: nil, response: nil,
        error: invalidURLError, task: nil)
      if let handler = asyncCompletionHandler {
        handler(erronousResult)
      }
      return erronousResult
    }
    addCookies(request.url!, newCookies: cookies)
    let config = TaskConfiguration(
      credential: auth,
      redirects: redirects,
      originalRequest: request,
      data: NSMutableData(),
      progressHandler: asyncProgressHandler)
    { result in
      if let handler = asyncCompletionHandler {
        handler(result)
      }
      if isSynchronous {
        requestResult = result
        semaphore.signal()
      }
    }

    if let task = makeTask(request, configuration: config) {
      task.resume()
    }

    if isSynchronous {
      let timeout = timeout.flatMap { DispatchTime.now() + $0 }
        ?? DispatchTime.distantFuture
      _ = semaphore.wait(timeout: timeout)
      return requestResult
    }
    return requestResult
  }

  func addCookies(_ URL: Foundation.URL, newCookies: [String: String]) {
    for (k, v) in newCookies {
      if let cookie = HTTPCookie(properties: [
          HTTPCookiePropertyKey.name: k,
          HTTPCookiePropertyKey.value: v,
          HTTPCookiePropertyKey.originURL: URL,
          HTTPCookiePropertyKey.path: "/"
        ])
      {
        session.configuration.httpCookieStorage?.setCookie(cookie)
      }
    }
  }
}

extension HTTP: URLSessionTaskDelegate, URLSessionDataDelegate {
  public func urlSession(_ session: URLSession, task: URLSessionTask,
    didReceive challenge: URLAuthenticationChallenge,
    completionHandler: @escaping (URLSession.AuthChallengeDisposition,
      URLCredential?) -> Void)
    {
    var endCredential: URLCredential? = nil

    if let taskConfig = taskConfigs[task.taskIdentifier],
      let credential = taskConfig.credential
    {
      if !(challenge.previousFailureCount > 0) {
        endCredential = URLCredential(
          user: credential.0,
          password: credential.1,
          persistence: self.defaults.credentialPersistence
        )
      }
    }

    completionHandler(.useCredential, endCredential)
  }

  public func urlSession(_ session: URLSession, task: URLSessionTask,
    willPerformHTTPRedirection response: HTTPURLResponse,
    newRequest request: URLRequest,
    completionHandler: @escaping (URLRequest?) -> Void)
  {
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

  public func urlSession(_ session: URLSession, task: URLSessionTask,
    didSendBodyData bytesSent: Int64, totalBytesSent: Int64,
    totalBytesExpectedToSend: Int64)
  {
    if let handler = taskConfigs[task.taskIdentifier]?.progressHandler {
      handler(
        HTTPProgress(
          type: .upload,
          bytesProcessed: totalBytesSent,
          bytesExpectedToProcess: totalBytesExpectedToSend,
          chunk: nil
        )
      )
    }
  }

  public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask,
    didReceive data: Data)
  {
    if let handler = taskConfigs[dataTask.taskIdentifier]?.progressHandler {
      handler(
        HTTPProgress(
          type: .download,
          bytesProcessed: dataTask.countOfBytesReceived,
          bytesExpectedToProcess: dataTask.countOfBytesExpectedToReceive,
          chunk: data
        )
      )
    }
    if taskConfigs[dataTask.taskIdentifier]?.data != nil {
      taskConfigs[dataTask.taskIdentifier]?.data.append(data)
    }
  }

  public func urlSession(_ session: URLSession, task: URLSessionTask,
    didCompleteWithError error: Error?)
  {
    if let config = taskConfigs[task.taskIdentifier],
      let handler = config.completionHandler
    {
      let result = HTTPResult(
        data: config.data as Data,
        response: task.response,
        error: error,
        task: task
      )
      result.JSONReadingOptions = self.defaults.JSONReadingOptions
      result.encoding = self.defaults.encoding
      handler(result)
    }
    taskConfigs.removeValue(forKey: task.taskIdentifier)
  }
}

public let Just = JustOf<HTTP>()
