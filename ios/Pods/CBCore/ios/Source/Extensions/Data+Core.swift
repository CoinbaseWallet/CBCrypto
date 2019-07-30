// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation
import os.log

private let hexadecimalArray: [UInt8] = Array("0123456789abcdef".utf8)

extension Data {
    /// Convert to JSON dictionary if possible
    public var jsonDictionary: [String: Any]? {
        return jsonObject as? [String: Any]
    }

    /// Convert to JSON object if possible
    public var jsonObject: Any? {
        do {
            return try JSONSerialization.jsonObject(with: self, options: [])
        } catch {
            print("exception: \(error)")
            return nil
        }
    }

    /// Generate random `Data` based on given length
    ///
    /// - Parameter:
    ///     - numberOfBytes: Size of random `Data` object to generate
    ///
    /// - Returns: Randomized bytes with given size encapsulated in a `Data` object
    public static func randomBytes(_ numberOfBytes: Int) -> Data? {
        var randomBytes = [UInt8](repeating: 0, count: numberOfBytes)
        let status = SecRandomCopyBytes(kSecRandomDefault, randomBytes.count, &randomBytes)

        if status != errSecSuccess { return nil }

        return Data(randomBytes)
    }

    /// Convert to prefixed hex string
    public func toPrefixedHexString() -> String {
        if isEmpty {
            return "0x"
        }

        let startIndex = 2
        let outputLength = count * 2 + startIndex + 1

        return withUnsafeBytes { (ptr: UnsafePointer<UInt8>) -> String in
            let bytes = UnsafeBufferPointer<UInt8>(start: ptr, count: self.count)
            var output = [UInt8](repeating: 0, count: outputLength)
            output[0] = 48 // 0
            output[1] = 120 // x

            var i = startIndex
            for b in bytes {
                let left = Int(b / 16)
                let right = Int(b % 16)
                output[i] = hexadecimalArray[left]
                output[i + 1] = hexadecimalArray[right]
                i += 2
            }
            return String(cString: UnsafePointer(output))
        }
    }

    /// Get a subset data from the current data using the given range
    ///
    /// - Parameter range: Range of sub data
    ///
    /// - Returns: Sub-data
    public func subdata(in range: ClosedRange<Index>) -> Data {
        return subdata(in: range.lowerBound ..< range.upperBound + 1)
    }
}
