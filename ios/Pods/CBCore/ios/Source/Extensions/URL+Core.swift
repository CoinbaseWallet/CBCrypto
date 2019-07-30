// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

extension URL {
    /// The string of the url without the scheme inculded
    public var absoluteStringWithoutScheme: String {
        guard let scheme = self.scheme else {
            return absoluteString
        }

        let prefix = scheme + "://"
        let endOfPrefixIndex = prefix.endIndex

        return String(absoluteString[endOfPrefixIndex...])
    }
}
