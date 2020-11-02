//
//  Copyright © 2020 crexista. All rights reserved.
//

import Foundation
import UseCaseKit

enum StopWatchCommand: Command {
    typealias State = StopWatchState
    case start
    case stop
    case reset
}
