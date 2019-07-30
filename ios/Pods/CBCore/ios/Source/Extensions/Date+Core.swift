// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

extension Date {
    /// Initializes a Date from a unix timestamp string
    ///
    /// - Parameter unixTimestamp: The unix timestamp string
    public init?(unixTimestamp: String) {
        guard let timeInterval = TimeInterval(unixTimestamp) else { return nil }

        self.init(timeIntervalSince1970: timeInterval)
    }

    private static var rcf3339DateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

        return dateFormatter
    }

    /// An RCF3339 formatted String of the date
    public var rcf3339: String {
        return Date.rcf3339DateFormatter.string(from: self)
    }

    /// A date generated from an RCF3339 formatted String
    public static func rcf3339Date(with rcf3339: String) -> Date? {
        return rcf3339DateFormatter.date(from: rcf3339)
    }
}
