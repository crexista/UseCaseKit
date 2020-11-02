//
//  Copyright © 2020 crexista. All rights reserved.
//

import Foundation
import UseCaseKit

extension UseCase {
    
    static func stopWatch() -> UseCase<StopWatchCommand> {
        return  .store(.stopped) { store in
            var timer: Timer?
            
            return {
                switch $0 {
                case .stop:
                    timer?.invalidate()
                    store.update { $0 = .pause($0.count) }

                case .start:
                    timer?.invalidate()
                    store.update { $0 = .counting($0.count) }
                    timer = .scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                        store.update { $0 = .counting($0.count + 1) }
                    }

                case .reset:
                    guard case .pause = store.currentState else { return }
                    timer?.invalidate()
                    store.update { $0 = .stopped }
                }
            }
        }
    }

}
