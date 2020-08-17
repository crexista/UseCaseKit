//
// Copyright © 2020 @crexista. All rights reserved.
//

import Foundation

public protocol Command {
    associatedtype State: Equatable
}

public class UseCase<CommandType: Command> {

    public let dispatcher: Dispatcher<CommandType>
    public let state: StateRelay<CommandType.State>

    init(dispatcher: Dispatcher<CommandType>, publisher: StateRelay<CommandType.State>) {
        self.dispatcher = dispatcher
        self.state = publisher
    }

    deinit {
        print("usecase deinit")
    }

}
