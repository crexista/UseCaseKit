//
// Copyright © 2020 @crexista. All rights reserved.
//

import Foundation

public extension UseCase {

    typealias Handler = (CommandType) -> Void

    /// This method generate Simple UseCase
    /// - Parameters:
    ///   - state: A State that will be published by this UseCase
    ///   - configure: A closure that setup command handler
    /// - Returns: A UseCase that calles Handler that has been set by configurator when received command.
    static func store(_ state: CommandType.State,
                      configure: @escaping (Store<CommandType.State>) -> Handler) -> UseCase<CommandType> {
        let store = Store(state: state)
        let handler = configure(store)

        return UseCase<CommandType>(dispatcher: Dispatcher<CommandType> { handler($0) }, publisher: store.stateRelay)
    }

}
