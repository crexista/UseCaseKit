//
// Copyright © 2020 @crexista. All rights reserved.
//

import Foundation
import UseCaseKit

enum MockCommand: Command {
    typealias State = MockState
    case test1
    case test2
}
