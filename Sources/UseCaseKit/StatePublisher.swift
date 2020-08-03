//
// Copyright © 2020 @crexista. All rights reserved.
//

import Foundation

class StatePublisher<State: Equatable>: StateRelay<State> {
    private class Container {
        var state: State

        init(state: State) {
            self.state = state
        }
    }

    private var subscribers: [Subscriber<State>] = []
    private var container: Container

    var state: State { return container.state }

    init(state: State) {
        let container = Container(state: state)
        self.container = container
        super.init { $0(container.state) }
    }

    /// This method publish state and save
    ///
    /// - Parameter state: The state that is emitted to recivers via StateRelay
    func publish(_ state: State) {
        self.container.state = state
        subscribers.forEach { $0(state) }
    }

    override func sink(receiver: @escaping Subscriber<State>) {
        super.sink(receiver: receiver)
        subscribers.append(receiver)
    }

}
