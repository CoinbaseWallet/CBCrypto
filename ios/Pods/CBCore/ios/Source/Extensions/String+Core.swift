// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import BigInt
import os.log

private let hexadecimalCharacters = "0123456789abcdef"

extension String {
    /// Represents an empty string
    public static let empty = ""

    /// An ellipsis character, used as a placeholder for labels and other UI elements
    public static let ellipsis = "…"

    /// Decimal digit zero
    public static let zero = "0"

    /// Represents a space string
    public static let space = " "

    /// Represents a period
    public static let period = "."

    /// Convert string to BigInt if possible
    public var asBigInt: BigInt? {
        return BigInt.fromScientificNotation(string: self)
    }

    /// Convert string to hex representation
    public var asHexString: String {
        let data = Data(utf8)
        return data.map { String(format: "%02x", $0) }.joined()
    }

    /// Convert string to boolean if possible
    public var asBool: Bool? {
        switch lowercased() {
        case "false", "0":
            return false
        case "true", "1":
            return true
        default:
            return nil
        }
    }

    /// Determine whether string is a numeric scientific notation
    public var isNumericScientificNotation: Bool {
        let pattern = "^[\\-]{0,1}\\d+(\\.\\d+)*e\\d+$"

        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return false }

        return !regex.matches(in: self, options: [], range: NSRange(location: 0, length: count)).isEmpty
    }

    /// Convert optional string to URL if possible
    public var asURL: URL? {
        return URL(string: self)
    }

    /// A new string made by deleting the extension (if any, and only the last) from the receiver.
    public var deletingPathExtension: String {
        return (self as NSString).deletingPathExtension
    }

    /// The last path component of the receiver.
    public var lastPathComponent: String {
        return (self as NSString).lastPathComponent
    }

    /// Determine whether string is a valid hex string
    public var isHexString: Bool {
        guard let regex = try? NSRegularExpression(pattern: "^(0x|0X)?[a-f0-9]*$", options: [.caseInsensitive]) else {
            return false
        }

        let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: count)).compactMap { $0 }

        return !matches.isEmpty
    }

    /// Convert to hex Data if possible
    public var asHexEncodedData: Data? {
        let strippedLowerStr = strip0x().lowercased()
        let str = strippedLowerStr.count % 2 == 0 ? strippedLowerStr : "0" + strippedLowerStr

        let length = str.count / 2
        var bytes = [UInt8](repeating: 0, count: length)

        for i in 0 ..< length {
            let hexLeft = str[str.index(str.startIndex, offsetBy: i * 2)]
            let hexRight = str[str.index(str.startIndex, offsetBy: i * 2 + 1)]
            guard let idxLeft = hexadecimalCharacters.index(of: hexLeft) else {
                return nil
            }
            guard let idxRight = hexadecimalCharacters.index(of: hexRight) else {
                return nil
            }
            let valLeft = hexadecimalCharacters.distance(from: hexadecimalCharacters.startIndex, to: idxLeft)
            let valRight = hexadecimalCharacters.distance(from: hexadecimalCharacters.startIndex, to: idxRight)
            bytes[i] = UInt8(valLeft * 16 + valRight)
        }
        return Data(bytes: bytes)
    }

    /// Convert to JSON object if possible
    public var jsonObject: Any? {
        do {
            guard let data = self.data(using: .utf8) else { return nil }
            return try JSONSerialization.jsonObject(with: data, options: [])
        } catch let e {
            print("exception: \(e)")
            return nil
        }
    }

    public var containsANumber: Bool {
        return !matches(regex: "(\\d+)").isEmpty
    }

    public var containsANonNumber: Bool {
        return !matches(regex: "(\\D+)").isEmpty
    }

    /// Converts a StaticString to a String
    ///
    /// - Parameters:
    ///     - staticString: a string of type StaticString
    ///
    /// - Returns: a string representation of the object
    public init(_ staticString: StaticString) {
        self = staticString.withUTF8Buffer {
            String(decoding: $0, as: UTF8.self)
        }
    }

    /// Strip out "0x" prefix if one exists. Otherwise, no-op
    public func strip0x() -> String {
        return starts(with: "0x") ? String(self[index(startIndex, offsetBy: 2)...]) : self
    }

    /// Search and replace all occurrences matching given regex pattern
    ///
    /// - Parameters:
    ///     - regex: Regular expression pattern
    ///     - template: Replacement text/template
    ///     - options: Regex options. Such as case sensitive
    ///
    /// - Returns: Updated replaced text
    public func replace(regex pattern: String, template: String, options: NSRegularExpression.Options = []) -> String {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return self }

        let range = NSRange(location: 0, length: count)

        return regex.stringByReplacingMatches(in: self, options: [], range: range, withTemplate: template)
    }

    /// Finds all matches using given regex pattern
    ///
    /// - Parameters:
    ///     - regex: Regular expression pattern
    ///
    /// - Returns: A list of matches
    public func matches(regex pattern: String) -> [String?] {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return [] }

        return regex.matches(in: self, options: [], range: NSRange(location: 0, length: count))
            .flatMap { match -> [String?] in
                var results = [String?]()
                for i in 1 ..< match.numberOfRanges {
                    let nsRange = match.range(at: i)

                    if nsRange.location == NSNotFound {
                        results.append(nil)
                        continue
                    }

                    if nsRange.length == 0 {
                        results.append("")
                        continue
                    }

                    guard
                        nsRange.location + nsRange.length <= self.count,
                        let matchedSubstring = substring(nsRange: nsRange)
                    else {
                        continue
                    }

                    results.append(String(matchedSubstring))
                }

                return results
            }
    }

    /// Reverse a string and return a `String` object. Swift's reversed() converts the `String`
    /// to `ReversedCollection<String>`
    public func reversedString() -> String {
        return String(reversed())
    }

    /// Substring using NSRange
    ///
    /// - Parameters:
    ///     - nsRange: NSRange used in the substring operation
    ///
    /// - Returns: The result Substring
    public func substring(nsRange: NSRange) -> Substring? {
        guard let range = nsRange.range(on: self as NSString) else { return nil }

        return self[range]
    }

    public func firstMatch(pattern: String) -> NSTextCheckingResult? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else { return nil }
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count))
    }
}

extension Optional where Wrapped == String {
    public var asBigInt: BigInt? {
        guard let value = self else { return nil }

        return value.asBigInt
    }

    /// Convert optional string to URL if possible
    public var asURL: URL? {
        guard let self = self else { return nil }
        return URL(string: self)
    }

    /// Convert optional string to Int if possible
    public var asInt: Int? {
        guard let self = self else { return nil }
        return Int(self)
    }

    /// Determine if optional string is empty or nil
    public var isEmpty: Bool {
        guard let val = self else { return true }

        return val.isEmpty
    }
}
