//
// Copyright © 2020 @crexista. All rights reserved.
//

import Foundation

public protocol Terminatable {

    var isTerminated: Bool { get }
    /// This method stop to subscribe state updating.
    func terminate()
}
