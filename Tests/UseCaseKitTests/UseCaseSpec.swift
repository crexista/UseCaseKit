//
// Copyright © 2020 @crexista. All rights reserved.
//

@testable import UseCaseKit
import Quick
import Nimble

class UseCaseSpec: QuickSpec {

    override func spec() {
        var usecase: UseCase<MockCommand>!

        describe("UseCase") {

            beforeEach {
                usecase = .store(.initial) { store in
                    return {
                        switch $0 {
                        case .test1: store.update { $0 = .mock1 }
                        case .test2: store.update { $0 = .mock2 }
                        }
                    }
                }
            }

            context("if UseCase doesn't receive command") {
                it("returns current state to subscribing closure") {
                    waitUntil { end in
                        _ = usecase.sink(on: .main) { expect($0) == .initial; end() }
                    }
                }
            }

            context("if UseCase receive test1 command") {
                it("returns mock1 state to subscribing closure") {
                    waitUntil { end in
                        usecase.dispatcher.dispatch(.test1)
                        _ = usecase.sink(on: .main) { expect($0) == .mock1; end() }
                    }
                }
            }

            context("if UseCase receive test2 command") {
                it("returns mock2 state to subscribing closure") {
                    waitUntil { end in
                        usecase.dispatcher.dispatch(.test2)
                        _ = usecase.sink(on: .main) { expect($0) == .mock2; end() }
                    }
                }
            }

        }
    }
}
