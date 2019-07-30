// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import BigInt

extension BigInt {
    /// Optionally returns a BigInt from a given hex string.
    ///
    /// - Parameter hex: a hexidecimal string.
    public init?(hex: String?) {
        guard let hex = hex else { return nil }

        self.init(hex.hasPrefix("0x") ? String(hex.dropFirst(2)) : hex, radix: 16)
    }

    /// Constructor to convert string to BigInt with added scientific notation parsing support i.e. 3.3e18
    ///
    /// - Parameters:
    ///     - string: Numeric string used to create an instance of BigInt
    ///
    /// - Returns: A new instance of `BigInt` representing the string or nil if unable to parse string
    public static func fromScientificNotation(string: String) -> BigInt? {
        if let value = BigInt(string) {
            return value
        }

        let matches = string.matches(regex: "^([\\-]?)(\\d+)(\\.{0,1}(\\d+))?e{1}(\\d+)$")

        guard
            matches.count == 5,
            let lhsOfDecimal = matches[1]?.replace(regex: "^0+", template: ""),
            let numberOfDecimalsString = matches[4],
            let numberOfDecimals = Int(numberOfDecimalsString)
        else {
            return nil
        }

        let rhsOfDecimal = matches[3]?.replace(regex: "0+$", template: "") ?? ""

        guard numberOfDecimals > rhsOfDecimal.count, let number = BigInt(lhsOfDecimal + rhsOfDecimal) else {
            return nil
        }

        let isNegative = matches[0] == "-"
        let decimalsToMove = numberOfDecimals - rhsOfDecimal.count
        let bigIntValue = number * BigInt(10).power(decimalsToMove) * (isNegative ? BigInt(-1) : BigInt(1))

        return BigInt(bigIntValue)
    }
}
