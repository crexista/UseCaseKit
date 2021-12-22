//
// Copyright © 2020 @crexista. All rights reserved.
//

import Foundation

public protocol Command {
    associatedtype State: Equatable
}

public class UseCase<CommandType: Command> {

    private let store: Store<CommandType.State>
    private var terminatables: [Terminatable] = []
    private let handler: Handler

    init(handler: Handler, store: Store<CommandType.State>) {
        self.handler = handler
        self.store = store
    }

    var state: CommandType.State {
        store.currentState
    }

    @discardableResult
    public func sink(on queue: DispatchQueue, receiver: @escaping (CommandType.State) -> Void) -> Terminatable {
        let newReceiver: (CommandType.State) -> Void = { state in
            queue.async { receiver(state) }
        }
        let terminatable = store.addSubscriber(newReceiver)
        terminatables.append(terminatable)
        return terminatable
    }

    public func dispatch(_ command: CommandType) {
        handler.commandReceiver?(command)
    }

    deinit {
        handler.deinitListener?()
        terminatables.forEach { $0.terminate() }
    }

}

public extension UseCase {

    class Handler {
        let commandReceiver: ((CommandType) -> Void)?
        let deinitListener: (() -> Void)?

        private init(commandReceiver: ((CommandType) -> Void)?, deinitListener: (() -> Void)?) {
            self.commandReceiver = commandReceiver
            self.deinitListener = deinitListener
        }

        /// Generate `Handler` with command handler and deinit handler
        ///
        /// - Parameters:
        ///   - commandHandler: A closure that is called when command is dispatched to `UseCase`.
        ///   - deinitListener: A closure that is called when `UseCase` deinit.
        /// - Returns: `Handler`
        static public func onReceive(with commandReceiver: ((CommandType) -> Void)?,
                                     onDeinit deinitListener: (() -> Void)? = nil) -> Handler {
            return Handler(commandReceiver: commandReceiver, deinitListener: deinitListener)
        }

        /// Generate `Handler` that do nothing.
        ///
        /// - Returns: A `Handler` that do nothing
        static public func empty() -> Handler {
            return Handler(commandReceiver: nil, deinitListener: nil)
        }
    }

    /// Instantiates a `UseCase`
    ///
    /// - Parameters:
    ///   - state: Initial state of Store
    ///   - interaction: A closure that interacts store when usecase received command, is released instance etc.
    convenience init(_ state: CommandType.State, interaction: (Store<CommandType.State>) -> Handler) {
        let store = Store(state: state)
        let handler = interaction(store)
        self.init(handler: handler, store: store)
    }
}

@available(iOS 13.0, *)
extension UseCase {

    /// Convert to StateObject from UseCase
    /// - Returns: StateObject
    func asStateObject() -> StateObject<CommandType> {
        StateObject(usecase: self)
    }
}
