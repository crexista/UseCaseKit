//
// Copyright © 2020 @crexista. All rights reserved.
//

@testable import UseCaseKit
import Quick
import Nimble

class UseCaseSpec: QuickSpec {

    override func spec() {
        var usecase: UseCase<MockCommand>?
        var deinitWaiter: XCTestExpectation!
        var sinkWaiter: XCTestExpectation!
        var terminatables: [Terminatable?] = []

        describe("UseCase") {

            beforeEach {
                terminatables = []
                deinitWaiter = self.expectation(description: "DeinitListener Waiter")
                sinkWaiter = self.expectation(description: "A Closure that subscriber is called")
                usecase = .test(deinitWaiter)
            }

            context("if UseCase doesn't receive command") {
                it("returns current state to subscribing closure") {
                    usecase?.sink(ignoreFirst: false) { expect($0) == .initial; sinkWaiter.fulfill() }
                    expect(XCTWaiter.wait(for: [sinkWaiter], timeout: 1.0, enforceOrder: true)) == .completed
                }
            }

            it("receiver received mock1 state after dispatch test1 command") {
                usecase?.sink(ignoreFirst: true) { expect($0) == .mock1; sinkWaiter.fulfill() }
                usecase?.dispatch(.test1)
                expect(XCTWaiter.wait(for: [sinkWaiter], timeout: 1.0, enforceOrder: true)) == .completed
            }

            it("receiver received mock2 state after dispatch test2 command") {
                usecase?.sink(ignoreFirst: true) { expect($0) == .mock2; sinkWaiter.fulfill() }
                usecase?.dispatch(.test2)
                expect(XCTWaiter.wait(for: [sinkWaiter], timeout: 1.0, enforceOrder: true)) == .completed
            }

            context("when usecase is deinited") {

                beforeEach {
                    terminatables = [usecase?.sink(on: .main) { _ in }, usecase?.sink(on: .main) { _ in }]
                    usecase = nil
                }

                it("deinitHandler will be called.") {
                    expect(XCTWaiter.wait(for: [deinitWaiter], timeout: 1.0, enforceOrder: true)) == .completed
                }

                it("all terminatable will be terminated that created when UseCase sinking") {
                    expect(terminatables[0]?.isTerminated) == true
                    expect(terminatables[1]?.isTerminated) == true
                }
            }

            context("when terminarable is terminated") {

                beforeEach {
                    let terminatable = usecase?.sink(ignoreFirst: true) { _ in sinkWaiter.fulfill() }
                    terminatable?.terminate()
                }

                it("receiver will not be called even if command dispatched") {
                    usecase?.dispatch(.test1)
                    expect(XCTWaiter.wait(for: [sinkWaiter], timeout: 1.0, enforceOrder: true)) == .timedOut
                }

                it("deinitHandler will not be called") {
                    expect(XCTWaiter.wait(for: [deinitWaiter], timeout: 1.0, enforceOrder: true)) == .timedOut
                }

                it("receiver will be called after sink") {
                    usecase?.sink(ignoreFirst: true) { expect($0) == .mock1; sinkWaiter.fulfill() }
                    usecase?.dispatch(.test1)
                    expect(XCTWaiter.wait(for: [sinkWaiter], timeout: 1.0, enforceOrder: true)) == .completed
                }
            }

        }
    }
}

extension UseCase where CommandType == MockCommand {

    static func test(_ deinitWaiter: XCTestExpectation?) -> UseCase {
        return .init(.initial) { store in
            return .onReceive {
                switch $0 {
                case .test1: store.update { $0 = .mock1 }
                case .test2: store.update { $0 = .mock2 }
                }
            } onDeinit: {
                deinitWaiter?.fulfill()
            }
        }
    }

    @discardableResult
    func sink(ignoreFirst: Bool, receiver: @escaping (MockState) -> Void) -> Terminatable {
        var isFirst = true && ignoreFirst
        return sink(on: .main) {
            guard !isFirst else { isFirst = false; return }
            receiver($0)
        }
    }

    func sink(with waiter: XCTestExpectation, receiver: @escaping (MockState) -> Void) -> Terminatable {
        self.sink(on: .main) {
            receiver($0)
            waiter.fulfill()
        }
    }
}
