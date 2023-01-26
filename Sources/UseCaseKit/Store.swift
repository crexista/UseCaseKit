//
// Copyright © 2020 @crexista. All rights reserved.
//

import Foundation

/// `Store` save a state, and notify that state when that state is updated.
///
public class Store<State: Equatable> {

    private typealias Listener = (State) -> Void

    private let queue: DispatchQueue = .init(label: "st.crexi.UseCaseKit.Store")
    private var state: State
    private var listener: Listener?

    /// This property returns current state that `Store` has.
    ///
    /// - Attention: This property is computed property and called in serial queue for thread-safe,
    ///              So this property will be called in update closure, it causes crash.
    public var currentState: State {
        return queue.sync { state }
    }

    public init(state: State) {
        self.state = state
    }

    /// This method updates Store's state with updater closure.
    ///
    /// - Parameters:
    ///   - transient: A Boolean value that the update is transient either or not.
    ///   - updater: A closure that update state. This closure is thread safe.
    public func update(transient: Bool = false, updater: @escaping (inout State) -> Void) {
        queue.async { [weak self] in
            guard let self = self else { return }
            var newState = self.state
            updater(&newState)
            self.state = transient ? self.state : newState
            self.listener?(newState)
        }
    }

    func set(stateListener: @escaping (State) -> Void) {
        queue.sync { [weak self] in
            self?.listener = stateListener
        }
    }

    func removeListener() {
        queue.async { [weak self] in
            self?.listener = nil
        }
    }
}
