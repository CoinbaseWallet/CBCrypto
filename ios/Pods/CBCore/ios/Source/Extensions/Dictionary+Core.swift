// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

/// Adds one dictionary to another
/// - Parameters:
///     - left:  Source dictionary
///     - right: Overriding dictionary
///
/// - Returns: A new dictionary combining left and right dictionary
public func + <K, V>(left: [K: V], right: [K: V]) -> [K: V] {
    var map = left
    right.forEach { map[$0] = $1 }
    return map
}
