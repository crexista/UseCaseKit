//
// Copyright © 2020 @crexista. All rights reserved.
//

import Foundation

class DefaultTerminatable: Terminatable {
    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    func terminate() {
        closure()
    }
}
