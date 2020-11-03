//
// Copyright © 2020 @crexista. All rights reserved.
//

@testable import UseCaseKit
import Quick
import Nimble

class StateSourceSpec: QuickSpec {
    override func spec() {
        var store = Store<MockState>(state: .initial)
        var source: StateSource<MockState> = store.source
        var terminatable: Terminatable?
        var waiter: XCTestExpectation!

        describe("StateSource") {

            beforeEach {
                waiter = self.expectation(description: "A Closure that subscriber is called")
                terminatable = nil
            }

            afterEach { terminatable?.terminate() }

            describe("map Test") {
                beforeEach {
                    source = StateSource(subscribable: { callback -> Terminatable in
                        callback(.mock1)
                        return DefaultTerminatable {}
                    })
                }

                it("calls a closure that registered as subscriber with converted state") {
                    let test = "test_"
                    terminatable = source.map { "\(test)\($0)" }.addSubscriber {
                        expect($0) == "\(test)\(MockState.mock1)"
                        waiter.fulfill()
                    }
                    expect(XCTWaiter.wait(for: [waiter], timeout: 1.0, enforceOrder: true)) == .completed
                }
            }

            describe("addSubscriber Test") {

                context("when source is initialized with store") {
                    beforeEach {
                        store = Store<MockState>(state: .initial)
                        source = StateSource(store: store)
                    }
                    // swiftlint:disable opening_brace
                    it("calls a closure that registered with \(MockState.initial)  before store update") {
                        terminatable = source.addSubscribers(list: [
                            { expect($0) == .initial; waiter.fulfill() }
                        ])
                        expect(XCTWaiter.wait(for: [waiter], timeout: 1.0, enforceOrder: true)) == .completed
                    }

                    it("calls a closure that registered subscriber at once without updating store") {
                        // If called subscriber over two times, error will be thrown.
                        terminatable = source.addSubscribers(list: [ { _ in waiter.fulfill() }, { _ in waiter.fulfill() }])
                        expect(XCTWaiter.wait(for: [waiter], timeout: 1.0, enforceOrder: true)) == .completed
                    }

                    it("calls a closure that registered subscriber with \(MockState.mock1) after store update") {
                        // If called subscriber over two times, error will be thrown.
                        terminatable = source.addSubscribers(list: [
                            { expect($0) == .initial },
                            { expect($0) == .mock1; waiter.fulfill() }
                        ])
                        store.update { $0 = .mock1 }
                        expect(XCTWaiter.wait(for: [waiter], timeout: 1.0, enforceOrder: true)) == .completed
                    }

                    it("doesn't calls closure that registered subscriber anymore after terminate") {
                        // If called subscriber over two times, error will be thrown.
                        terminatable = store.source.addSubscribers(list: [
                            { expect($0) == .initial },
                            { expect($0) == .mock1; waiter.fulfill() }
                        ])
                        terminatable?.terminate()
                        store.update { $0 = .mock1 }
                        expect(XCTWaiter.wait(for: [waiter], timeout: 1.0, enforceOrder: true)) == .timedOut
                    }
                }

            }
        }
    }
}

extension StateSource {
    func addSubscribers(list: [(State) -> Void]) -> Terminatable {
        var i: Int = 0
        return addSubscriber {
            list[i]($0)
            i += 1
        }
    }
}
