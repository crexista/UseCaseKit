//
// Copyright © 2021 @crexista. All rights reserved.
//

@testable import UseCaseKit
import Quick
import Nimble
import XCTest

@available(iOS 13.0, *)
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
                    waitUntil { end in
                        usecase.dispatch(.test1)
                        _ = usecase.state
                        DispatchQueue.main.async { expect(observableMock.state) == .mock1; end() }
                    }
                }

                it("`StateObject`'s state will change to mock2 after test2 command is dispatched to `UseCase`") {
                    waitUntil { end in
                        usecase.dispatch(.test2)
                        _ = usecase.state
                        DispatchQueue.main.async { expect(observableMock.state) == .mock2; end() }
                    }
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
                    waitUntil { end in
                        usecase.sink(ignoreFirst: true) { expect($0) == .mock1; end() }
                        observableMock.dispatch(.test1)
                    }
                }

                it("`UseCase` state will change to mock2 after test2 command is dispatched to `StateObject`") {
                    waitUntil { end in
                        usecase.sink(ignoreFirst: true) { expect($0) == .mock2; end() }
                        observableMock.dispatch(.test2)
                    }
                }

            }
        }
    }
}
