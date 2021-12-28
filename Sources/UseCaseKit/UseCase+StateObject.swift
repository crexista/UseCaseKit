// 
// Copyright © 2021 @crexista. All rights reserved.
//

import Foundation

@available(iOS 13.0, *)
public extension UseCase {

    /// Converts `self` to `StateObject`.
    /// - Returns: A `StateObject` that represents `self`.
    func asStateObject() -> StateObject<CommandType> {
        StateObject(usecase: self)
    }
}
