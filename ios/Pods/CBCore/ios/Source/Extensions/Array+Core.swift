// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

extension Array {
    /// Split current array into an array of arrays based on given size
    ///
    /// - Parameters:
    ///     - size: Size of chunked array
    ///
    /// - Return: An array containing group of array
    public func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map { Array(self[$0 ..< Swift.min($0 + size, count)]) }
    }

    /// Helper to determine whether array is not empty
    public var isNotEmpty: Bool {
        return !isEmpty
    }
}

extension Array where Element: Hashable {
    /// Returns a uniqued array
    public var uniqued: [Element] {
        let set = Set<Element>(self)

        return [Element](set)
    }
}

extension Array: JSONSerializable where Element: Codable & JSONSerializable {}
