// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

/// Thread safe atomic integer
public struct AtomicInt32 {
    private var value: Int32
    private let accessQueue = DispatchQueue(label: "AtomicInt32.accessQueue")

    public init(_ value: Int32 = 0) {
        self.value = value
    }

    /// Safe concurrent get
    public func get() -> Int32 {
        var val: Int32!

        accessQueue.sync {
            val = self.value
        }

        return val
    }

    /// Atomically increment the backed integer and return the value
    public mutating func incrementAndGet() -> Int32 {
        var val: Int32!

        accessQueue.sync(flags: .barrier) {
            self.value += 1
            val = self.value
        }

        return val
    }

    /// Atomically increment the backed integer
    public mutating func increment() {
        accessQueue.sync(flags: .barrier) {
            self.value += 1
        }
    }
}
