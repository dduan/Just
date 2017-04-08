import XCTest
@testable import JustTests

XCTMain([
  CaseInsensitiveDictionaryTests.allTests,
  JustQueryStringTests.allTests,
  JustSimpleRequestTests.allTests,
  JustSendURLQueryAsHTTPBody.allTests,
  JustRedirections.allTests,
  JustSendingJSON.allTests,
  JustSendingFiles.allTests,
  Result.allTests,
  SendingHeader.allTests,
  BasicAuthentication.allTests,
  DigestAuthentication.allTests,
  Cookies.allTests,
  RequestMethods.allTests,
  Timeout.allTests,
  LinkHeader.allTests,
  Configurations.allTests,
])
