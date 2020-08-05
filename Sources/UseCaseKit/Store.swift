//
// Copyright © 2020 @crexista. All rights reserved.
//

import Foundation

public class Store<State: Equatable> {

    private class Container {
        var state: State

        init(state: State) {
            self.state = state
        }
    }

    private let queue: DispatchQueue = .init(label: "st.crexi.UseCaseKit.Store")
    private let container: Container

    let stateRelay: StateRelay<State>

    public var currentState: State {
        return queue.sync { container.state }
    }

    public init(state: State) {
        let container = Container(state: state)
        stateRelay = .init(on: queue) { $0(container.state) }
        self.container = container
    }

    /// This method updates Store's state with updater closure.
    ///
    /// - Parameters:
    ///   - transient: A Boolean value that the update is transient either or not.
    ///   - updater: A closure that update state. This closure is thread safe.
    public func update(transient: Bool = false, updater: @escaping (inout State) -> Void) {
        queue.async {
            var state = self.container.state
            updater(&state)
            if transient {
                self.stateRelay.publish(state)
                self.stateRelay.publish(self.container.state)
            } else {
                self.container.state = state
                self.stateRelay.publish(state)
            }
        }
    }

}
