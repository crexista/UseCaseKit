//
// Copyright © 2020 @crexista. All rights reserved.
//

@testable import UseCaseKit
import Quick
import Nimble
import XCTest

class DefualtTerminatableSpec: QuickSpec {

    override func spec() {
        var terminateWaiter: XCTestExpectation!
        var terminatable: DefaultTerminatable!

        describe("Terminate test") {
            beforeEach {
                terminateWaiter = self.expectation(description: "terminate called")
                terminatable = DefaultTerminatable { terminateWaiter.fulfill() }
            }

            context("when terminate is called") {
                beforeEach {
                    terminatable.terminate()
                }

                it("a closure that injected when insntace initieated will be called") {
                    expect(XCTWaiter.wait(for: [terminateWaiter], timeout: 1.0, enforceOrder: true)) == .completed
                }

                it("terminatable is true") {
                    expect(terminatable.isTerminated) == true
                }
            }
        }

        describe("Multiple terminate test") {
            it("a closure called only once") {
                var isCalled = 0
                let terminatable = DefaultTerminatable { isCalled += 1 }
                terminatable.terminate()
                terminatable.terminate()
                expect(isCalled) == 1
            }

        }
    }
}
