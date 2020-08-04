//
// Copyright © 2020 @crexista. All rights reserved.
//

import Foundation

public extension StateRelay {

    /// This method converts output state to `T`
    ///
    /// - Parameter transform: This closure convert state that is received from upstream.
    /// - Returns: A relay that uses the provided closure to map elements fron the upstream relay
    ///            to new elements that it then relays
    func map<T>(_ transform: @escaping (State) -> T) -> StateRelay<T> {
        return StateRelay<T>(on: queue) { handler in
            self.subscribe { handler(transform($0)) }
        }
    }

    /// This method relays only the state that matches the conditions which is provided by closure.
    ///
    /// - Parameter isIncluded: A closure that returns Boolean value whether state will be relayed or not.
    /// - Returns: A Relay that relays all elements that satisfy the closure.
    func filter(_ isIncluded: @escaping (State) -> Bool) -> StateRelay<State> {
        return StateRelay(on: queue) { handler in
            self.subscribe {
                guard isIncluded($0) else { return }
                handler($0)
            }
        }
    }

    /// This method relays only elements that don’t match the previous element.
    ///
    /// - Returns: A Relay that consumes — rather than relays — duplicate elements.
    func removeDuplicates() -> StateRelay<State> {
        return StateRelay(on: queue) { handler in
            var prev: State?
            self.subscribe {
                guard prev != $0 else { return }
                prev = $0
                handler($0)
            }
        }
    }
}
