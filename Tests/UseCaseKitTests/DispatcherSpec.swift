//
// Copyright © 2020 @crexista. All rights reserved.
//

@testable import UseCaseKit
import Quick
import Nimble

class DispatcherSpec: QuickSpec {

    override func spec() {

        describe("Dispatcher") {
            it("calls handler that is set on init when dispatched") {
                waitUntil { end in
                    let dispatcher = Dispatcher<DispatchTestCommand> { _ in end() }
                    dispatcher.dispatch(.test1)
                }
            }

            context("if test1 command is dispathed") {
                it("can receive test1 command") {
                    waitUntil { end in
                        let dispatcher = Dispatcher<DispatchTestCommand> { expect($0) == .test1; end() }
                        dispatcher.dispatch(.test1)
                    }
                }
            }

            context("if test2 command is dispathed") {
                it("can receive test2 command") {
                    waitUntil { end in
                        let dispatcher = Dispatcher<DispatchTestCommand> { expect($0) == .test2; end() }
                        dispatcher.dispatch(.test2)
                    }
                }
            }

        }
    }
}

private enum DispatchTestCommand: Command {
    typealias State = String
    case test1
    case test2
}
