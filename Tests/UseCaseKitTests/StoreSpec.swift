//
// Copyright © 2020 @crexista. All rights reserved.
//

@testable import UseCaseKit
import Quick
import Nimble

class StoreSpec: QuickSpec {

    override func spec() {
        let initialState = "test1"
        let newState = "test2"
        var store = Store(state: initialState)
        var updatedState: String?

        describe("Store") {

            beforeEach {
                updatedState = nil
                store = Store(state: initialState)
            }

            it("returns initial state via currentState property") {
                expect(store.currentState) == initialState
            }

            context("after setting state listener") {
                beforeEach { store.set { updatedState = $0 } }

                it("updated state will not called") {
                    expect(updatedState).to(beNil())
                }

                context("when state is updated") {
                    beforeEach {
                        store.update { $0 = newState }
                    }

                    it("current state return new state") {
                        expect(store.currentState) == newState
                    }

                    it("new State is notified to listener") {
                        expect(updatedState) == newState
                    }
                }

                context("when state is updated as trancient") {
                    beforeEach {
                        store.update(transient: true) { $0 = newState }
                    }

                    it("current state is not changed") {
                        expect(store.currentState) == initialState
                    }

                    it("new State is notified to listener") {
                        expect(updatedState) == newState
                    }
                }

            }

            context("when state is updated") {
                beforeEach {
                    store.update { $0 = newState }
                }

                it("current state return new state") {
                    expect(store.currentState) == newState
                }

                it("new State is not notified to listener") {
                    expect(updatedState).to(beNil())
                }

            }

        }
    }
}
