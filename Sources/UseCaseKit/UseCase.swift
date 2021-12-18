//
// Copyright © 2020 @crexista. All rights reserved.
//

import Foundation

public protocol Command {
    associatedtype State: Equatable
}

public class UseCase<CommandType: Command> {

    public let dispatcher: Dispatcher<CommandType>
    private let store: Store<CommandType.State>
    private var terminatables: [Terminatable] = []

    init(dispatcher: Dispatcher<CommandType>, store: Store<CommandType.State>) {
        self.dispatcher = dispatcher
        self.store = store
    }

    public func sink(on queue: DispatchQueue, receiver: @escaping (CommandType.State) -> Void) -> Terminatable {
        let newReceiver: (CommandType.State) -> Void = { state in
            queue.async { receiver(state) }
        }
        let terminatable = store.addSubscriber(newReceiver)
        terminatables.append(terminatable)
        return terminatable
    }

    deinit {
        terminatables.forEach { $0.terminate() }
    }

}
