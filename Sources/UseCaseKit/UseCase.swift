//
// Copyright © 2020 @crexista. All rights reserved.
//

import Foundation

public protocol Command {
    associatedtype State: Equatable
}

public class UseCase<CommandType: Command> {

    private typealias SubscribingKey = Int

    public typealias Receiver = (CommandType.State) -> Void

    private let queue: DispatchQueue = .init(label: "st.crexi.UseCaseKit.UseCase")
    private let store: Store<CommandType.State>
    private var terminatables: [Terminatable] = []
    private let handler: Handler
    private var subscribers: [SubscribingKey: Receiver] = [:]
    private var key: SubscribingKey = 0

    init(handler: Handler, store: Store<CommandType.State>) {
        self.handler = handler
        self.store = store
        store.set { [weak self] in self?.publish($0) }
    }

    var state: CommandType.State {
        store.currentState
    }

    var subscribersCount: Int {
        queue.sync {
            subscribers.values.count
        }
    }

    @discardableResult
    public func sink(on queue: DispatchQueue, receiver: @escaping Receiver) -> Terminatable {
        let newReceiver: (CommandType.State) -> Void = { state in
            queue.async { receiver(state) }
        }
        return sink(receiver: newReceiver)
    }

    func sink(receiver: @escaping (CommandType.State) -> Void) -> Terminatable {
        queue.sync {
            let newKey = key + 1
            subscribers[newKey] = receiver
            let terminable = DefaultTerminatable { [weak self] in self?.subscribers.removeValue(forKey: newKey) }
            key = newKey
            terminatables.append(terminable)
            receiver(store.currentState)
            return terminable
        }
    }

    func adapt<NewCommand: Command>(_ commandType: NewCommand.Type,
                                    receptor: ((NewCommand) -> FilterResult<CommandType>)? = nil,
                                    reducer: @escaping (CommandType.State) -> FilterResult<NewCommand.State>,
                                    with initializer: @escaping (CommandType.State) -> NewCommand.State) -> UseCase<NewCommand> {

        return .init(initializer(state)) { store in
            let terminatable = self.sink {
                guard case let .relay(state) = reducer($0) else { return }
                store.update { $0 = state }
            }

            return .onReceive {
                guard case let .relay(command) = receptor?($0) else { return }
                self.dispatch(command)
            } onDeinit: {
                terminatable.terminate()
            }
        }
    }

    private func publish(_ state: CommandType.State) {
        queue.async { [weak self] in
            self?.subscribers.values.forEach { $0(state) }
        }
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

        fileprivate init(commandReceiver: ((CommandType) -> Void)?, deinitListener: (() -> Void)?) {
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

public extension UseCase {

    enum FilterResult<T> {
        case relay(T)
        case discard
    }

    struct Adaptor<NewCommand: Command> {
        let source: UseCase<CommandType>
        let inputConverter: (NewCommand) -> FilterResult<CommandType>
        let outputConverter: (CommandType.State) -> FilterResult<NewCommand.State>
    }

    func adapt<NewCommand: Command>(_ commandType: NewCommand.Type, converter: @escaping (NewCommand) -> FilterResult<CommandType>) -> Adaptor<NewCommand> {
        Adaptor(source: self, inputConverter: converter, outputConverter: { _ in .discard })
    }

}

extension UseCase.Adaptor {

    func asUseCase(with initializer: @escaping (CommandType.State) -> NewCommand.State) -> UseCase<NewCommand> {
        source.adapt(NewCommand.self,
                     receptor: inputConverter,
                     reducer: outputConverter,
                     with: initializer)
    }
}

public extension UseCase.Adaptor {

    func converting(onStateUpdate converter: @escaping (CommandType.State) -> NewCommand.State) -> UseCase<NewCommand> {
        let adaptor = UseCase.Adaptor<NewCommand>(source: source, inputConverter: inputConverter, outputConverter: { .relay(converter($0)) })
        return adaptor.asUseCase(with: converter)
    }

}
