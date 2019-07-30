// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

extension Set {
    /// Inserts an array
    ///
    /// - Parameters:
    /// -   newMembers: List of new elements to insert
    public mutating func insert(_ newMembers: [Set.Element]) {
        newMembers.forEach { self.insert($0) }
    }
}
