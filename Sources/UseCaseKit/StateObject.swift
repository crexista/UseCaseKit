//
// Copyright © 2021 @crexista. All rights reserved.
//

import Foundation

/// StateObject is state dispatch object for SwiftUI
@available(iOS 13.0, *)
public class StateObject<CommandType: Command>: ObservableObject {

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
