// Copyright (c) 2017-2019 Coinbase Inc. See LICENSE

import Foundation

extension URLComponents {
    /// Return query params as Dictionary
    public var queryItemsDictionary: [String: String]? {
        return queryItems?.reduce(into: [:]) { $0[$1.name] = $1.value }
    }
}
