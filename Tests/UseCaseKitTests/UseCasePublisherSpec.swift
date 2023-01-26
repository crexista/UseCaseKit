//
// Copyright © 2021 @crexista. All rights reserved.
//

@testable import UseCaseKit
import Quick
import Nimble
import Combine
import XCTest

@available(iOS 13.0, *)
class UseCasePublisherSpec: QuickSpec {

    override func spec() {
        var usecase: UseCase<MockCommand>?
        var publisher: AnyPublisher<MockCommand.State, Never>?
        var sinkWaiter: XCTestExpectation!
        var deinitWaiter: XCTestExpectation!
        var cancelable: Cancellable?
        var expectedState: MockCommand.State?

        describe("UseCase's AnyPublisher Test") {

            beforeEach {
                deinitWaiter = self.expectation(description: "DeinitListener Waiter")
                sinkWaiter = self.expectation(description: "A Closure that subscriber is called")
                usecase = .test(deinitWaiter)
                publisher = usecase?.asAnyPublisher()
            }

            describe("Publishing stored state test") {

                beforeEach {
                    cancelable = publisher?.sink { expectedState = $0; sinkWaiter.fulfill() }
                }

                it("A state that is stored by usecase is published immediately after `sink`") {
                    expect(expectedState) == .initial
                    expect(XCTWaiter.wait(for: [sinkWaiter], timeout: 1.0, enforceOrder: true)) == .completed
                }

                it("`UseCase`'s subscribing count goes up") {
                    expect(usecase?.subscribersCount) == 1
                }

            }

            describe("Dispatch Command Test") {
                beforeEach {
                    cancelable = publisher?.dropFirst().sink { expectedState = $0 }
                }

                it("A state that is sent after test1 command is dispatched to `UseCase` is mock1") {
                    usecase?.dispatch(.test1)
                    await expect(expectedState == .mock1).toEventually(beTrue())
                }

                it("A state that is sent after test2 command is dispatched to `UseCase` is mock2") {
                    usecase?.dispatch(.test2)
                    await expect(expectedState == .mock2).toEventually(beTrue())
                }
            }

            describe("Cancel Test") {

                beforeEach {
                    cancelable = publisher?.dropFirst().sink { _ in  sinkWaiter.fulfill() }
                    cancelable?.cancel()
                }

                it("subscriber is not called if usecase is command dispatched") {
                    usecase?.dispatch(.test1)
                    expect(XCTWaiter.wait(for: [sinkWaiter], timeout: 1.0, enforceOrder: true)) == .timedOut
                }

                it("`UseCase`'s subscribing count goes down") {
                    expect(usecase?.subscribersCount) == 0
                }

                it("usecase set nil it will be released") {
                    usecase = nil
                    publisher = nil
                    expect(XCTWaiter.wait(for: [deinitWaiter], timeout: 1.0, enforceOrder: true)) == .completed
                }
            }
        }

    }
}
