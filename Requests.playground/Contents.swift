import Foundation

let r = Requests.get("http://httpbin.org/gzip")

r.headers["content-encoding"]
r.text
r.json
r.statusCode