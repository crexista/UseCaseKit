//
// Copyright © 2020 @crexista. All rights reserved.
//

import XCTest
@testable import UseCaseKit
import Quick
import Nimble

class StateRelayMapSpec: QuickSpec {

    override func spec() {
        describe("StateRelay") {
            let queue: DispatchQueue = .init(label: "st.crexi.UseCaseKit.StateRelayMapSpec")
            let convertStr = "Test"
            let mapFunc: (Int) -> String = { "\(convertStr) - \($0)" }

            context("if it has source callback") {
                let initialNum: Int = 1

                it("calles subscribing method") {
                    let stateRelay = StateRelay(on: queue) { subscriber in subscriber(initialNum) }
                    waitUntil { end in
                        stateRelay
                            .map(mapFunc)
                            .sink { _ in end() }
                    }
                }

                it("convert Int state to String") {
                    let stateRelay = StateRelay(on: queue) { subscriber in subscriber(initialNum) }
                    waitUntil { end in
                        stateRelay
                            .map(mapFunc)
                            .sink { expect($0) == mapFunc(initialNum); end() }
                    }
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
