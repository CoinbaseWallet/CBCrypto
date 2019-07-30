// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

/// A simple thread-safe cache.
public final class ConcurrentCache<K: Hashable, V> {
    private let accessQueue = DispatchQueue(label: "WalletLink.ConcurrentCache", attributes: .concurrent)
    private var cache = [K: V]()

    /// Number of entries in cache
    public var count: Int {
        return cache.count
    }

    public required init() {}

    /// Subscript setter/getter
    public subscript(_ key: K) -> V? {
        get { return accessQueue.syncGet { cache[key] } }
        set { accessQueue.sync(flags: .barrier) { cache[key] = newValue } }
    }

    // Remove all entries
    public func removeAll() {
        accessQueue.sync(flags: .barrier) { cache.removeAll() }
    }

    /// Helper to check if cache contains the given key
    public func has(_ key: K) -> Bool {
        return self[key] != nil
    }

    // Get values
    public var values: Dictionary<K, V>.Values {
        return accessQueue.syncGet { cache.values }
    }
}
