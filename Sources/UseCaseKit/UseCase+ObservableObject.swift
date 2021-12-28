//
// Copyright © 2021 @crexista. All rights reserved.
//

import Foundation
import Combine

@available(iOS 13.0, *)
public extension UseCase {

    class ObservableObject: Combine.ObservableObject {

        @Published public private(set) var state: CommandType.State

        private let usecase: UseCase<CommandType>

        init(usecase: UseCase<CommandType>) {
            self.usecase = usecase
            self.state = usecase.state
            usecase.sink(on: .main) { [weak self] in self?.state = $0 }
        }

        public func dispatch(_ command: CommandType) {
            usecase.dispatch(command)
        }
    }

    /// Converts `self` to `UseCase.ObservableObject`.
    /// - Returns: A `UseCase.ObservableObject` that represents `self`.
    func asObservableObject() -> ObservableObject {
        ObservableUseCase(usecase: self)
    }
}

@available(iOS 13.0, *)
public typealias ObservableUseCase<CommandType: Command> = UseCase<CommandType>.ObservableObject

@available(iOS 13.0, *)
public extension ObservableUseCase {

    convenience init(_ state: CommandType.State, interaction: (Store<CommandType.State>) -> UseCase<CommandType>.Handler) {
        self.init(usecase: UseCase(state, interaction: interaction))
    }
}
