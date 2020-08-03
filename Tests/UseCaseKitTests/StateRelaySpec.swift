import XCTest
@testable import UseCaseKit
import Quick
import Nimble

class StateRealySpec: QuickSpec {

    override func spec() {
        describe("StateRelay") {
            context("if it has source callback") {

                it("calles subscribing method") {
                    let test = "test"
                    let stateRelay = StateRelay { subscriber in subscriber(test) }
                    waitUntil { end in
                        stateRelay.sink { expect($0) == test; end() }
                    }
                }
            }

            context("if it has empty source") {
                it("calles subscribing method") {
                    let stateRelay: StateRelay<String> = StateRelay { _ in }
                    let exp = self.expectation(description: "Do not call")
                    stateRelay.sink { _ in  exp.fulfill() }
                    expect(XCTWaiter.wait(for: [exp], timeout: 1.0)) == .timedOut
                }

            }
        }
    }
}
