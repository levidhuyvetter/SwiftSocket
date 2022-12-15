import XCTest
@testable import SwiftSocket

final class SwiftSocketTests: XCTestCase {
    func testExample() throws {
        let sock = Socket()
        sock.bind(port:4000)

        sock.listen { data in
                print("Connection")

            let html = "<!DOCTYPE html><html><body style='text-align:center;'><h1>Hello from <a href='https://swift.org'>Swifty</a> Web Server.</h1></body></html>"
            let httpResponse: String = """
            HTTP/1.1 200 OK

            \(html)
            """

                return httpResponse.data(using: .utf8)!
        }

        while true {}
        
    }
}
