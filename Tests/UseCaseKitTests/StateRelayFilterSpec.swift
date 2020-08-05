//
// Copyright © 2020 @crexista. All rights reserved.
//

import XCTest
@testable import UseCaseKit
import Quick
import Nimble

class StateRelayFilterSpec: QuickSpec {

    override func spec() {
        describe("StateRelay") {
            let convertStr = "Test"
            let mapFunc: (Int) -> String = { "\(convertStr) - \($0)" }
            let queue: DispatchQueue = .init(label: "st.crexi.UseCaseKit.StateRelayFilterSpec")
            context("if it has source callback") {
                let initialNum: Int = 1

                it("relays state when that state mathes condition") {
                    let stateRelay = StateRelay(on: queue) { subscriber in subscriber(initialNum) }
                    waitUntil { end in
                        stateRelay
                            .filter { $0 == initialNum }
                            .sink { _ in end() }
                    }
                }

                it("doesn't relays state when that state mathes condition") {
                    let stateRelay = StateRelay(on: queue) { subscriber in subscriber(initialNum) }
                    let exp = self.expectation(description: "Do not call")
                    stateRelay.filter { $0 != initialNum }.sink { _ in exp.fulfill() }
                    expect(XCTWaiter.wait(for: [exp], timeout: 1.0)) == .timedOut
                }
            }

            context("if it has empty source") {
                it("calles subscribing method") {
                    let stateRelay: StateRelay<Int> = StateRelay(on: queue) { _ in }
                    let exp = self.expectation(description: "Do not call")
                    stateRelay.map(mapFunc).sink { _ in  exp.fulfill() }
                    expect(XCTWaiter.wait(for: [exp], timeout: 1.0)) == .timedOut
                }

            }
        }
    }
}
