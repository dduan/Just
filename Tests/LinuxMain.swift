import XCTest
@testable import JustTests

XCTMain([
  testCase(JustQueryStringTests.allTests()),
  testCase(JustSimpleRequestTests.allTests()),
  testCase(JustSendURLQueryAsHTTPBody.allTests()),
  testCase(JustRedirections.allTests()),
  testCase(JustSendingJSON.allTests()),
  testCase(JustSendingFiles.allTests()),
  testCase(Result.allTests()),
  testCase(SendingHeader.allTests()),
  testCase(BasicAuthentication.allTests()),
  testCase(DigestAuthentication.allTests()),
  testCase(Cookies.allTests()),
  testCase(RequestMethods.allTests()),
  testCase(Timeout.allTests()),
  testCase(LinkHeader.allTests()),
  testCase(Configurations.allTests()),
  testCase(CaseInsensitiveDictionaryTests.allTests()),
])
