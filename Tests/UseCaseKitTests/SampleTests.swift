import XCTest
@testable import UseCaseKit
import Quick
import Nimble

class TestSample: QuickSpec {
    override func spec() {
        describe("sample") {
            it("sample test") {
                expect("test") == "test"
            }
        }
    }
}
