//
// Copyright © 2021 @crexista. All rights reserved.
//

import Foundation
import Combine

extension UseCase {

    class Subscription<S: Subscriber>: Combine.Subscription where S.Input == CommandType.State, S.Failure == Never {

        private let usecase: UseCase<CommandType>
        private var subscriber: S
        private var terminatable: Terminatable?

        init(usecase: UseCase<CommandType>, subscriber: S) {
            self.subscriber = subscriber
            self.usecase = usecase
        }

        func request(_ demand: Subscribers.Demand) {
            terminatable = usecase.sink { [subscriber] in
                _ = subscriber.receive($0)
            }
        }

        func cancel() {
            terminatable?.terminate()
        }

    }

    struct Publisher: Combine.Publisher {
        typealias Output = CommandType.State
        typealias Failure = Never

        private let usecase: UseCase<CommandType>

        init(usecase: UseCase<CommandType>) {
            self.usecase = usecase
        }

        func receive<S>(subscriber: S) where S: Subscriber, Never == S.Failure, CommandType.State == S.Input {
            let subscription = Subscription(usecase: usecase, subscriber: subscriber)
            subscriber.receive(subscription: subscription)
        }
    }

}

public extension UseCase {

    /// Make an AnyPublisher that is publishing `UseCase`'s state.
    ///
    /// - Returns: An `AnyPublisher` that is publishing `UseCase`'s state
    func asAnyPublisher() -> AnyPublisher<CommandType.State, Never> {
        return Publisher(usecase: self).eraseToAnyPublisher()
    }
}
