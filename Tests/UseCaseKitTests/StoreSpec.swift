//
// Copyright © 2020 @crexista. All rights reserved.
//

@testable import UseCaseKit
import Quick
import Nimble

class StoreSpec: QuickSpec {

    override func spec() {
        let initialState = "test1"
        let currentState = "test2"
        var store = Store(state: initialState)
        describe("Store") {

            context("not update") {

                beforeEach { store = Store(state: initialState) }

                it("returns initial state via currentState property") {
                    expect(store.currentState) == initialState
                }

                it("relays initial state to receiver") {
                    waitUntil { end in
                        store.stateRelay.sink { expect($0) == initialState; end() }
                    }
                }
            }

            context("update state permanently") {
                beforeEach {
                    store = Store(state: initialState)
                    store.update { $0 = currentState }
                }

                it("retunes current state via currentState property") {
                    expect(store.currentState) == currentState
                }

                it("relays current state ") {
                    waitUntil { end in
                        store.stateRelay.sink {
                            expect($0) == currentState
                            end()
                        }
                    }
                }
            }

            context("update state transiently") {
                beforeEach {
                    store = Store(state: initialState)
                }

                it("returns initial state via currentState property") {
                    store.update(transient: true) { $0 = currentState }
                    expect(store.currentState) == initialState
                }

                it("recover to initial state after changing currentState") {
                    let first = self.expectation(description: "first")
                    let second = self.expectation(description: "second")
                    let third = self.expectation(description: "third")
                    var count = 1
                    store.stateRelay.sink {
                        switch count {
                        case 1:
                            expect($0) == initialState
                            first.fulfill()
                        case 2:
                            expect($0) == currentState
                            second.fulfill()
                        case 3:
                            expect($0) == initialState
                            third.fulfill()
                        default: break
                        }
                        count += 1
                    }
                    store.update(transient: true) { $0 = currentState }
                    expect(XCTWaiter.wait(for: [first, second, third], timeout: 1.0, enforceOrder: true)) == .completed
                }

            }
        }
    }
}
