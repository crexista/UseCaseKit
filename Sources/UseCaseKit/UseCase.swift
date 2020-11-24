//
// Copyright © 2020 @crexista. All rights reserved.
//

import Foundation

public protocol Command {
    associatedtype State: Equatable
}

public class UseCase<CommandType: Command> {

    public let dispatcher: Dispatcher<CommandType>
    private let source: StateSource<CommandType.State>
    private var terminatables: [Terminatable] = []

    init(dispatcher: Dispatcher<CommandType>, source: StateSource<CommandType.State>) {
        self.dispatcher = dispatcher
        self.source = source
    }

    public func sink(on queue: DispatchQueue, receiver: @escaping (CommandType.State) -> Void) -> Terminatable {
        let newReceiver: (CommandType.State) -> Void = { state in
            queue.async { receiver(state) }
        }
        let terminatable = source.addSubscriber(subscriber: newReceiver)
        terminatables.append(terminatable)
        return terminatable
    }

    deinit {
        terminatables.forEach { $0.terminate() }
    }

}
