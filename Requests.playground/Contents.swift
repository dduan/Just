import Foundation

let r = Requests.get("http://httpbin.org/get")

r.headers["content-type"]
r.text
r.json
