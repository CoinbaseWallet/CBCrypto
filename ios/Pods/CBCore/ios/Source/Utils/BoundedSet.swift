// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

/// A size bounded Set. Oldest keys will be evicted.
public final class BoundedSet<T: Hashable> {
    private var set = NSMutableOrderedSet()
    private let maxSize: Int

    /// Number of entries in set
    public var count: Int {
        return set.count
    }

    /// Default Constructor
    public required init(maxSize: Int) {
        self.maxSize = maxSize
    }

    /// Get whether entry exists
    ///
    /// - Parameter key: Check if item exists in the set
    ///
    /// - Returns: True if has item
    public func has(_ item: T) -> Bool {
        return set.contains(item)
    }

    /// Add item to the set
    ///
    /// - Parameter item: Item to add to the set
    public func add(_ item: T) {
        if has(item) {
            set.remove(item)
        }

        set.add(item)

        while set.count > maxSize, set.isNotEmpty {
            set.removeObject(at: 0)
        }
    }
}
