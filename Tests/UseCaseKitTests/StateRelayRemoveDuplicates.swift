//
// Copyright © 2020 @crexista. All rights reserved.
//

@testable import UseCaseKit
import Quick
import Nimble

class StateRelayRemoveDuplicates: QuickSpec {

    override func spec() {
        let initialState = "test"
        let newState1 = "test1"
        let newState2 = "test2"
        var publisher: StatePublisher<String>!

        describe("StateRelay") {
            context("send no state") {

                beforeEach { publisher = StatePublisher(state: initialState) }

                it("does not call receiver") {
                    let calledOnce = self.expectation(description: "Called once")
                    publisher.filter { $0 != initialState }
                        .removeDuplicates()
                        .sink { _ in calledOnce.fulfill() }
                    expect(XCTWaiter.wait(for: [calledOnce], timeout: 1.0)) == .timedOut
                }
            }

            context("send same state") {

                beforeEach { publisher = StatePublisher(state: initialState) }

                it("calles receiver closure once") {
                    let calledOnce = self.expectation(description: "Called once")
                    publisher.filter { $0 != initialState }
                        .removeDuplicates()
                        .sink { _ in calledOnce.fulfill() }
                    publisher.publish(newState1)
                    publisher.publish(newState1)
                    expect(XCTWaiter.wait(for: [calledOnce], timeout: 1.0)) == .completed
                }
            }

            context("send different state") {

                beforeEach { publisher = StatePublisher(state: initialState) }

                it("calles receiver closure once") {
                    let first = self.expectation(description: "first")
                    let second = self.expectation(description: "second")
                    var count = 1
                    publisher.filter { $0 != initialState }
                        .removeDuplicates()
                        .sink { _ in
                            ((count == 1) ? first : second).fulfill()
                            count += 1
                        }
                    publisher.publish(newState1)
                    publisher.publish(newState2)
                    expect(XCTWaiter.wait(for: [first, second], timeout: 1.0)) == .completed
                }
            }

        }

    }
}
