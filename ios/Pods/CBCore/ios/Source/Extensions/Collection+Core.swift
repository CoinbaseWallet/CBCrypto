// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

extension Collection where Index == Int {
    /// Get element at given index. If index is out of bounds, return nil
    ///
    /// - Parameter index: Index of element to fetch
    ///
    /// - Returns: Element at given index
    public subscript(safe index: Int) -> Iterator.Element? {
        return index >= count || index < 0 ? nil : self[index]
    }
}
