//
// Copyright © 2020 @crexista. All rights reserved.
//

import Foundation

/// A Relay that relays event that is occurred by state updating
public class StateRelay<State: Equatable> {

    public typealias Subscriber<T> = (T) -> Void

    private var observers: [Subscriber<State>] = []
    private var source: (@escaping Subscriber<State>) -> Void

    let queue: DispatchQueue

    init(on queue: DispatchQueue, handler: @escaping (@escaping Subscriber<State>) -> Void) {
        self.queue = queue
        source = handler
    }

    func publish(_ state: State) {
        self.observers.forEach { $0(state) }
    }

    func subscribe(receiver: @escaping Subscriber<State>) {
        observers.append(receiver)
        source { state in
            self.observers.forEach { $0(state) }
        }
    }

    /// This method register `receiver` that is called
    /// when the target that this is observing updates state.
    ///
    /// - Parameter receiver: This closure will be called when observing target's state
    ///                       is updating.
    public func sink(receiver: @escaping Subscriber<State>) {
        queue.async {
            self.subscribe(receiver: receiver)
        }
    }

    public func sink(on sinkQueue: DispatchQueue, receiver: @escaping Subscriber<State>) {
        let newReceiver: (State) -> Void = { state in
            sinkQueue.async { receiver(state) }
        }
        sink(receiver: newReceiver)
    }
}
