//
// Copyright © 2020 @crexista. All rights reserved.
//

import Foundation

class DefaultTerminatable: Terminatable {

    private var closure: () -> Void

    var isTerminated: Bool = false

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    func terminate() {
        closure()
        isTerminated = true
        closure = {}
    }
}
