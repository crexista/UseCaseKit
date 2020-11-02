//
//  Copyright © 2020 crexista. All rights reserved.
//

import Foundation

enum StopWatchState: Equatable {
    case pause(Int)
    case counting(Int)
    case stopped
    
    var count: Int {
        switch self {
        case let .counting(num): return num
        case let .pause(num): return num
        case .stopped: return 0
        }
    }
}
