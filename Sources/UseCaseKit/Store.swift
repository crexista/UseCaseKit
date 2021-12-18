//
// Copyright © 2020 @crexista. All rights reserved.
//

import Foundation

public class Store<State: Equatable> {

    typealias SubscriberKey = Int

    private let queue: DispatchQueue = .init(label: "st.crexi.UseCaseKit.Store")
    private var state: State
    private var subscribers: [SubscriberKey: (State) -> Void] = [:]
    private var currentKey: SubscriberKey = 0

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
        queue.async {
            let originalState = self.state
            var newState = self.state
            updater(&newState)
            if transient {
                self.state = newState
                self.subscribers.values.forEach { $0(newState) }
                self.state = originalState
                self.subscribers.values.forEach { $0(originalState) }
            } else {
                self.state = newState
                self.subscribers.values.forEach { $0(newState) }
            }
        }
    }

    @discardableResult
    func addSubscriber(_ subscriber: @escaping (State) -> Void) -> Terminatable {
        return queue.sync {
            let key = currentKey
            self.subscribers[key] = subscriber
            queue.async { self.subscribers[key]?(self.state) }
            currentKey += 1

            return DefaultTerminatable { [weak self] in
                self?.removeSubscriber(of: key)
            }
        }
    }

    func removeSubscriber(of key: SubscriberKey) {
        queue.async {
            self.subscribers.removeValue(forKey: key)
        }
    }

}
