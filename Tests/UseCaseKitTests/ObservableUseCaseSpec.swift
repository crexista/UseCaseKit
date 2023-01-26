//
// Copyright © 2021 @crexista. All rights reserved.
//

@testable import UseCaseKit
import Quick
import Nimble
import XCTest

class ObservableUseCaseSpec: QuickSpec {

    override func spec() {
        var usecase: UseCase<MockCommand>!
        var observableMock: ObservableUseCase<MockCommand>!

        describe("StateObject Subscribing Test") {

            context("`UseCase` state is set to `initial`") {

                beforeEach {
                    usecase = .test(nil)
                    observableMock = usecase.asObservableObject()
                }

                it("StateObject's state is `initial`") {
                    expect(observableMock.state) == .initial
                }

                it("`StateObject`'s state will change to mock1 after test1 command is dispatched to `UseCase`") {
                    usecase.dispatch(.test1)
                    await expect(observableMock.state == .mock1).toEventually(beTrue())
                }

                it("`StateObject`'s state will change to mock2 after test2 command is dispatched to `UseCase`") {
                    usecase.dispatch(.test2)
                    await expect(observableMock.state == .mock2).toEventually(beTrue())
                }

            }

        }

        describe("StateObject dispatch Test") {
            context("`UseCase` state is set to `initial`") {

                beforeEach {
                    usecase = .test(nil)
                    observableMock = usecase.asObservableObject()
                }

                it("`UseCase` state will change to mock1 after test1 command is dispatched to `StateObject`") {
                    await waitUntil { end in
                        usecase.sink(ignoreFirst: true) { expect($0) == .mock1; end() }
                        observableMock.dispatch(.test1)
                    }
                }

                it("`UseCase` state will change to mock2 after test2 command is dispatched to `StateObject`") {
                    await waitUntil { end in
                        usecase.sink(ignoreFirst: true) { expect($0) == .mock2; end() }
                        observableMock.dispatch(.test2)
                    }
                }

            }
        }
    }
}
