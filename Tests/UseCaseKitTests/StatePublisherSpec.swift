//
// Copyright © 2020 @crexista. All rights reserved.
//

@testable import UseCaseKit
import Quick
import Nimble

class StatePublisherSpec: QuickSpec {

    override func spec() {
        let initialState = "test"
        var publisher = StatePublisher(state: initialState)

        describe("StatePublisher") {
            context("before publish") {

                beforeEach {
                    publisher = StatePublisher(state: initialState)
                }

                it("sends to state that is retained when is sinked") {
                    waitUntil { end in
                        publisher.sink { expect($0) == initialState; end() }
                    }
                }

                it("sends state to receiver for each sink") {
                    let first = self.expectation(description: "first")
                    let second = self.expectation(description: "second")
                    publisher.sink { expect($0) == initialState; first.fulfill() }
                    publisher.sink { expect($0) == initialState; second.fulfill() }
                    expect(XCTWaiter.wait(for: [first, second], timeout: 1.0, enforceOrder: true)) == .completed
                }

                it("returns current state that is initial state") {
                    expect(publisher.state) == initialState
                }
            }

            context("after publish") {
                let newState = "test2"
                beforeEach {
                    publisher = StatePublisher(state: initialState)
                    publisher.publish(newState)
                }

                it("sends state that published after sending initial state") {
                    let first = self.expectation(description: "first")
                    publisher.filter { $0 != initialState }
                        .sink { expect($0) == newState; first.fulfill() }

                    expect(XCTWaiter.wait(for: [first], timeout: 1.0)) == .completed
                }

                it("multicast state to each receivers") {
                    let first = self.expectation(description: "first")
                    let second = self.expectation(description: "second")

                    publisher.filter { $0 != initialState }
                        .sink { expect($0) == newState; first.fulfill() }

                    publisher.filter { $0 != initialState }
                        .sink { expect($0) == newState; second.fulfill() }

                    expect(XCTWaiter.wait(for: [first, second], timeout: 1.0)) == .completed

                }

                it("return new state") {
                    expect(publisher.state) == newState
                }
            }
        }

    }
}
