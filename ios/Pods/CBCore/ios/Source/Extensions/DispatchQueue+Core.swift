// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

extension DispatchQueue {
    /// Helper closure to run closure and get the result atomically
    public func syncGet<T>(closure: (() -> T)) -> T {
        var value: T!

        sync { value = closure() }

        return value
    }

    public func asyncAfter(seconds: Double, execute block: @escaping () -> Void) {
        let delay = Double(Int64(seconds * Double(NSEC_PER_SEC)))
        let deadline: DispatchTime = DispatchTime.now() + delay / Double(NSEC_PER_SEC)
        asyncAfter(deadline: deadline, execute: block)
    }
}
