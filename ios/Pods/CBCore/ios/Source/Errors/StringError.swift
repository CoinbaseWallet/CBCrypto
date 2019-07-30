// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

enum StringError: Error {
    /// Thrown when substring-ing with a range that's out of bounds
    case indexOutOfBounds
}
