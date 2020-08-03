//
// Copyright © 2020 @crexista. All rights reserved.
//

import Foundation

/// A Relay that relays event that is occurred by state updating
public class StateRelay<State: Equatable> {

    public typealias Subscriber<T> = (T) -> Void
    private var source: (@escaping Subscriber<State>) -> Void

    init(handler: @escaping (@escaping Subscriber<State>) -> Void) {
        source = handler
    }

    /// This method register `receiver` that is called
    /// when the target that this is observing updates state.
    ///
    /// - Parameter receiver: This closure will be called when observing target's state
    ///                       is updating.
    public func sink(receiver: @escaping Subscriber<State>) {
        source(receiver)
    }

}
