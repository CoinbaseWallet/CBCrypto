// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

extension NSDecimalNumber {
    public var isNumber: Bool {
        return self != .notANumber
    }
}
