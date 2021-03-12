//
// Copyright © 2020 @crexista. All rights reserved.
//

import Foundation

/// This class emits updated state
public class StateSource<State: Equatable> {

    private let publisher: (@escaping (State) -> Void) -> Terminatable

    init(subscribable: @escaping (@escaping (State) -> Void) -> Terminatable) {
        self.publisher = subscribable
    }

    func addSubscriber(subscriber: @escaping (State) -> Void) -> Terminatable {
        return publisher(subscriber)
    }

    deinit {
        print("State Adapter deinit")
    }
}

extension StateSource {

    convenience init(store: Store<State>) {
        self.init(subscribable: { [weak store] in
            if let key = store?.addSubscriber($0) {
                return DefaultTerminatable { store?.removeSubscriber(of: key) }
            } else {
                return DefaultTerminatable(closure: {})
            }
        })
    }
}

extension StateSource {

    func map<T: Equatable>(converter: @escaping (State) -> T) -> StateSource<T> {
        return .init { receiver -> Terminatable in
            return self.addSubscriber { receiver(converter($0)) }
        }
    }

}
